# Get all "events" - which are any period in which someone is at a place continuously
expand_trips <- function(trips, cities, people, view_all_trips_people_meetings_venues){
  out <- list()
  for(i in 1:nrow(trips)){
    dates <- seq(trips$trip_start_date[i],
                 trips$trip_end_date[i],
                 by = 1)
    df <- trips[i,] %>% dplyr::select(trip_id, person_id, city_id, trip_uid)
    df1 <- df
    while(length(dates) > nrow(df)){
      df <- bind_rows(df, df1)
    }
    df$date <- dates
    out[[i]] <- df
  }
  df <- bind_rows(out)
  # Bring in venue
  df <- left_join(df,
                  view_all_trips_people_meetings_venues %>%
                    group_by(trip_uid) %>%
                    summarise(venue_name = dplyr::first(venue_name)) %>%
                    ungroup,
                  by = 'trip_uid')
  
  # Get rid of dulicates
  df <- df %>% dplyr::distinct(city_id, date,
                               venue_name) %>%
    arrange(city_id, date)
  # Get gap between previous days
  df <- df %>%
    group_by(city_id,venue_name) %>%
    mutate(date_dif = date - dplyr::lag(date, 1)) %>% ungroup
  # Get a "event_id"
  df$event_id <- NA
  df$event_id[1] <- 1
  for(i in 2:nrow(df)){
    df$event_id[i] <- 
      ifelse(any(is.na(df$date_dif[i]), df$date_dif[i] > 1),
             df$event_id[i-1] + 1,
             df$event_id[i-1])
  }
  # Group by event id and get start / end
  old_df <- df
  df <- df %>%
    group_by(city_id, event_id) %>%
    summarise(start = min(date),
              end = max(date)) %>%
    ungroup
  # Get the cities (events)
  df <- left_join(df,
                  cities %>% 
                    dplyr::select(city_id, city_name),
                  by = 'city_id')
  # Get the event into
  df <- left_join(df, old_df, by = c('city_id', 'event_id'))
  
  # Remove non-event stuff
  df <- df %>% dplyr::filter(!is.na(venue_name) & venue_name != '' & venue_name != 'Unspecified Venue')
  
  # Make a content variale
  df <- df %>%
    mutate(content = ifelse(!is.na(venue_name) & venue_name != '',
                            venue_name,
                            city_name)) %>%
    mutate(content = ifelse(content == 'Unspecified Venue',
                            paste0('Unspecified event in ', city_name),
                            content))
  
  
  
  # Keep only one observation for each event
  df <- df %>%
    dplyr::distinct(city_id, event_id, start, end, city_name, content, .keep_all = TRUE)
  # Remove those with nothing
  df <- df %>%
    mutate(type = 'range',
           title = content) %>%
    mutate(group = 1)
  # Get the meetings in each event
  meetings <- view_all_trips_people_meetings_venues %>%
    dplyr::select(person_id, city_id, trip_group,
                  trip_start_date,
                  trip_end_date,
                  short_name,
                  agenda) %>%
    dplyr::mutate(content = paste0(short_name, 
                                   ifelse(!is.na(agenda) & agenda != '',
                                          ': ',
                                          ''), agenda)) %>%
    left_join(df %>% dplyr::select(-content,
                                   -type)) %>%
    # Keep only those dates which fall in the range
    filter(trip_start_date >= start,
           trip_end_date <= end) %>%
    mutate(group = 2) %>%
    mutate(type = 'point')
  meetings <- meetings[,names(df)]
  # Combine everything
  df <- bind_rows(df, meetings)
  df$id <- 1:nrow(df)
  df$subgroup <- df $event_id
  cols <- colorRampPalette(brewer.pal(8, 'Dark2'))(length(unique(df$subgroup)))
  df$style <- paste0('color: ', cols[df$subgroup], ';')
  df <- df %>% arrange(start, city_name)
  # Make 23 hour event for those which are events
  df$start <- as.POSIXct(df$start)
  df$end <- as.POSIXct(df$end)
  df$end[df$group == 1] <- df$end[df$group == 1] + hours(23)
  return(df)
}
