Setting up the MDR
------------------

Client
------
You will need to set up a client first. Select the relevant entry from the "Configure" menu. Enter the following values into the form:

Client Name: mdr_ui_local
Client Description: mdr_ui_local
Redirect URLs: http://mdr-ui.site.de:8087
Client ID: mdr_ui_local (overwrite the default value)
Client Secret: You can't change this. You will need to copy it into the docker-compose.yml file.
Client type: Metadata Repository

You will also need a public key for the docker-compose file. You can find this at:

http://samplyauth.site.de:8086/oauth2/certs

(base64DerFormat)

User
----
You will also need to set up a user for MDR, which you can do via the "Configure" menu. Remember to make the user enabled and findable, and click "email verified" too.

Role
----
You do not need to set up a role to use the MDR.

