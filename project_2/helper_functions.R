library(tidyverse)

# wrangle UMD data set
UMD = read_tsv("data/UMD_Services_Provided_20190719.tsv") %>%
  select(`Client File Number`, Date) %>%
  mutate(formatted.date = as.Date(Date, "%m/%d/%Y")) %>%
  mutate(year = as.numeric(format(formatted.date, "%Y"))) %>%
  filter(1996 <= year & formatted.date <= "2019-07-19") %>%
  mutate(year.month = cut(formatted.date, breaks = "month"))

# wrangle unemployment data set
unemp = read_csv("data/employment.csv") %>%
  gather(Jan:Dec, key = "Month", value = "unemployment_rate") %>%
  mutate(year.month = as.Date(paste(Year, Month, "01", sep = "-"), format = "%Y-%b-%d")) %>%
  arrange(year.month) %>%
  select(-Year, -Month) %>%
  mutate(panel = "Durham unemployment rate (%)") %>%
  mutate(visits = NA)

# derive visit summary grouped by `Client File Number`
summary = read_tsv("data/UMD_Services_Provided_20190719.tsv") %>%
  mutate(formatted.date = as.Date(Date, "%m/%d/%Y")) %>%
  mutate(year = as.numeric(format(formatted.date, "%Y"))) %>%
  filter(1996 <= year & formatted.date <= "2019-07-19") %>%
  group_by(`Client File Number`) %>%
  summarize(`Visit Count` = n(),
            `First Visit` = min(formatted.date),
            `Last Visit` = max(formatted.date),
            `Bus Tickets` = sum(`Bus Tickets (Number of)`, na.rm = T),
            `Food-Persons` = sum(`Food Provided for`, na.rm = T),
            `Food Pounds` = sum(`Food Pounds`, na.rm = T),
            `Clothing Items` = sum(`Clothing Items`, na.rm = T),
            `Diapers` = sum(`Diapers`, na.rm = T),
            `School Kits` = sum(`School Kits`, na.rm = T),
            `Hygiene Kits` = sum(`Hygiene Kits`, na.rm = T),
            `Financial Support` = sum(`Financial Support`, na.rm = T))

# derive a vector of client IDs
client.list = pull(summary, `Client File Number`)
# conditional to proceed with a valid ID, display aggregate for ID == 0, give an error otherwise
plot.unemp.visits = function(ID){
  if (ID %in% client.list) {
    UMD2 = UMD %>%
      filter(`Client File Number` == ID) %>%
      group_by(year.month) %>%
      summarize(visits = n()) %>%
      mutate(year.month = as.Date(year.month)) %>%
      mutate(panel = "visit frequency") %>%
      mutate(unemployment_rate = NA)
  } else if (ID == 0){
    UMD2 = UMD %>%
      group_by(year.month) %>%
      summarize(visits = n()) %>%
      mutate(year.month = as.Date(year.month)) %>%
      mutate(panel = "Visit count") %>%
      mutate(unemployment_rate = NA)
  } else {
    stop(as.character("Invalid value for `Client File Number`. No output created."))
  }

# truncate the x-axis to a month before and after the first and last dates respectively
date.lim = c(as.Date(cut(min(UMD2$year.month) - 1, "month")), as.Date(cut(max(UMD2$year.month) + 31, "month")))
# I had wanted to have minor breaks of 3 months but I couldn't get them to properly align
# The next line is something I tried with a lubridate function but I couldn't get them to work either.
# date.lim = as.Date(c(lubricate::floor_date(min(UMD2$year.month), "year"), lubridate::ceiling_date(min(UMD2$year.month), "year")))

# show month-by-month labels if time frame is small enough
# omit if too large
if (max(UMD2$year.month) - min(UMD2$year.month) <= 730) {
  minbr = waiver()
  majbr = "1 month"
} else {
  minbr = "1 months"
  majbr = "1 year"
}

# https://stackoverflow.com/q/3099219 and
# https://github.com/tidyverse/ggplot2/wiki/Align-two-plots-on-a-page
# a workaround to avoid having more than one y-axes 
panel = rbind(UMD2, unemp)
panel %>%
  ggplot(mapping = aes(x = year.month, y = visits)) + 
  facet_grid(panel~., scale="free") + 
  geom_bar(data = UMD2, stat = "identity") + 
  geom_line(data = unemp, mapping=aes(y = unemployment_rate)) +
  scale_x_date(date_breaks = majbr, minor_breaks = minbr, date_labels = "%Y-%m", limits = date.lim) +
  # next line of code sourced from https://stackoverflow.com/a/39877048 to force integer values on the y-axis 
  scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1))))) +
  xlab("year") +
  ylab("")
}
