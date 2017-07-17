# MySQL 5.6.21
The package provides MySQL server inside OSv.

## Usage
Following command will start MySQL using default username and password (root/root)
and create default database schema (default) with UTF8 default character set:
```
$ capstan run demo --boot mysql -m 700MB
```
| ENV       |  MAPS TO    | DEFAULT VALUE       | EFFECT
|-----------|-------------|---------------------|--------
| INIT_FILE | --init-file | /etc/mysql-init.sql | script that prepares database
| ARGS      | arg         | (empty)             | mysqld arguments

Feel free to modify INIT_FILE to match your needs (e.g. to change username/password).

## Limitations
For some reason MySQL needs at least 700MB of memory to boot properly. Be careful about
this since default memory is 512MB and the MySQL doesn't boot.
