# TRAVELDASH
A travel dashboard for the IFC / World Bank

# Developer's instructions

_The below assumes ubuntu 16.04_

## Data source

This application uses either a PostgreSQL database or a google sheet as the data source. Whether to use one or the other is defined in the `use_google` option in the first few lines of `global.R`. In production, this app will use the database; the purpose of the google sheets option is to allow for deploying to shinyapps.io. This application allows for modification of the underlying data; changes made in one "mode" (ie, `use_google` set to `TRUE`) will not affect the data in the other mode (ie, the database).

## Packages

- This package requires a non-standard installation of `networkD3`. Prior to running the application, install `nd3` by running `devtools::install_github('databrew/nd3').
- Note that proper functioning of the `tmap` package requires gdal 2.01 or greater. For installation, see this [SO thread](https://stackoverflow.com/questions/37294127/python-gdal-2-1-installation-on-ubuntu-16-04).

## Credentials set-up

To use this app with database functionality, you'll note to provide database information and credentials. You'll note a `credentials/credentials.yaml` file. This is set up to assume an accessible, non-password protected "arl" database. If your database requires credentials, is running on a specific port, etc, add to the file in this format:

```
dbname: arl
host: "w0lxsfigssa01"
port: 5432
user: "rscript"
password: <ENTER CORRECT PASSWORD HERE>
```

The above arguments should reflect any and all argments that one might pass to the `dbConnect` function.

## Database set-up

To run the app locally, you must have a PostgreSQL database running. This database should be named `arl`, have a schema named `pd_wbgtravel`, and have a table named `dev_events`. Here's how to create that from scratch.

- Create a database named "arl" by entering into an interactive PostgreSQL session (`psql`) and then running the following: `CREATE DATABASE arl;`
- Connect to the database: `\connect arl;`
- Create a `pd_wbgtravel` schema: `create schema pd_wbgtravel;`
- Set the search path for the schema: `SET search_path TO pd_wbgtravel;`
- Ctrl+d to get out of interactive psql session.
- Run the code in `R/populate_dev_events.R` in order to populate the `dev_events` table.
- Enter the `arl` database in an interactive psql session: `psql arl`.
- Confirm that the table is there: `\dt` should return:

```
           List of relations
 Schema |    Name    | Type  |  Owner  
--------+------------+-------+---------
 public | dev_events | table | joebrew

```
