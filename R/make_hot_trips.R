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
  # Look for duplicates
  df <- df %>%
    arrange(Person, City, Start, End)
  df$dup <- FALSE
  for(i in 2:nrow(df)){
    same_person <- df$Person[i] == df$Person[i-1]
    same_city <- df$City[i] == df$City[i-1]
    overlapping_dates <- FALSE
    if(same_person & same_city){
      overlapping_dates <- df$Start[i] <= df$End[i-1]
    }
    if(overlapping_dates){
      df$dup[i] <- TRUE
    }
  }
  return(df)
}