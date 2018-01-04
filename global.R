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
events$file <- 'head_shot_small.png'

# Define static objects for selection
people <- sort(unique(events$Person))
organizations <- sort(unique(events$Organization))
cities <- sort(unique(events$`City of visit`))
counterparts <- sort(unique(events$Counterpart))
countries <- sort(unique(events$`Country of visit`))
