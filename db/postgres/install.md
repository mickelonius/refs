# PostGreSQL Install
```bash

# Add APT repo
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

sudo apt update
sudo apt install postgresql postgresql-14 postgresql-contrib

sudo systemctl list-units | grep postgres
sudo systemctl status postgresql@<version=14|16>-main
sudo systemctl stop postgresql@14-main

sudo mkdir -p /data/postgres/14
sudo chown -R postgres:postgres /data/postgres/14
sudo chmod -R 700 /data/postgres/14

# As postgres user, verify or adjust the configuration in the
# PostgreSQL configuration file (`postgresql.conf`), which is now
# located in your custom directory, under the `pgdata` subdirectory:
sudo pg_dropcluster --stop 14 main
sudo -u postgres pg_createcluster 14 main --datadir=/data/postgres/14

sudo systemctl start postgresql@14-main
sudo -u postgres psql -c "SHOW data_directory;"
sudo -u postgres /usr/lib/postgresql/14/bin/psql -c "SHOW data_directory;"
```

## Alias to use PG 14 (16 default)
```
# .bashrc
alias psql14="/usr/lib/postgresql/14/bin/psql"
alias postgres14="/usr/lib/postgresql/14/bin/postgres"
```

## Allowing connection from anywhere
```bash
# Change to listen_addresses = '*'
sudo nano /etc/postgresql/16/main/postgresql.conf

# Add
# allow connections from any IP address on the local network:
# host    all             all             192.168.1.0/24          md5
# allow connections from any IP address (not recommended for production):
# host    all             all             0.0.0.0/0               md5
sudo nano /etc/postgresql/16/main/pg_hba.conf

# For the changes to take effect, restart the PostgreSQL service
sudo systemctl restart postgresql

# for firewall, if necessary
sudo ufw allow 5432/tcp
```