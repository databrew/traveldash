check_user_name_and_password <- function(user_name = '',
                                         password = '',
                                         users){
  # Subset for only the correct user name
  users <- users %>% filter(user_role == user_name)
  if(nrow(users) > 1){
    stop('There are two users with user name: ', user_name, '. This needs to be fixed in the database.')
  }
  if(nrow(users) == 0){
    message('Log-in attempted for an inexistant user: ', user_name)
    return(0)
  }
  # See if password is correct
  password_correct <- users$user_password == password
  if(!password_correct){
    message('Incorrect password provided for ', user_name)
    return(0)
  } else {
    uid <- users$user_id
    message('Correct password provided for ', user_name, '. Logging in as user id: ', uid)
    return(uid)
  }

}