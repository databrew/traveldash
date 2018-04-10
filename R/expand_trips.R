# Get all "events" - which are any period in which someone is at a place continuously
expand_trips <- function(view_all_trips_people_meetings_venues, venue_types, venue_events, cities){
  
  # Only operate on actual data
  ok <- FALSE
  if(!is.null(view_all_trips_people_meetings_venues)){
    if(nrow(view_all_trips_people_meetings_venues) > 0){
      ok <- TRUE
    }
  }
  
  if(ok){
    # Get all the necessary info
    all_data <- view_all_trips_people_meetings_venues %>%
      dplyr::select(event_title,
                    event_start_date,
                    event_end_date,
                    display_flag,
                    venue_id,
                    venue_name,
                    meeting_person_ids,
                    meeting_person_organization,
                    meeting_person_short_names,
                    short_name, organization) %>%
      # Get venue information
      left_join(venue_events %>%
                  dplyr::select(venue_type_id,
                                venue_city_id,
                                venue_id),
                by = 'venue_id') %>%
      left_join(venue_types,
                by = 'venue_type_id') %>%
      # filter(is_temporal_venue) %>%
      dplyr::select(-is_temporal_venue) %>%
      dplyr::select(- venue_type_id) %>%
      left_join(cities %>% dplyr::select(city_id, city_name), by = c('venue_city_id' = 'city_id')) %>%
      dplyr::select(-venue_city_id) %>%
      dplyr::filter(display_flag)
    
    # Create an id
    all_data <- all_data %>%
      mutate(dummy = paste0(event_title, venue_id)) %>%
      mutate(id = as.numeric(factor(dummy))) %>%
      dplyr::select(-dummy) %>%
      ungroup
    
    # Get a group of just events
    just_events <- all_data %>%
      group_by(id) %>%
      summarise(start = dplyr::first(event_start_date),
                end = dplyr::first(event_end_date),
                title = dplyr::first(venue_name),
                city_name = dplyr::first(city_name),
                content = paste0(dplyr::first(event_title), ' at ', 
                                 dplyr::first(city_name),
                                 ': ',
                                 oleksiy_date(dplyr::first(event_start_date),
                                              dplyr::last(event_end_date)))) %>%
      ungroup %>%
      mutate(group = 1,
             type = 'range',
             subgroup = id)
    
    # Get a group of just meetings
    just_meetings <- all_data %>%
      mutate(meeting_person_short_names = ifelse(meeting_person_short_names == short_name, 
                                                 NA, meeting_person_short_names)) %>%
      mutate(subgroup = id) %>%
      mutate(id = 1:nrow(all_data),
             start = event_start_date,
             end = event_end_date,
             title = paste0(short_name, ifelse(!is.na(meeting_person_short_names), ' and ', ''), 
                            ifelse(!is.na(meeting_person_short_names), meeting_person_short_names, '')),
             content = paste0(short_name,
                              ifelse(!is.na(organization),
                                     paste0(' (', organization),
                                     ''),
                              ifelse(!is.na(organization),
                                     ')',
                                     ''),
                              ifelse(!is.na(meeting_person_short_names), ' with ', ''),
                              ifelse(!is.na(meeting_person_short_names), meeting_person_short_names, ''))) %>%
      mutate(group = 2,
             type = 'point')
    just_meetings <- just_meetings[,names(just_meetings) %in% names(just_events)]
    
    # Combine them all
    df <- bind_rows(just_events, just_meetings)
    df$id <- 1:nrow(df)
    cols <- colorRampPalette(brewer.pal(8, 'Dark2'))(length(unique(df$subgroup)))
    cols_light <- adjustcolor(cols, alpha.f = 0.6)
    df$style <- ifelse(df$group == 2,
                       paste0('color: ', cols[df$subgroup], ';'),
                       paste0('background-color:', cols_light[df$subgroup], ';'))
    df <- df %>% arrange(start, city_name, content)
    # Make 23 hour event for those which are events
    df$start <- as.POSIXct(df$start)
    df$end <- as.POSIXct(df$end)
    df$end[df$group == 1] <- df$end[df$group == 1] + hours(22)
    df$event_id <- df$subgroup
    return(df)
  } else {
    return(NULL)
  }
 
}
