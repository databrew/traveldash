check_user_name_and_password <- function(user_name = '',
                                         password = ''){
  # This needs to be populated with something which sends the arguments to the 
  # database and checks whether the log in is good or not.
  # For now, just automatically saying as good
  if(user_name == 'fail'){ # this option allows for ui testing
    return(0)
  } else {
    return(1)
  }
}