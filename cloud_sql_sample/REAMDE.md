# Usage of the cloud_sql_sample

## Setup of CloudSQL or local MySQL database

### Google Cloud SQL instance

The [Google Developers Console](https://console.developers.google.com/) allows
one to create new Cloud SQL instances in the `Storage -> Cloud SQL` section.

The second step is to request an IP address in the `Access Control` tab of the
instance.

Finally it is necessary to set a password and add an IP network block in the
`Authorized Networks` section. To allow all access `0.0.0.0/0` can be used.

After this it is possible to connect to the instance via the a `mysql` client:

```
$ mysql -u root -p -h <the-instance-IP>
Welcome to the MySQL monitor.  Commands end with ; or \g.
...
mysql> 
```

### Local MySQL instance for testing

For testing purposes it might make sense to start a local MySQL server instead
of using a remote Cloud SQL instance. This can be easily achieved by using the
mysql docker image.

```
# Set the DOCKER_HOST environment variable
$ export DOCKER_HOST="tcp://$(boot2docker ip 2> /dev/null):2375"

# Start the MySQL server and expose it's 3306 port.
$ docker run -d --name localsql -e MYSQL_ROOT_PASSWORD=mysecret mysql
<container hash>
```

This will create a new mysql instance with password `mysecret` for the root
user. The mysql service will be automatically exposed on port `3306`. The
container will be named `localsql`.

Note that even though the port `3306` is exposed on the host running the docker
daemon, it is the VirtualBox VM which accepts connections on this port.

The next step is to find out the IP address of the just created container. This
IP address will be used by the dart application to connect to it.

```
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' localsql
<MySQL IP Address>
```

Other docker containers can connect to the MySQL instance using this IP address.

For getting a mysql prompt, we can connect from outside of the VirtualBox VM
using

```
$ mysql -u root -p -h $(boot2docker ip 2> /dev/null)
Enter password: 'mysecret' 
Welcome to the MySQL monitor.
...
mysql> 
```

## Setting up the 'greetingsdb' database & a 'greetings' table.

Before our dart application can insert/query on data from the database we need
to create the database and the tables first. This can be easily done with the
mysql prompt:

```
mysql> CREATE DATABASE greetingsdb;
Query OK, 1 row affected (0.00 sec)
mysql> USE greetingsdb;
Database changed.
mysql> CREATE TABLE greetings (
    ->   id INTEGER NOT NULL AUTO_INCREMENT,
    ->   author VARCHAR(255) NOT NULL,
    ->   content LONGTEXT NOT NULL,
    ->   date DATETIME NOT NULL,
    ->   PRIMARY KEY(id)
    -> );
Query OK, 0 rows affected (0.00 sec)
mysql> quit
Bye
```

## Running the sample

In order to run the example, `bin/server.dart` must be changed with the correct
IP address and password (see the `<please-fill-in>` markers in the code).
