---
layout: post
title:  "Use FreeIPA Certificate for oVirt Engine"
date:   2022-06-30 12:00:00 -0800
categories: freeipa, ovirt
---
Red Hat provides documentation for replacing the certificate used by the oVirt Engine web interface here.

Red Hat’s documentation provides a general overview of replacing the certificate. However, I will be documenting more specific steps to use your internal FreeIPA Certificate Authority to generate a certificate, apply the needed conversions, and configure oVirt Engine to use it.

## Certificate Signing Request Creation

When issuing a certificate from IPA, you are provided a helpful command to use certutil to generate a CSR on the client computer. As of oVirt 4.4, certutil is not included. With the image based method of managing packages and their updates, installing certutil is not immediately straightforward. The two remaining options are:

* Create the CSR on another machine and copy the resulting key file to the oVirt Engine VM
* Use openssl to create the CSR.

Opting for the openssl method, you can create this request on the oVirt Engine VM:

```
openssl req -newkey rsa:4096 -keyout apache.key -out apache.csr
```

### IPA Principal and Certificate Creation

Before we can issue a certificate using the CSR data, we need to setup a principal in IPA.

![FreeIPA oVirt HTTP Service](/asseets/freeipa-add-ovirt-http-service.png)

Proceed to Identity -> Services -> Add Service. Fill in HTTP as the service and the FQDN of the oVirt Engine. Our engine VM isn’t joined to the realm so we will want to select the option to Skip host check and continue.

Next, issue the certificate from Authentication -> Certificates -> Certificates -> Issue. Use the full principal name, in my case HTTP/ovirt.lukedavidson.space@LUKEDAVIDSON.SPACE. You can reference this in the Service tab if need be. Finally, paste the contents of the generated apache.csr file into the text box and click Issue.

Onve the certificate is issued in IPA. Download and the IPA CA bundle and copy it to the oVirt Engine VM. We will next want to use openssl to remove the passphrase on the ovirt.key if one was set in the CSR request. We can also rename the key to apache.key to 

```
openssl rsa -in apache.key -out apache.key
```

## Certificate Installation

Put the engine in maintenance mode. This can be done from oVirt node rather than the engine itself.

```
hosted-engine --set-maintenance --mode=global 
```

Copy the IPA CA bundle to the ca-trust source directory and update the system’s CA trust.

```
cp ipa-ca.pem /etc/pki/ca-trust/source/anchors
update-ca-trust 
```

Remove the symlink for the apache ca certificate and replace it with your IPA CA bundle.

```
rm /etc/pki/ovirt-engine/apache-ca.pem
cp ipa-ca.pem /etc/pki/ovirt-engine/apache-ca.pem
```

Backup the original and replace with you certificate.

```
cp /etc/pki/ovirt-engine/keys/{apache.key.nopas,apache.key.nopass.bck}
cp /etc/pki/ovirt-engine/certs/{apache.cer,apache.cer.bck}
cp apache.key /etc/pki/ovirt-engine/keys/apache.key.nopass
chown root:ovirt /etc/pki/ovirt-engine/keys/apache.key.nopass
chmod 640 /etc/pki/ovirt-engine/keys/apache.key.nopass
cp apache.cer /etc/pki/ovirt-engine/certs/apache.cer
chown root:ovirt /etc/pki/ovirt-engine/certs/apache.cer
chmod 644 /etc/pki/ovirt-engine/certs/apache.cer
systemctl restart httpd.service
cat > EOF << /etc/ovirt-engine/engine.conf.d/99-custom-truststore.conf
ENGINE_HTTPS_PKI_TRUST_STORE="/etc/pki/java/cacerts"
ENGINE_HTTPS_PKI_TRUST_STORE_PASSWORD=""
EOF

cp /etc/ovirt-engine/ovirt-websocket-proxy.conf.d/{10-setup.conf,99-setup.conf}

cat > EOF << /etc/ovirt-engine/ovirt-websocket-proxy.conf.d/99-setup.conf 
SSL_CERTIFICATE=/etc/pki/ovirt-engine/certs/apache.cer
SSL_KEY=/etc/pki/ovirt-engine/keys/apache.key.nopass
EOF

systemctl restart ovirt-websocket-proxy.service
mkdir -p /etc/ovirt-engine-backup/engine-backup-config.d

cat > EOF << /etc/ovirt-engine-backup/engine-backup-config.d/update-system-wide-pki.sh
BACKUP_PATHS="${BACKUP_PATHS} /etc/ovirt-engine-backup"
EOF

cp -f /etc/pki/ovirt-engine/apache-ca.pem /etc/pki/ca-trust/source/anchors/ipa-ca.pem
update-ca-trust

systemctl restart ovirt-provider-ovn.service
systemctl restart ovirt-imageio.service
systemctl restart ovirt-engine.service
```


