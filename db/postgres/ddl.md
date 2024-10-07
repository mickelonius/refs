## Creation
```sql
CREATE DATABASE <database_name>;

-- Get table names
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';


```