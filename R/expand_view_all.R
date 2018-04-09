expand_view_all <- function(view_all_trips_people_meetings_venues, people){
  view_all_trips_people_meetings_venues <- 
    view_all_trips_people_meetings_venues %>%
    # Create a "meeting with" column
    mutate(meeting_with = meeting_person_short_names,
           meeting_person_name = meeting_person_short_names,
           coincidence_person_name = meeting_person_short_names) %>%
    # Create a "person_name" column
    mutate(person_name = short_name) %>%
    # get whether the coincidence person is wbg too
    left_join(people %>%
                dplyr::select(person_id, is_wbg) %>%
                dplyr::rename(meeting_person_ids = person_id,
                              coincidence_is_wbg = is_wbg) %>%
                mutate(meeting_person_ids = as.character(meeting_person_ids)),
              by = 'meeting_person_ids')
  return(view_all_trips_people_meetings_venues)
}