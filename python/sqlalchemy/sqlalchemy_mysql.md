## Connection Timeouts and Disconnects
MySQL / MariaDB feature an automatic connection close behavior, for
connections that have been idle for a fixed period of time,
defaulting to eight hours. To circumvent having this issue, use
the create_engine.pool_recycle option which ensures that a connection
will be discarded and replaced with a new one if it has been present in
the pool for a fixed number of seconds:

```python
from sqlalchemy import create_engine
engine = create_engine('mysql+mysqldb://...', pool_recycle=3600)
```
For more comprehensive disconnect detection of pooled connections, including accommodation of server restarts
and network issues, a pre-ping approach may be employed. The 
pessimistic approach refers to emitting a test statement on the 
SQL connection at the start of each connection pool checkout, 
to test that the database connection is still viable.
```python
from sqlalchemy import create_engine
engine = create_engine("mysql+pymysql://user:pw@host/db", pool_pre_ping=True)
```
specify a table with `ENGINE` of `InnoDB`, `CHARSET` of `utf8mb4`, 
and `KEY_BLOCK_SIZE` of `1024`:
```python
from sqlalchemy import Table, Column, String, MetaData
metadata = MetaData()
Table('mytable', metadata,
      Column('data', String(32)),
      mysql_engine='InnoDB',
      mysql_charset='utf8mb4',
      mysql_key_block_size="1024"
     )
```
> It is strongly advised that table names be declared as all 
> lower case both within SQLAlchemy as well as on the MySQL/MariaDB
> database itself, especially if database reflection features are
> to be used.

SQLAlchemy will automatically set AUTO_INCREMENT on the first Integer 
primary key column which is not marked as a foreign key, i.e.
`autoincrement` defaults to `True`
```python
from sqlalchemy import Table, Column, String, MetaData, Integer
metadata = MetaData()
Table('mytable', metadata,
      Column('gid', Integer, primary_key=True, autoincrement=False),
      Column('id', Integer, primary_key=True)
     )
```

### Charset selection
When attempting to pass binary data to the database, while a 
character set encoding is also in place, when the binary data 
itself is not valid for that encoding, MySQL>=5.6 emits a warning:

Add the query string parameter `binary_prefix=True` to the URL
to repair this warning
```python
from sqlalchemy import create_engine 
e = create_engine(
    "mysql+pymysql://scott:tiger@localhost/test?charset=utf8mb4")

engine = create_engine(
    "mysql+mysqldb://scott:tiger@localhost/test?charset=utf8mb4&binary_prefix=true")
```

### Changing `sql_mode`
```python
from sqlalchemy import create_engine, event

eng = create_engine(
    "mysql+mysqldb://scott:tiger@localhost/test", 
    echo='debug'
)

# `insert=True` will ensure this is the very first listener to run
@event.listens_for(eng, "connect", insert=True)
def connect(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    cursor.execute("SET sql_mode = 'STRICT_ALL_TABLES'")

conn = eng.connect()
```