Namecheap requires the SSL certs be re-issued every year
This requires generating CSR that contains the appropriate domain
Currently, we have
 * `*.mickelonius.com`
 * `mickelonius-analytics.com`

```bash
# Generate key
sudo openssl genrsa -out private.key 2048
# or
sudo openssl ecparam -genkey -name secp384r1 -out private.key -genkey

# Generate CSR
sudo openssl req -new -key private.key -out csr.pem

# Or, all in one command
sudo openssl req -new -newkey rsa:2048 -nodes -keyout private.key -out csr.pem
```