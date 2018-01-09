# The below installs the nd3 package from the local build.
# This is suitable for a case in which one cannot install from github (due to permissions, etc.).
# However, this is not suitable for publishing to shinyapps.io, which requires packages
# to be on github, bitbucket or cran.
# If publishing through rsconnect, do not run this script. Instead, run
# devtools::install_github('databrew/nd3')
if(require(nd3)){
  remove.packages('nd3')
}
library(devtools)
document('nd3')
install('nd3')
