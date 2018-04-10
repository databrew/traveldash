make_hot_people <- function(people, person = NULL){
  if(!is.null(people)){
    if(nrow(people) > 0){
      df <- people %>%
        dplyr::select(person_id,
                      short_name,
                      title,
                      organization,
                      is_wbg)
      if(!is.null(person)){
        df <- df %>% filter(short_name == person)
      }
      if(!is.null(df)){
        if(nrow(df) > 0){
          df <- df %>% dplyr::select(-person_id) %>%
            mutate(is_wbg = ifelse(is_wbg == 1, TRUE, FALSE))
          return(df)
        }
      }
    }
  }
  
}