make_hot_venue_events <- function(data, venues = FALSE, cities){
  df <- data %>%
    dplyr::select(venue_type_id,
                  venue_city_id,
                  event_title,
                  event_start_date,
                  event_end_date,
                  display_flag,
                  venue_id,
                  venue_name) %>%
    left_join(venue_types,
              by = 'venue_type_id') %>%
    # filter(is_temporal_venue) %>%
    dplyr::select(-is_temporal_venue) %>%
    dplyr::select(- venue_type_id) %>%
    left_join(cities %>% dplyr::select(city_id, city_name), by = c('venue_city_id' = 'city_id')) %>%
    dplyr::select(-venue_city_id) %>%
    arrange(desc(event_start_date))
  if(venues){
    df <- df %>%
      mutate(event_title = venue_name) %>%
      dplyr::select(-venue_name) %>%
      dplyr::rename(venue_name = event_title)
  } else {
      df <- df %>%
        filter(!is.na(event_title),
               event_title != '') %>%
        dplyr::select(-venue_name)
      df <- df %>%
        dplyr::select(type_name, event_title, city_name, event_start_date, event_end_date, display_flag, venue_id)
      
    }
  return(df)
}