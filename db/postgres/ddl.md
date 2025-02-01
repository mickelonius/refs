## Creation
```sql
CREATE DATABASE <database_name>;

-- Get table names
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';
```

## Database Management
**Creating and Deleting Databases**

- Create a new database:

  ```sql
  CREATE DATABASE new_database;
  ```

- Delete a database:

  ```sql
  DROP DATABASE new_database;
  ```

**Backup and Restore**

- To back up a database, you can use the `pg_dump` utility:

  ```bash
  pg_dump -U username -d your_database > backup_file.sql
  ```

- To restore a database:

  ```bash
  psql -U username -d your_database -f backup_file.sql
  ```

For large databases, consider using `pg_dumpall` to back up all databases at once or `pg_basebackup` for streaming replication purposes.
