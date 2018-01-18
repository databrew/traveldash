#' Create a calendar plot
#'
#' Create a ggplot calendar object
#' @param dates
#' @param fills
#' @return A data table ready for inclusion into an HTML context (shiny / rmd)
#' @import googleVis
#' @import ggplot2
#' @export


# Calendar, modified from https://github.com/jayjacobs/ggcal/blob/master/R/ggcal.R
gg_cal <- function(dates, fills) {
  # get ordered vector of month names
  months <- format(seq(as.Date("2016-01-01"), as.Date("2016-12-01"), by="1 month"), "%B")
  
  # get lower and upper bound to fill in missing values
  mindate <- as.Date(format(min(dates), "%Y-%m-01"))
  maxdate <- (seq(as.Date(format(max(dates), "%Y-%m-01")), length.out = 2, by="1 month")-1)[2]
  # set up tibble with all the dates.
  filler <- tibble(date = seq(mindate, maxdate, by="1 day"))
  
  t1 <- tibble(date = dates, fill=fills) %>%
    right_join(filler, by="date") %>% # fill in missing dates with NA
    mutate(dow = as.numeric(format(date, "%w"))) %>%
    mutate(month = format(date, "%B")) %>%
    mutate(woy = as.numeric(format(date, "%U"))) %>%
    mutate(year = as.numeric(format(date, "%Y"))) %>%
    mutate(month = factor(month, levels=months, ordered=TRUE)) %>%
    arrange(year, month) %>%
    mutate(monlabel=month)
  
  if (length(unique(t1$year))>1) { # multi-year data set
    t1$monlabel <- paste(t1$month, t1$year)
  }
  
  t2 <- t1 %>%
    mutate(monlabel = factor(monlabel, ordered=TRUE)) %>%
    mutate(monlabel = fct_inorder(monlabel)) %>%
    mutate(monthweek = woy-min(woy),
           y=max(monthweek)-monthweek+1)
  
  weekdays <- c("S", "M", "T", "W", "T", "F", "S")
  ggplot(t2, aes(dow, y, fill=fill)) +
    geom_tile(color="gray80") +
    facet_wrap(~monlabel, ncol=4, scales="free") +
    scale_x_continuous(expand=c(0,0), position="top",
                       breaks=seq(0,6), labels=weekdays) +
    scale_y_continuous(expand=c(0,0)) +
    theme(panel.background=element_rect(fill=NA, color=NA),
          strip.background = element_rect(fill=NA, color=NA),
          strip.text.x = element_text(hjust=0, face="bold"),
          # legend.title = element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_blank(),
          axis.text.y = element_blank(),
          strip.placement = "outsite")
}
