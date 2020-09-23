# Lapis-chan

Lapis-chan is a text and image board written in Lua using the Lapis web framework.

# Features

To view a complete list of features, check out the [Feature Set](https://docs.google.com/spreadsheets/d/19WfJm5cT_QHkuStD4NbuWLZ8EEhr23yEmJbS083mjQE/edit?usp=sharing) spreadsheet.

# Install

# Installing

```
$ docker-compose build
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
$ prod.sh
```
