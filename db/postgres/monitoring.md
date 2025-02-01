
Viewing Database Size
```sql
SELECT pg_size_pretty(pg_database_size('your_database'));
```

Checking Active Connections
```sql
SELECT * FROM pg_stat_activity;
```

**Setting Configuration for Performance**

Here are a few critical settings in `postgresql.conf`:

- `shared_buffers`: Controls memory allocated for caching data in shared memory. Increase based on system memory.
- `work_mem`: Memory per query for sorting and hash operations.
- `maintenance_work_mem`: Memory allocated for maintenance tasks like `VACUUM`.

```conf
shared_buffers = 2GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

**VACUUM and ANALYZE**

These commands help maintain the database by removing dead rows and updating statistics.

```sql
VACUUM ANALYZE;
```

Or, to vacuum a specific table:

```sql
VACUUM your_table;
```

---

** Logging and Troubleshooting **

**Setting Up Logging**

Enable logging in `postgresql.conf`:

```conf
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%a.log'
```

**Viewing Logs**

On Linux, PostgreSQL logs are often found in `/var/lib/pgsql/pg_log/` or `/var/log/postgresql/`. Check logs for errors or performance issues.

**Checking System Activity**

PostgreSQL has system views for checking performance metrics:

- `pg_stat_user_tables`: Shows row activity on tables.
- `pg_stat_user_indexes`: Shows index usage.

Example:

```sql
SELECT relname, seq_scan, idx_scan, n_tup_ins, n_tup_upd, n_tup_del 
FROM pg_stat_user_tables;
```

**Security Best Practices**

- **Secure Passwords**: Use strong passwords for all roles.
- **Least Privilege**: Grant users only the privileges they need.
- **SSL/TLS**: Configure SSL for encrypted connections.
- **Firewall**: Restrict access to PostgreSQL from trusted networks only.

**Example: Enabling SSL Connections**

In `postgresql.conf`:

```conf
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```