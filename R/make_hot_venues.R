make_hot_venues <- function(data){
  df <- data %>%
    dplyr::select(venue_type_id,
                  venue_city_id,
                  display_flag,
                  venue_id,
                  venue_name) %>%
    left_join(venue_types,
              by = 'venue_type_id') %>%
    filter(!is_temporal_venue) %>%
    dplyr::select(-is_temporal_venue) %>%
    dplyr::select(- venue_type_id) %>%
    left_join(cities %>% dplyr::select(city_id, city_name), by = c('venue_city_id' = 'city_id')) %>%
    dplyr::select(-venue_city_id) %>%
    arrange(venue_name)
  return(df)
}
