DocHarris Docker Mysql
==================

Base docker image to run a MySQL database server.

Only MySQL 5.5 is supported for persisting data when working with boot2docker. See Dockerfile Line 23-28 of 5.5 folder.


MySQL version
-------------

Different versions are built from different folders. 


Usage
-----

To create the image `docharris/mysql`, execute the following command on the docharris-mysql folder:

        docker build -t docharris/mysql 5.5/

To run the image and bind to port 3306:

        docker run --name DocHarrisMySQL -d -p 3306:3306 -v /var/www/data/mysql:/var/lib/mysql docharris/mysql

Hint: The path `/var/www/data` exists in the boot2docker.iso as a mounted folder of your Mac/Win system.
The folder `/var/www/data/mysql` must be created before you start docker.


The first time that you run your container, a new user `admin` with all privileges 
will be created in MySQL with a random password. To get the password, check the logs
of the container by running:

        docker logs <CONTAINER_ID>

You will see an output like the following:

        boot2docker ip -> get the ip address

        ========================================================================
        You can now connect to this MySQL Server using:

            mysql -uadmin -p47nnf4FweaKu -h<host> -P<port>

        Please remember to change the above password as soon as possible!
        MySQL user 'root' has no password but only allows local connections
        ========================================================================

In this case, `47nnf4FweaKu` is the password allocated to the `admin` user.

Remember that the `root` user has no password but it's only accessible from within the container.

You can now test your deployment:

        mysql -uadmin -p

Done!


Setting a specific password for the admin account
-------------------------------------------------

If you want to use a preset password instead of a random generated one, you can
set the environment variable `MYSQL_PASS` to your specific password when running the container:

        docker run -d -p 3306:3306 -e MYSQL_PASS="mypass" docharris/mysql

You can now test your deployment:

        mysql -uadmin -p"mypass"

The admin username can also be set via the `MYSQL_USER` environment variable.


Mounting the database file volume
---------------------------------

In order to persist the database data, you can mount a local folder from the host 
on the container to store the database files. To do so:

        docker run -d --volumes-from MySQLStorage docharris/mysql /bin/bash -c "/usr/bin/mysql_install_db"

This will mount the local folder `/path/in/host` inside the docker in `/var/lib/mysql` (where MySQL will store the database files by default). `mysql_install_db` creates the initial database structure.

Remember that this will mean that your host must have `/path/in/host` available when you run your docker image!

After this you can start your mysql image but this time using `/path/in/host` as the database folder:

        docker run -d -p 3306:3306 --volumes-from MySQLStorage docharris/mysql

Migrating an existing MySQL Server
----------------------------------

In order to migrate your current MySQL server, perform the following commands from your current server:

To dump your databases structure:

        mysqldump -u<user> -p --opt -d -B <database name(s)> > /tmp/dbserver_schema.sql

To dump your database data:

        mysqldump -u<user> -p --quick --single-transaction -t -n -B <database name(s)> > /tmp/dbserver_data.sql

To import a SQL backup which is stored for example in the folder `/tmp` in the host, run the following:

        sudo docker run -d -v /tmp:/tmp docharris/mysql /bin/bash -c "/import_sql.sh <user> <pass> /tmp/<dump.sql>"

Where `<user>` and `<pass>` are the database username and password set earlier and `<dump.sql>` is the name of the SQL file to be imported.


Replication - Master/Slave
-------------------------
To use MySQL replication, please set environment variable `REPLICATION_MASTER`/`REPLICATION_SLAVE` to `ture`. Also, on master side, you may want to specify `REPLICATION_USER` and `REPLICATION_PASS` for the account to perform replication, the default value is `replica:replica`

Examples:
- Master MySQL
- 
        docker run -d -e REPLICATION_MASTER=true -e REPLICATION_PASS=mypass -p 3306:3306 --name mysql docharris/mysql

- Example on Slave MySQL:
- 
        docker run -d -e REPLICATION_SLAVE=true -p 3307:3306 --link mysql:mysql docharris/mysql

Now, you can access port `3306` and `3307` for the master/slave mysql
Environment variables
---------------------

`MYSQL_USER`: Set a specific username for the admin account (default 'admin')
`MYSQL_PASS`: Set a specific password for the admin account.

Compatibility Issues
--------------------

- Volume created by MySQL 5.6 cannot be used in MySQL 5.5 Images or MariaDB images
