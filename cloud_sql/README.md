# Usage of the cloud_sql_sample

This sample shows the usage of Cloud SQL with Dart.

## Setup of CloudSQL or local MySQL database

### Google Cloud SQL instance

 1. Go to `Storage -> Cloud SQL` in the
[Google Developers Console](https://console.developers.google.com/) and create a
new Cloud SQL instance.
 2. Request an IP address in the `Access Control` tab of the instance.
 3. Set a password and add an IP network block in the `Authorized Networks`
section.
To allow access from any IP–*not recommended*–`0.0.0.0/0` can be used.

You can now connect to the instance with a `mysql` client:

```
$ mysql -u root -p -h <the-instance-IP>
Welcome to the MySQL monitor.  Commands end with ; or \g.
...
mysql>
```

### Local MySQL instance for testing

For testing, you can use a local MySQL server instead of using a remote Cloud
SQL instance. This can be easily done by using the `mysql` Docker image.

```
# Make sure you've configured Docker environment variables.
# With docker 1.3+ you can use:
$ $(boot2docker shellinit)

# Start the MySQL server and expose it's 3306 port.
$ docker run -d --name localsql -e MYSQL_ROOT_PASSWORD=mysecret mysql
<container hash>
```

This will create a MySQL instance with password `mysecret` for the root
user. The MySelf service will be automatically exposed on port `3306`. The
container will be named `localsql`.

Note: even though the port `3306` is exposed on the host running the Docker
daemon, it is the VirtualBox VM which accepts connections on this port.

Next, determine the IP address of the newly created container.
This IP address will be used by the Dart application.

```
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' localsql
<MySQL Container IP Address>
```

Other Docker containers can connect to the MySQL instance using this IP address.

To use the MySQL prompt, connect from outside of the VirtualBox VM using:

```
$ mysql -u root -p -h $(boot2docker ip 2> /dev/null)
Enter password: 'mysecret'
Welcome to the MySQL monitor.
...
mysql>
```

## Setting up the 'greetingsdb' database & a 'greetings' table.

Before our Dart application can query and modify data you need to create a
database and tables.
This can be easily done by copying-and-pasting the following script in at the MySQL prompt:

```
CREATE DATABASE greetingsdb;
USE greetingsdb;
CREATE TABLE greetings (
  id INTEGER NOT NULL AUTO_INCREMENT,
  author VARCHAR(255) NOT NULL,
  content LONGTEXT NOT NULL,
  date DATETIME NOT NULL,
  PRIMARY KEY(id)
);
```

## Running the sample

To run the example, `bin/server.dart` must be updated with the correct
IP address and password (see the `<please-fill-in>` markers in the code).

The application can be started using

    $ gcloud preview app run app.yaml

To view the application, navigate to:

    http://localhost:8080
