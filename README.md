# Lapis-chan

Lapis-chan is an text/image board written in Lua using the Lapis web framework.

# Features

To view a complete list of features, check out the [Feature Set](https://docs.google.com/spreadsheets/d/19WfJm5cT_QHkuStD4NbuWLZ8EEhr23yEmJbS083mjQE/edit?usp=sharing) spreadsheet.

# Dependencies

## Install From Source

* giflib 5.1.1
* OpenResty custom nginx distro

## Install From Package Manager

* ffmpeg
* libmagicwand-dev
* LuaJIT 2.0+
* Luarocks
* PostgreSQL or MySQL (untested)

## Install From LuaRocks

* bcrypt
* giflib
* i18n
* Lapis 1.5+
* luaposix
* magick
* markdown
* md5

# Install

## giflib

Lapis-chan specifically requires v5.1.1.

```
$ wget http://downloads.sourceforge.net/project/giflib/giflib-5.1.1.tar.bz2
$ tar jxf giflib-5.1.1.tar.bz2
$ cd giflib-5.1.1
$ ./configure
$ make
$ sudo make install
```

## OpenResty

```
$ tar xvf ngx_openresty-VERSION.tar.gz
$ cd ngx_openresty-VERSION/
$ ./configure
$ make
$ sudo make install
```

## Other Stuff

### Debian Family

```
$ sudo apt-get install ffmpeg
$ sudo apt-get install libmagickwand-dev
$ sudo apt-get install luajit
$ sudo apt-get install luarocks
$ sudo apt-get install postgresql
$ sudo apt-get install mysql-server
```

### RHEL Family

```
$ sudo dnf install ffmpeg
$ sudo dnf install ImageMagick-devel
$ sudo dnf install luajit
$ sudo dnf install luarocks
$ sudo dnf install postgresql
$ sudo dnf install mysql-server
```

### LuaRocks

```
$ luarocks install bcrypt
$ luarocks install giflib --server=http://luarocks.org/dev
$ luarocks install i18n
$ luarocks install lapis
$ luarocks install luafilesystem
$ luarocks install luaposix
$ luarocks install magick
$ luarocks install markdown
$ luarocks install md5
```

NOTE: Setting up [pg_hba.conf](https://github.com/leafo/pgmoon/issues/19) might be required!

NOTE: [This](https://fedoraproject.org/wiki/PostgreSQL#User_Creation_and_Database_Creation) may be helpful too!

# Installing

Installing Lapis-chan is a multi-step process. Before you can run the installation script, you must first configure your server. Below are the prerequisite steps:

## Create a New Database

Lapis-chan prefers to live inside its own database, so it is highly recommended to create an empty database for Lapis-chan to install to. Lapis-chan has been tested on PostgreSQL but Lapis Models should also be compatible with MySQL.

```
$ psql
> CREATE DATABASE 'lapischan';
```

## Configure config.lua

In this file, you need to set the `lua_path` and `lua_cpath` to find both LuaRocks and OpenResty. LuaRocks has a simple command, OpenResty does not so you need to know where you installed it to.

```
$ luarocks path
```

Make sure the following options within the config file are set correctly:

1. subdomains - Probably best to leave this as false unless know what you are doing with ngx configurations
1. site_name  - Set this to whatever you want your website to be called
1.	port - Most commonly set to `80` unless you are hosting multiple websites on the same server
1. Make sure your db engine is set properly to `postgres` or `mysql`
1. host - Most commonly `localhost` or `127.0.0.1`
1. user - The database username
1. password - The database password
1. database - The database name (we just created it!)

## Migrate the Database

Now that we have Lapis configured, you must execute the migration to fill the database with empty tables. It is recommended to perform this step every time you upgrade Lapis-chan as it will automagically update your database without damaging any data.

```
$ lapis migrate
```

## Create Cryptographic Secrets

In the `secrets` directory, open up both the `token.lua` and `salt.lua` files.

### Secret Token

The secret token should be a random string of characters between 40 and 60 characters in length. Change `CHANGE_ME` to your secret token. Keep this token extremely safe, it is the backbone of security on Lapis-chan! Don't lose it, either!

### Secret Salt

The secret salt should be a random string of characters exactly two characters in length. The salt can be comprised of letters, numbers, a period (".") or a slash ("\\"). Change `CHANGE_ME` to your secret salt. This salt is not necessarily meant to be secure, but don't hand it out willy-nilly either. This is only used for generating insecure tripcodes.

## Start Lapis

Now we're ready to finish the installation!

```
$ lapis server production
```
