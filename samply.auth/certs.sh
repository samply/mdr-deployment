mkdir -p /etc/samply
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

