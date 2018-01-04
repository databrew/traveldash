library(maps)
library(tidyverse)

# Read data from oleksiy
events <- read_csv('from_oleksiy/Fake events data1.csv') %>%
  arrange(Person,
          Counterpart) %>%
  mutate(`Visit start` = as.Date(paste0(`Visit start`, '-2017'),
                                 format = '%d-%b-%Y'),
         `Visit end` = as.Date(paste0(`Visit end`, '-2017'),
                                 format = '%d-%b-%Y'))
# For now, just add the same file for every photo
events$file <- paste0('headshots/', events$Person, '.png')

# Define static objects for selection
people <- sort(unique(events$Person))
organizations <- sort(unique(events$Organization))
cities <- sort(unique(events$`City of visit`))
counterparts <- sort(unique(events$Counterpart))
countries <- sort(unique(events$`Country of visit`))
months <- unique(format(seq(as.Date('2017-01-01'), as.Date('2017-12-31'), 1), '%B'))
date.range <- as.Date(c("2017-01-01", "2017-12-31"))
