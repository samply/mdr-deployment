#!/bin/bash -e

: "${POSTGRES_HOST:=samplyauth-db}"

MAND_VARS="MAIL_HOST MAIL_FROMADDR MAIL_FROMNAME MAIL_USER MAIL_PASS POSTGRES_PASSWORD POSTGRES_USER POSTGRES_DB FQDN ADMIN_USER ADMIN_PASS"

MISSING_VARS=""

for VAR in $MAND_VARS; do
	if [ -z "${!VAR}" ]; then
		MISSING_VARS+="$VAR "
	fi
done

if [ -n "$MISSING_VARS" ]; then
	echo "Error: Mandatory variables not defined (see documentation): $MISSING_VARS"
	exit 1
fi

mkdir -p /etc/samply

# E-Mail

FILENAME="auth.mail.xml"

echo "Generating $FILENAME from environment variables."

xmlstarlet ed \
	-u "ns1:mailSending/ns1:host" -v "$MAIL_HOST" \
	-u "ns1:mailSending/ns1:fromAddress" -v "$MAIL_FROMADDR" \
	-u "ns1:mailSending/ns1:fromName" -v "$MAIL_FROMNAME" \
	-u "ns1:mailSending/ns1:user" -v "$MAIL_USER" \
	-u "ns1:mailSending/ns1:password" -v "$MAIL_PASS" \
	/docker/templates/conf/$FILENAME > /etc/samply/$FILENAME

# Database

FILENAME="auth.postgres.xml"

echo "Generating $FILENAME from environment variables."

xmlstarlet ed -N x="http://schema.samply.de/common" \
	-u "x:postgresql/x:host" -v "$POSTGRES_HOST" \
	-u "x:postgresql/x:database" -v "$POSTGRES_DB" \
	-u "x:postgresql/x:username" -v "$POSTGRES_USER" \
	-u "x:postgresql/x:password" -v "$POSTGRES_PASSWORD" \
	/docker/templates/conf/$FILENAME > /etc/samply/$FILENAME

# Authentication

FILENAME="auth.oauth2.xml"

if [ -e /etc/samply/$FILENAME ]; then
	echo "Skipping generation of $FILENAME as it already exists."
else
	echo "$FILENAME not found. Generating new key pair."

	TEMPFILE=$(mktemp)

	openssl genrsa -out $TEMPFILE 4096
	OAUTH2_PRIVKEY=$(openssl pkcs8 -topk8 -nocrypt -in $TEMPFILE -outform DER | base64)
	OAUTH2_PUBKEY=$(openssl rsa -in $TEMPFILE -outform DER -pubout | base64)

	rm $TEMPFILE

	xmlstarlet ed -N x="http://schema.samply.de/config/OAuth2Provider" \
		-u "x:oAuth2Provider/x:privateKey" -v "$OAUTH2_PRIVKEY" \
		-u "x:oAuth2Provider/x:publicKey" -v "$OAUTH2_PUBKEY" \
		-u "x:oAuth2Provider/x:issuer" -v "https://$FQDN" \
		/docker/templates/conf/$FILENAME > /etc/samply/$FILENAME
fi

# Tomcat admin access

FILENAME="tomcat-users.xml"

if [ -e /usr/local/tomcat/conf/$FILENAME ]; then
	echo "Skipping generation of $FILENAME as it already exists."
else
	echo "Generating $FILENAME from environment variables."

	xmlstarlet ed -N x="http://tomcat.apache.org/xml" \
		-s "x:tomcat-users" -t elem -n "role" \
		-i "//role" -t attr -name "rolename" -v "auth-admin" \
		-s "x:tomcat-users" -t elem -n "user" \
		-i "//user" -t attr -name "username" -v "$ADMIN_USER" \
		-i "//user" -t attr -name "password" -v "$ADMIN_PASS" \
		-i "//user" -t attr -name "roles" -v "auth-admin" \
		/docker/templates/conf/tomcat-users.xml > /usr/local/tomcat/conf/tomcat-users.xml
fi

# Add log4j2.xml (actually req'd for Samply.Auth operation)

[ -e /etc/samply/log4j2.xml ] || cp /docker/templates/conf/log4j2.xml /etc/samply/log4j2.xml

exec catalina.sh run
