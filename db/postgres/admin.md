# Users/Roles
```psql
CREATE ROLE new_superuser WITH LOGIN PASSWORD 'secure_password' SUPERUSER;
ALTER USER username WITH PASSWORD 'new_password';
mike/m43d23l
```

# Connections from hosts
```bash
# To get /path/to
# RUN
# SHOW config_file;
# psql

# Add
# host    all             all             0.0.0.0/0               md5
# to /path/to/pg_hba.conf

# Add or change
# listen_addresses = '*'
# in /path/to/postgresql.conf
sudo systemctl restart postgresql
sudo ufw allow 5432/tcp
