Postfix Config lines

Add the following lines to `/etc/postfix/main.cf`

relayhost = [smtp.gmail.com]:587
myhostname= your_hostname

Location of sasl_passwd we saved
smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd

Enables SASL authentication for postfix
smtp_sasl_auth_enable = yes
smtp_tls_security_level = encrypt

Disallow methods that allow anonymous authentication
smtp_sasl_security_options = noanonymous

-------------------------------------------------------------------------------------------

Create a file under /etc/postfix/sasl/

Filename: sasl_passwd

Add the below line
[smtp.gmail.com]:587 email@gmail.com:password


change directory to `cd /etc/postfix/sasl`
change the ownership `sudo chown root:root  *`
change the permission `sudo chmod 600 *`

Convert the sasl_passwd file into db file
`postmap /etc/postfix/sasl/sasl_passwd`

Start the postfix service


------------------------------------------------------------------------------------------

To send an email using Linux terminal

echo "Test Mail" | mail -s "Postfix TEST" paul@gmail.com