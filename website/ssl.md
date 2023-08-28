## Generating CSR using OpenSSL
This option is normally used on Linux-based Amazon instances as they usually already 
have the required tool setup, or it is easy to set up. All commands should be run 
through either CLI or any third-party command line tool connected to your instance 
(for example, Putty, or Terminal app on MacOS and Linux).

The Private Key is created first and then the CSR is generated based on it.
Run the following command to generate the key:

```commandline
sudo openssl genrsa -out private.key 2048
```

Where `2048` is a key size. If you do not specify the size, a 2048-bit key is generated.
You can specify any name for the key file (private.key) to make it recognizable in case 
you have multiple SSLs stored on the server. If you want to generate the SSL with an 
ECDSA algorithm, you can use this command instead (this is just a recommended 
option — there are other setups you can use, too):

```commandline
sudo openssl ecparam -genkey -name secp384r1 -out private.key -genkey
```

The CSR is generated based on the Private Key. The following command is used for the CSR creation:

```commandline
sudo openssl req -new -key private.key -out csr.pem
```

Alternatively, you can use one command to generate the RSA Private Key and CSR:
```commandline
sudo openssl req -new -newkey rsa:2048 -nodes -keyout private.key -out csr.pem
```

The output will look similar to the following example:
```commandline
You are about to be asked to enter information that will be incorporated into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields, but you can leave some blank.
For some fields there will be a default value.
If you just press Enter, the field will be left blank.

  The following information needs to be filled in. We strongly recommend filling in all the fields. A CSR with any blank fields can be rejected by our system or by the Certificate Authority.

Note: For Organisation Validation (OV) or Extended Validation (EV) types of SSLs, make sure to use the correct legal company name. If it’s a reissued CSR, ensure the company details are the same as the ones used previously.

Note: Please only use Alphanumeric characters. A CSR with special symbols, such as Ä or È, will not be recognized. Such special characters should be replaced with their analogs from the alphanumerics, such as A and E.

Country name: use a valid 2-letter country-code.
State of Province:  Use your state or Province name, or use the Locality name if you have none.
Locality name: use your city, town or other locality name.
Organization Name: use your company/organization name or put NA (Not Applicable).
Organizational Unit: use your unit or department name or put NA (Not Applicable).
Common Name: Fully qualified domain name you need to secure: for example, www.example.com
```

Note: When filling in the Common Name field, it is important to remember that it 
should be the exact domain name you need to secure. It should look like www.example.com, 
example.com, or like mail.example.com, if you need to secure the subdomain. For a Wildcard
certificate the common name should be stated as *.example.com or *.sub.example.com.

Email address: Server administrator's email address: for example, admin@example.com This 
email address will be fetched by the system as an administrative contact for the SSL
certificate files to be sent to once the certificate is issued. You’ll be able to change
it during the SSL activation as well.

Challenge password and Optional company name are legacy fields and can be skipped. Most 
certificates Namecheaps provide secure both www.example.com and example.com automatically. 
However, if you have any doubts, we recommend checking the correct way to define your 
domain name for a particular certificate with our Support Team.

Run the following command to open the CSR file you’ve just generated:
```commandline
cat csr.pem
```

In the output you will see the CSR in plain text. Copy the whole text starting with 
the `"-----BEGIN CERTIFICATE REQUEST-----"` line and use it for the certificate 
activation. Once the certificate is issued by the Certificate Authority, you can
proceed with its installation.

WARNING: Please remember the following points before beginning the process:
Write down the directory where the CSR was generated, as the Private Key for the SSL will be saved 
there. You will need to know where the key is located in order to install the SSL.
If you are not sure which folder it is, you can check it with the pwd command:
```commandline
find / -type f -name "*.csr"
```

or

```commandline
find / -type f -name "*.pem"
```
