# TRAVELDASH
A travel dashboard for the IFC / World Bank

# Developer's instructions

_The below assumes ubuntu 16.04_

## Data source

This application uses either a PostgreSQL database or a google sheet as the data source. Whether to use one or the other is defined in the `use_google` option in the first few lines of `global.R`. In production, this app will use the database; the purpose of the google sheets option is to allow for deploying to shinyapps.io. This application allows for modification of the underlying data; changes made in one "mode" (ie, `use_google` set to `TRUE`) will not affect the data in the other mode (ie, the database).

## Packages

- This package requires a non-standard installation of `networkD3`. Prior to running the application, install `nd3` by running `devtools::install_github('databrew/nd3').

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

### Setting up the development database

The development database is resembles the production database, but is named `dev` rather than `ARL`. To set up the database from scratch, take the following steps:

- Create a database named "ARL" by entering into an interactive PostgreSQL session (`psql`) and then running the following: `CREATE DATABASE "dev";`
- Connect to the database: `\connect dev;`
- Create a `pd_wbgtravel` schema: `create schema pd_wbgtravel;`
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

- To ensure that the database upload worked correctly, run the `upload_raw_data.R` script.

### SQLite

AS an alternative to PostgreSQL, we use SQLite for quick testing, development iterations, and deployment to shinyapps.io. Below are the instructions for setting up the app database for use with SQLite.

```
(Not done)
```