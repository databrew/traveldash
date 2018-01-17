# TRAVELDASH
A travel dashboard for the IFC / World Bank

# Developer's instructions

## Packages

- This package requires a non-standard installation of `networkD3`. Prior to running the application, install `nd3` by running `devtools::install_github('databrew/nd3').
- Package versions and sources used for this app are at the bottom of this document.

## Credentials set-up

## Database set-up

To run the app locally, you must have a PostgreSQL database running. This database should be named `arl`, have a schema named `pd_wbgtravel`, and have a table named `dev_events`. Here's how to create that from scratch.

- Create a database named "arl" by entering into an interactive PostgreSQL session (`psql`) and then running the following: `CREATE DATABASE arl;`
- Connect to the database: `\connect ARL;`
- Create a `pd_wbgtravel` schema: `create schema pd_wbgtravel;`
- Set the search path for the schema: `SET search_path TO pd_wbgtravel;`
- Ctrl+d to get out of interactive psql session.
- 
- CREATE SOME TABLE IN THE DATABASE

- Confirm that the table is there: `\dt` should return:

```
SOME STUFF HERE
```



## Package versions

```
        package  version source
             BH 1.65.0-1   CRAN
            DBI      0.7   CRAN
             DT      0.2   CRAN
     DiagrammeR    0.9.2   CRAN
        Formula    1.2-2   CRAN
          Hmisc    4.0-3   CRAN
           MASS   7.3-48   CRAN
         Matrix   1.2-12   CRAN
             R6    2.2.2   CRAN
   RColorBrewer    1.1-2   CRAN
           Rcpp  0.12.14   CRAN
           Rook    1.1-1   CRAN
            XML 3.98-1.9   CRAN
        acepack    1.4.1   CRAN
     assertthat    0.2.0   CRAN
      backports    1.1.2   CRAN
      base64enc    0.1-3   CRAN
          bindr      0.1   CRAN
       bindrcpp      0.2   CRAN
           brew    1.0-6   CRAN
          broom    0.4.3   CRAN
          callr    1.0.0   CRAN
     cellranger    1.1.0   CRAN
      checkmate    1.8.5   CRAN
            cli    1.0.0   CRAN
          clipr    0.4.0   CRAN
        cluster    2.0.6   CRAN
     colorspace    1.3-2   CRAN
         crayon    1.3.4   CRAN
      crosstalk    1.0.0   CRAN
           curl      3.1   CRAN
     data.table 1.10.4-3   CRAN
      data.tree    0.7.3   CRAN
         dbplyr    1.1.0   CRAN
      dichromat    2.0-0   CRAN
         digest   0.6.13   CRAN
     downloader      0.4   CRAN
          dplyr    0.7.4   CRAN
       evaluate   0.10.1   CRAN
        forcats    0.2.0   CRAN
        foreign   0.8-69   CRAN
        ggplot2    2.2.1   CRAN
           glue    1.2.0   CRAN
      googleVis    0.6.2   CRAN
      gridExtra      2.3   CRAN
         gtable    0.2.0   CRAN
          haven    1.1.0   CRAN
          highr      0.6   CRAN
            hms    0.4.0   CRAN
      htmlTable   1.11.1   CRAN
      htmltools    0.3.6   CRAN
    htmlwidgets      0.9   CRAN
         httpuv    1.3.5   CRAN
           httr    1.3.1   CRAN
         igraph    1.1.2   CRAN
     influenceR    0.1.0   CRAN
          irlba    2.3.1   CRAN
       jsonlite      1.5   CRAN
          knitr     1.18   CRAN
       labeling      0.3   CRAN
        lattice  0.20-35   CRAN
   latticeExtra   0.6-28   CRAN
       lazyeval    0.2.1   CRAN
        leaflet    1.1.0   CRAN
      lubridate    1.7.1   CRAN
       magrittr      1.5   CRAN
           maps    3.2.0   CRAN
       markdown      0.8   CRAN
           mime      0.5   CRAN
         miniUI    0.1.1   CRAN
         mnormt    1.5-5   CRAN
         modelr    0.1.1   CRAN
        munsell    0.4.3   CRAN
            nd3 0.4.9000 github
           nlme  3.1-131   CRAN
           nnet   7.3-12   CRAN
        openssl    0.9.9   CRAN
        packrat  0.4.8-1   CRAN
         pillar    1.0.1   CRAN
      pkgconfig    2.0.1   CRAN
          plogr    0.1-1   CRAN
           plyr    1.8.4   CRAN
            png    0.1-7   CRAN
          psych    1.7.8   CRAN
          purrr    0.2.4   CRAN
         raster    2.6-7   CRAN
          readr    1.1.1   CRAN
         readxl    1.0.0   CRAN
        rematch    1.0.1   CRAN
         reprex    0.1.1   CRAN
       reshape2    1.4.3   CRAN
          rgexf   0.15.3   CRAN
          rlang    0.1.6   CRAN
      rmarkdown      1.8   CRAN
          rpart   4.1-11   CRAN
      rprojroot    1.3-1   CRAN
     rstudioapi      0.7   CRAN
          rvest    0.3.2   CRAN
         scales    0.5.0   CRAN
        selectr    0.3-1   CRAN
          shiny    1.0.5   CRAN
 shinydashboard    0.6.1   CRAN
        shinyjs    0.9.1   CRAN
    sourcetools    0.1.6   CRAN
             sp    1.2-5   CRAN
        stringi    1.1.6   CRAN
        stringr    1.2.0   CRAN
       survival   2.41-3   CRAN
         tibble    1.4.1   CRAN
          tidyr    0.7.2   CRAN
     tidyselect    0.2.3   CRAN
      tidyverse    1.2.1   CRAN
           utf8    1.1.2   CRAN
        viridis    0.4.0   CRAN
    viridisLite    0.2.0   CRAN
     visNetwork    2.0.2   CRAN
        whisker    0.3-2   CRAN
           xml2    1.1.1   CRAN
         xtable    1.8-2   CRAN
           yaml   2.1.16   CRAN
```