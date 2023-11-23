```commandline
pip install mysqlclient SQLAlchemy==2.0.0rc2
```


```python
from sqlalchemy import ForeignKey, Table, Column, Integer, String
from sqlalchemy import MetaData, create_engine, text

# Transactions and DBAPI
# engine = create_engine("sqlite+pysqlite:///:memory:", echo=True)

# note that create_engine is lazily evaluated, meaning no connection is made until
# a database operation is actually executed
# mysql+mysqldb://<user>:<password>@<host>[:<port>]/<dbname>
engine = create_engine(
    "mysql+mysqldb://scott:tiger@192.168.0.134/test"
)

with engine.connect() as conn:
    result = conn.execute(text("select 'hello world'"))
    print(result.all())
    
"""BEGIN (implicit)
select 'hello world'
[...] ()
[('hello world',)]
ROLLBACK"""

# "commit as you go"
with engine.connect() as conn:
    conn.execute(text("CREATE TABLE some_table (x int, y int)"))
    conn.execute(
        text("INSERT INTO some_table (x, y) VALUES (:x, :y)"),
        [{"x": 1, "y": 1}, {"x": 2, "y": 4}],
    )
    conn.commit()
"""BEGIN (implicit)
CREATE TABLE some_table (x int, y int)
[...] ()
<sqlalchemy.engine.cursor.CursorResult object at 0x...>
INSERT INTO some_table (x, y) VALUES (?, ?)
[...] [(1, 1), (2, 4)]
<sqlalchemy.engine.cursor.CursorResult object at 0x...>
COMMIT"""

# "begin once"... block is enclosed in transaction
with engine.begin() as conn:
    conn.execute(
        text("INSERT INTO some_table (x, y) VALUES (:x, :y)"),
        [{"x": 6, "y": 8}, {"x": 9, "y": 10}],
    )
"""BEGIN (implicit)
INSERT INTO some_table (x, y) VALUES (?, ?)
[...] [(6, 8), (9, 10)]
<sqlalchemy.engine.cursor.CursorResult object at 0x...>
COMMIT"""

with engine.connect() as conn:
    result = conn.execute(text("SELECT x, y FROM some_table"))
    for row in result:
        print(f"x: {row.x}  y: {row.y}")
"""BEGIN (implicit)
SELECT x, y FROM some_table
[...] ()
x: 1  y: 1
x: 2  y: 4
x: 6  y: 8
x: 9  y: 10
ROLLBACK"""

result = conn.execute(text("select x, y from some_table"))

for x, y in result:
    ...

for row in result:
    x = row[0]

for row in result:
    y = row.y

    # illustrate use with Python f-strings
    print(f"Row: {row.x} {y}")

for dict_row in result.mappings():
    x = dict_row["x"]
    y = dict_row["y"]

# parameterize query
with engine.connect() as conn:
    result = conn.execute(text("SELECT x, y FROM some_table WHERE y > :y"), {"y": 2})
    for row in result:
        print(f"x: {row.x}  y: {row.y}")
"""BEGIN (implicit)
SELECT x, y FROM some_table WHERE y > ?
[...] (2,)
x: 2  y: 4
x: 6  y: 8
x: 9  y: 10
ROLLBACK"""

with engine.connect() as conn:
    conn.execute(
        text("INSERT INTO some_table (x, y) VALUES (:x, :y)"),
        [{"x": 11, "y": 12}, {"x": 13, "y": 14}],
    )
    conn.commit()
"""BEGIN (implicit)
INSERT INTO some_table (x, y) VALUES (?, ?)
[...] [(11, 12), (13, 14)]
<sqlalchemy.engine.cursor.CursorResult object at 0x...>
COMMIT"""

from sqlalchemy.orm import Session

stmt = text("SELECT x, y FROM some_table WHERE y > :y ORDER BY x, y")
with Session(engine) as session:
    result = session.execute(stmt, {"y": 6})
    for row in result:
        print(f"x: {row.x}  y: {row.y}")
"""BEGIN (implicit)
SELECT x, y FROM some_table WHERE y > ? ORDER BY x, y
[...] (6,)
x: 6  y: 8
x: 9  y: 10
x: 11  y: 12
x: 13  y: 14
ROLLBACK"""

with Session(engine) as session:
    result = session.execute(
        text("UPDATE some_table SET y=:y WHERE x=:x"),
        [{"x": 9, "y": 11}, {"x": 13, "y": 15}],
    )
    session.commit()
"""BEGIN (implicit)
UPDATE some_table SET y=? WHERE x=?
[...] [(11, 9), (15, 13)]
COMMIT"""

# Metadata (Core)
# MetaData object: This object is essentially a facade around a Python 
# dictionary that stores a series of Table objects keyed to their string name.
metadata_obj = MetaData()

# Create table and add to metadata
user_table = Table(
    "user_account",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("name", String(30)),
    Column("fullname", String),
)
user_table.c.name
"""Column('name', String(length=30), table=<user_account>)"""
user_table.c.keys()
"""['id', 'name', 'fullname']"""
user_table.primary_key
"""PrimaryKeyConstraint(Column('id', Integer(), table=<user_account>, primary_key=True, nullable=False))"""


address_table = Table(
    "address",
    metadata_obj,
    Column("id", Integer, primary_key=True),
    Column("user_id", ForeignKey("user_account.id"), nullable=False),
    Column("email_address", String, nullable=False),
)

# emit CREATE TABLE statements, or DDL, to our database so that we 
# can insert and query data from them.
engine = create_engine("mysql+mysqldb://scott:tiger@192.168.0.134/test")
metadata_obj.create_all(engine)
metadata_obj.drop_all()  # method that will emit DROP statements in the 
                     # reverse order as it would emit CREATE in order to drop schema elements
"""BEGIN (implicit)
PRAGMA main.table_...info("user_account")
...
PRAGMA main.table_...info("address")
...
CREATE TABLE user_account (
    id INTEGER NOT NULL,
    name VARCHAR(30),
    fullname VARCHAR,
    PRIMARY KEY (id)
)
...
CREATE TABLE address (
    id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    email_address VARCHAR NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY(user_id) REFERENCES user_account (id)
)
...
COMMIT"""

user_table.c.name
"""Column('name', String(length=30), table=<user_account>)"""

user_table.c.keys()
"""['id', 'name', 'fullname']"""

user_table.primary_key
"""PrimaryKeyConstraint(Column('id', Integer(), table=<user_account>, primary_key=True, nullable=False))"""

# Metadata (ORM)
# `User` and `Address`, are now referred towards as ORM Mapped Classes, 
# and are available for use in ORM persistence and query operations
from sqlalchemy.orm import DeclarativeBase
class Base(DeclarativeBase):
    pass

from typing import List
from typing import Optional
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import relationship

engine = create_engine("mysql+mysqldb://scott:tiger@192.168.0.134/test")

class User(Base):
    __tablename__ = "user_account"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(30))
    fullname: Mapped[Optional[str]]

    addresses: Mapped[List["Address"]] = relationship(back_populates="user")

    def __repr__(self) -> str:
        return f"User(id={self.id!r}, name={self.name!r}, fullname={self.fullname!r})"

class Address(Base):
    __tablename__ = "address"

    id: Mapped[int] = mapped_column(primary_key=True)
    email_address: Mapped[str]
    user_id = mapped_column(ForeignKey("user_account.id"))

    user: Mapped[User] = relationship(back_populates="addresses")

    def __repr__(self) -> str:
        return f"Address(id={self.id!r}, email_address={self.email_address!r})"

Base.metadata.create_all(engine)
"""BEGIN (implicit)
PRAGMA main.table_...info("user_account")
...
PRAGMA main.table_...info("address")
...
COMMIT"""

sandy = User(name="sandy", fullname="Sandy Cheeks")

## Get metadata/schema info from existing



metadata_obj = MetaData()
engine = create_engine("mysql+mysqldb://scott:tiger@192.168.0.134/test")
some_table = Table("some_table", metadata_obj, autoload_with=engine)
"""BEGIN (implicit)
PRAGMA main.table_...info("some_table")
[raw sql] ()
SELECT sql FROM  (SELECT * FROM sqlite_master UNION ALL   SELECT * FROM sqlite_temp_master) WHERE name = ? AND type in ('table', 'view')
[raw sql] ('some_table',)
PRAGMA main.foreign_key_list("some_table")
...
PRAGMA main.index_list("some_table")
...
ROLLBACK"""

## `INSERT`s
from sqlalchemy import insert
stmt = insert(user_table).values(name="spongebob", fullname="Spongebob Squarepants")

print(stmt)
"""INSERT INTO user_account (name, fullname) VALUES (:name, :fullname)"""
compiled = stmt.compile()
compiled.params
"""{'name': 'spongebob', 'fullname': 'Spongebob Squarepants'}"""

with engine.connect() as conn:
    result = conn.execute(stmt)
    conn.commit()
"""BEGIN (implicit)
INSERT INTO user_account (name, fullname) VALUES (?, ?)
[...] ('spongebob', 'Spongebob Squarepants')
COMMIT"""

result.inserted_primary_key
"(1,)"

with engine.connect() as conn:
    result = conn.execute(
        insert(user_table),
        [
            {"name": "sandy", "fullname": "Sandy Cheeks"},
            {"name": "patrick", "fullname": "Patrick Star"},
        ],
    )
    conn.commit()
"""BEGIN (implicit)
INSERT INTO user_account (name, fullname) VALUES (?, ?)
[...] [('sandy', 'Sandy Cheeks'), ('patrick', 'Patrick Star')]
COMMIT"""

```