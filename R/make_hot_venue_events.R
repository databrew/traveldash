make_hot_venue_events <- function(data){
  df <- data %>%
    dplyr::select(venue_type_id,
                  venue_city_id,
                  event_title,
                  event_start_date,
                  event_end_date,
                  display_flag,
                  venue_id) %>%
    left_join(venue_types %>% dplyr::select(venue_type_id,
                                            type_name),
              by = 'venue_type_id') %>%
    dplyr::select(- venue_type_id) %>%
    left_join(cities %>% dplyr::select(city_id, city_name), by = c('venue_city_id' = 'city_id')) %>%
    dplyr::select(-venue_city_id) %>%
    arrange(desc(event_start_date))
  return(df)
}