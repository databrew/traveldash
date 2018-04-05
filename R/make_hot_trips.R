make_hot_trips <- function(data, filter){
  df <-  data %>%
    dplyr::select(short_name,
                  organization,
                  title,
                  city_name,
                  country_name,
                  trip_start_date,
                  trip_end_date,
                  trip_group,
                  venue_name, 
                  meeting_person_short_names,
                  agenda,
                  trip_uid) %>%
    arrange(desc(trip_start_date)) %>%
    dplyr::rename(Person = short_name,
                  Organization = organization,
                  Title = title,
                  City= city_name,
                  Country = country_name,
                  Start = trip_start_date,
                  End = trip_end_date,
                  `Trip Group` = trip_group,
                  Venue = venue_name,
                  Meeting = meeting_person_short_names,
                  Agenda = agenda)
  if(!is.null(filter)){
    df <- df %>% search_df(filter)
  }
  return(df)
}