# osTicket System

## Pre-requirements

Download osTicket source from [osticket.com](https://osticket.com/download/)

Link: https://osticket.com/download/

## Run osTicket

**Step 01: Git clone this repository**

SSH

```shell

git clone git@github.com:hoangbeard/osticket.git
cd osticket
```

or HTTPS

```shell

git clone https://github.com/hoangbeard/osticket.git
cd osticket
```

**Step 02: Copy the previously downloaded osTicket zip file to `osticket` folder**

```shell

cp -r /path/to/osTicket.zip .
```

| Note: Correct path to `osticket.zip` file before running the command above.

**Step 03: Run osTicket installation**

```shell

make install
```

**Step 04: Access osTicket via browser**

Link: http://localhost

**Step 05: Follow the installation guide**

Setup DB connection, admin account, etc.

| Note: Default parameters (refer to `docker-compose.yml` file, also refer to `.env` file for more details)

db host: `db` 
db name: `osticket`
db user: `osticket`
db password: `osticketpass`

**Step 06: Finish installation by run the following command to clean up the setup files**

```shell

make clean-setup
```

## Stop

**Stop osTicket container**

```shell

make stop
```

**Remove container and keep data**

```shell

make uninstall
```

## Clean up

```shell

make clean
```

If you want to remove osTicket database data, run the following command:

```shell

sudo rm -rf osticket_data/
```
