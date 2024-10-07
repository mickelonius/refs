https://www.slingacademy.com/article/how-to-upgrade-postgresql-latest-version-ubuntu/

https://www.postgresqltutorial.com/postgresql-administration/uninstall-postgresql-ubuntu/

https://askubuntu.com/questions/172514/how-do-i-uninstall-mysql


### `pgloader`
```bash
pgloader mysql://mike:<pswd>@127.0.0.1:3306/f1db pgsql:///f1db
```

In order to avoid the `QMYND:MYSQL-UNSUPPORTED-AUTHENTICATION` error you have to switch your 
mysqld to use mysql_native_password by default.

Edit your `my.cnf` and in `[mysqld]` section add:
```
default-authentication-plugin=mysql_native_password
```

Then you need to update your user's password to mysql_native_password type like this:
```sql
ALTER USER 'youruser'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
```
