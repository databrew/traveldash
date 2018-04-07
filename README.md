# TRAVELDASH
A travel dashboard for the IFC / World Bank

# Developer's instructions


## Packages

- This package requires a non-standard installation of `networkD3`. Prior to running the application, install `nd3` by running `devtools::install_github('databrew/nd3').


## Credentials set-up

To use this app with database functionality, you'll note to provide database information and credentials. You'll note a `credentials/credentials.yaml` file. This is set up to assume an accessible, non-password protected "arl" database. If your database requires credentials, is running on a specific port, etc, add to the file in this format:


*World Bank AWS copy server*

```
dbname: ARL
host: "w0lxsfigssa01"
port: 5432
user: "rscript"
password: <ENTER CORRECT PASSWORD HERE>
```

*DataBrew AWS server*

```
dbname: dev
host: "databrewdb.cfejspjhdciw.us-east-2.rds.amazonaws.com"
user: "worldbank"
port: 8080
password: <ENTER CORRECt PASSWORD HERE>
```


The above arguments should reflect any and all argments that one might pass to the `dbConnect` function.


## Copy data from AWS to local

### From RDS (already running database)


- Create a dump from WB AWS RDS endpoint:
```
pg_dump -h figssamel1.cosjv4zx2mww.us-east-1.rds.amazonaws.com -U postgres -f ~/Desktop/dump.sql dev
```

### From EC2 (on-demand copy)

- SSH into the WB EC2 instance
```
ssh jbrew@34.236.109.104
```

- Use sudo as postgres:
```
sudo su - postgres
```

- Go into the directory where the backup script is:
```
cd /var/lib/postgresql/scripts
```

- Run the backup script:
```
./rds-download-and-restore-ARL-db.sh
```

- Generate a dump of the databases:
```
pg_dump ARL > arl_backup.sql;
pg_dump dev > dev_backup.sql
```

- Exit the SSH session, and - locally - use `scp` to copy the backups locally
```
scp ssh jbrew@34.236.109.104:/var/lib/postgresql/scripts/arl_backup.sql ~/Desktop/.
scp ssh jbrew@34.236.109.104:/var/lib/postgresql/scripts/dev_backup.sql ~/Desktop/.
```


## Copy data from local to AWS

- Create a local dump of the pd_wbgtravel schema. The below writes the contents of the local `dev_local` database's `pd_wbgtravel` schema to a file named `dev.sql`:
```
pg_dump -d dev_local -n pd_wbgtravel -f dev.sql
```

- Open a psql session within our AWS DB instance.
```
psql --host=databrewdb.cfejspjhdciw.us-east-2.rds.amazonaws.com --port=8080 --username=worldbank --dbname=dev 
```

- Restore a locally created dump from within psql
``` 
\i dev.sql
```

## Privileges

One might find that there are permissions/privileges issues on newly created tables and schemas. In this case, consider the below:

- Use the code in `grant_privileges.sql` to grant privileges to the `worldbank` user (password in credentials file).

- Or grant privileges like:

```
create role worldbank with password '<PASSWORD HERE>' login;
grant rds_superuser to worldbank;
GRANT ALL PRIVILEGES ON SCHEMA pd_wbgtravel TO worldbank;
GRANT ALL PRIVILEGES ON SCHEMA public TO worldbank;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO worldbank;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA pd_wbgtravel TO worldbank;
```

