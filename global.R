library(maps)
library(tidyverse)
library(sp)

# Save events as a binary for faster loading
if('events.RData' %in% dir()){
  load('events.RData')
} else {
  # Read data from oleksiy
  events <- read_csv('from_oleksiy/Fake events data1.csv') %>%
    arrange(Person,
            Counterpart) %>%
    mutate(`Visit start` = as.Date(paste0(`Visit start`, '-2017'),
                                   format = '%d-%b-%Y'),
           `Visit end` = as.Date(paste0(`Visit end`, '-2017'),
                                 format = '%d-%b-%Y'))
  
  # Add some fake new rows
  # africa <- cism::africa; dir.create('spatial'); save(africa, file = 'spatial/africa.RData')
  load('spatial/africa.RData')
  # Major cities from https://simplemaps.com/data/world-cities
  cities <- read_csv('spatial/simplemaps-worldcities-basic.csv') %>%
    dplyr::rename(Long = lng,
                  Lat = lat) %>%
    filter(country %in% africa@data$COUNTRY) %>%
    dplyr::mutate(`City of visit` = city,
                  `Country of visit` = country,
                  Organization = base::sample(c('IFC', 'World Bank', 'ILO'),
                                              size = length(Lat),
                                              replace = TRUE,
                                              prob = c(0.2, 0.7, 0.1)))
  # Add 50 rows
  n <- 50
  new_rows <- list()
  for(i in 1:n){
    new_row <- events %>% dplyr::sample_n(1) %>%
      dplyr::select(Person, Organization)
    new_loc <- cities %>% dplyr::sample_n(1) %>%
      dplyr::select(`City of visit`, `Country of visit`, Lat, Long)
    new_row <- cbind(new_row, new_loc)
    new_row <- new_row %>%
      dplyr::mutate(Counterpart = sample(events$Counterpart, 1)) %>%
      dplyr::mutate(`Visit start` = sample(seq(as.Date('2017-01-01'),
                                               as.Date('2017-12-31'),
                                               1),
                                           1)) %>%
      mutate(`Visit end` = `Visit start` + sample(1:20, 1),
             `Visit month` = format(`Visit start`, '%B'))
    new_row <- new_row[,names(events)]
    new_rows[[i]] <- new_row
  }
  new_rows <- bind_rows(new_rows)
  events <- bind_rows(events, new_rows)
  # For now, just add the same file for every photo
  events$file <- paste0('headshots/', events$Person, '.png')
  save(events, file = 'events.RData')
}
# events <- events %>%
#   arrange(`Visit start`) %>%
#   mutate(dummy = 1) %>%
#   group_by(Person) %>%
#   mutate(id = cumsum(dummy)) %>%
#   ungroup %>%
#   dplyr::select(-dummy)
# # Ensure that there is no overlapping
# expanded <- list()
# for(i in 1:nrow(events)){
#   new_row <- data.frame(Person = events$Person[i],
#                         id = events$id[i],
#                         date = seq(events$`Visit start`[i],
#                                    events$`Visit end`[i],
#                                    1))
#   expanded[[i]] <- new_row
# }
# expanded <- bind_rows(expanded)
# expanded <- expanded %>%
#   mutate(dummy = 1) %>%
#   group_by(Person, id) %>%
#   mutate(dup = cumsum(dummy))


# Define static objects for selection
people <- sort(unique(events$Person))
organizations <- sort(unique(events$Organization))
cities <- sort(unique(events$`City of visit`))
counterparts <- sort(unique(events$Counterpart))
countries <- sort(unique(events$`Country of visit`))
months <- unique(format(seq(as.Date('2017-01-01'), as.Date('2017-12-31'), 1), '%B'))
# choices_month <- format(seq.Date(from = as.Date("2017-01-01"), 
#                                  by = "month", 
#                                  length.out = 12), "%B-%Y")
choices_month <- seq(as.Date('2017-01-01'),
                     as.Date('2017-12-31'),
                     1)
