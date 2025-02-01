# Basic admin
**Linux:**
If PostgreSQL is installed as a systemd service, you can manage it as follows:

```bash
# Start PostgreSQL
sudo systemctl start postgresql

# Stop PostgreSQL
sudo systemctl stop postgresql

# Restart PostgreSQL
sudo systemctl restart postgresql

# Check the status of PostgreSQL
sudo systemctl status postgresql
```

**macOS (if using Homebrew):**

```bash
# Start PostgreSQL
brew services start postgresql

# Stop PostgreSQL
brew services stop postgresql

# Restart PostgreSQL
brew services restart postgresql
```

**Windows:**
If PostgreSQL is installed as a service, you can control it using the Services Manager or the `net` command.

```cmd
# Start PostgreSQL
net start postgresql-x64-16

# Stop PostgreSQL
net stop postgresql-x64-16
```

# Users/Roles
```psql
CREATE ROLE new_superuser WITH LOGIN PASSWORD 'secure_password' SUPERUSER;
ALTER USER username WITH PASSWORD 'new_password';
mike/m43d23l
```

In PostgreSQL, users are referred to as “roles.” You can create roles with various permissions.

**Example: Creating a Role with Superuser Privileges**

```sql
CREATE ROLE new_superuser WITH LOGIN SUPERUSER PASSWORD 'your_password';
```

**Example: Creating a Role without Superuser Privileges**

```sql
CREATE ROLE limited_user WITH LOGIN PASSWORD 'your_password';
```

**Granting Permissions to Roles**

- Grant privileges to access a database:

  ```sql
  GRANT CONNECT ON DATABASE your_database TO limited_user;
  ```

- Grant specific privileges on tables:

  ```sql
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE your_table TO limited_user;
  ```

**Revoking Permissions**

```sql
REVOKE ALL PRIVILEGES ON TABLE your_table FROM limited_user;
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
```

PostgreSQL configurations are typically managed in the `postgresql.conf` and `pg_hba.conf` files.

- **postgresql.conf** – Configure PostgreSQL settings, such as ports, memory, and logging.
- **pg_hba.conf** – Configure client authentication, defining who can connect to which databases from where.

**Example: Changing the Listening Port**

Edit `postgresql.conf`:

```conf
# Change the default port from 5432 to 5433
port = 5433
```

Then, restart PostgreSQL to apply changes.

**Example: Managing Access Control (pg_hba.conf)**

Edit `pg_hba.conf` to control who can access the database server and from where.

```conf
# Allow local connections with password authentication
host    all             all             127.0.0.1/32            md5

# Allow connections from a specific IP range
host    all             all             192.168.1.0/24          md5
```

**Reload the Configuration**

After changes, reload the configuration without restarting the service:

```bash
sudo systemctl reload postgresql
```