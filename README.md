# TRAVELDASH
A travel dashboard for the IFC / World Bank

# Developer's instructions

_The below assumes ubuntu 16.04_

## Packages

- This package requires a non-standard installation of `networkD3`. Prior to running the application, install `nd3` by running `devtools::install_github('databrew/nd3').

## Oauth set-up

Place `droptoken.rds` in the main repository. If you don't have it, request it from Joe. He generates it by running:

```
token <- drop_auth()
saveRDS(token, "droptoken.rds")
```

(Manual authentication)

## Credentials set-up

To use this app with database functionality, you'll note to provide database information and credentials. You'll note a `credentials/credentials.yaml` file. This is set up to assume an accessible, non-password protected "arl" database. If your database requires credentials, is running on a specific port, etc, add to the file in this format:

```
dbname: ARL
host: "w0lxsfigssa01"
port: 5432
user: "rscript"
password: <ENTER CORRECT PASSWORD HERE>
```

The above arguments should reflect any and all argments that one might pass to the `dbConnect` function.

## Database set-up

(The below should no longer be relevant, now that we are all using the same db on AWS)

(For using local dump sent by Soren, `devnew`)

### Setting up the development database

The development database is resembles the production database, but is named `dev` rather than `ARL`. To set up the database from scratch, take the following steps:

- Create a database named "ARL" by entering into an interactive PostgreSQL session (`psql`) and then running the following: `CREATE DATABASE "dev";`
- Connect to the database: `\connect dev;`
- Create a `pd_wbgtravel` schema: `create schema pd_wbgtravel;`
- Out of the psql console, define a function for uploading data:
```
psql -d dev -f dev_database/create_function_travel_uploads.sql
```
- Create and populate the tables by running the following: 

```
psql -d dev -f dev_database/pd_wbgtravel.sql
```
- Enter into the database again: `psql dev`
- Confirm that the tables are there: `\dt pd_wbgtravel.*` should return:

```
               List of relations
    Schema    |     Name      | Type  |  Owner  
--------------+---------------+-------+---------
 pd_wbgtravel | cities        | table | joebrew
 pd_wbgtravel | people        | table | joebrew
 pd_wbgtravel | trip_meetings | table | joebrew
 pd_wbgtravel | trips         | table | joebrew
(4 rows)
```

- To ensure that the database upload worked correctly, run the `upload_raw_data.R` script like this:

```
Rscript dev_database/upload_raw_data.R
```

- Next, create a "events" view by running the following:

```
psql -d dev -f dev_database/create_events_view.sql
```

- Next, create a view_trip_coincidences view by running the following:

```
psql -d dev -f dev_database/create_view_trip_coincidences.sql
```

- Next, create a sql function for handling uploads by running the following:

```
psql -d dev -f dev_database/create_function_travel_uploads.sql
```

- Confirm that all the views are there. Run `psql dev`, and then within the psql console, run `\dv pd_wbgtravel.*`. It should return the following:

```
                   List of relations
    Schema    |          Name          | Type |  Owner  
--------------+------------------------+------+---------
 pd_wbgtravel | events                 | view | joebrew
 pd_wbgtravel | view_trip_coincidences | view | joebrew
(2 rows)
```


## Database set-up on AWS

- Open a psql session within our AWS DB instance.
```
psql --host=databrewdb.cfejspjhdciw.us-east-2.rds.amazonaws.com --port=8080 --username=worldbank --dbname=dev 
```

Create a dump from WB AWS RDS endpoint:
```
pg_dump -h figssamel1.cosjv4zx2mww.us-east-1.rds.amazonaws.com -U postgres -f ~/Desktop/dump.sql dev
```

- Restore a locally created dump from within psql
``` 
\i /home/joebrew/Desktop/dev.sql
```

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



### SQLite

AS an alternative to PostgreSQL, we use SQLite for quick testing, development iterations, and deployment to shinyapps.io. Below are the instructions for setting up the app database for use with SQLite.

```
(Not done)
```

