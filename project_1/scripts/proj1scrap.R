library(tidyverse)

UMD_df = read_tsv("~/Documents/611/bios611-projects-fall-2019-b-phung/project_1/data/UMD_Services_Provided_20190719.tsv",
                  col_types = cols(Field1 = col_character(),
                                   Field2 = col_character(),
                                   Field3 = col_character())) %>%
  mutate(formatted.date = as.Date(Date, "%m/%d/%Y")) %>%
  arrange(formatted.date, `Client File Number`) %>%
  mutate(year = as.numeric(format(formatted.date, "%Y"))) %>%
  mutate(decade = year - (year %% 10))
  
  
unique.clients = UMD_df %>%
  group_by(`Client File Number`, decade) %>%
  summarize(visits=n())
unique.clients %>%
  ggplot(aes(visits)) +
    geom_histogram(binwidth = 1) +
    facet_wrap(~decade)

#limit to decades frmo 1990s to 2010s
unique.clients %>%
  filter(1990 <= decade & decade <= 2010) %>%
  filter(10 <= visits & visits <= 50) %>%
  ggplot(aes(visits)) +
    geom_histogram(binwidth = 1) +
    facet_wrap(~decade)

annual_summary = UMD_df %>%
  group_by(year) %>%
  summarize(n(),
            sum(`Bus Tickets (Number of)`, na.rm = T),
            sum(`Food Provided for`, na.rm = T),
            sum(`Food Pounds`, na.rm = T),
            sum(`Clothing Items`, na.rm = T),
            sum(`Diapers`, na.rm = T),
            sum(`School Kits`, na.rm = T),
            sum(`Diapers`, na.rm = T),
            sum(`Clothing Items`, na.rm = T),
            sum(`Financial Support`, na.rm = T))

many.visits = UMD_df %>%
  group_by(`Client File Number`) %>%
  summarize(visits=n()) %>%
  filter(visits >= 10)

unique.clients.year = UMD_df %>%
  filter(1996 <= year & year <= 2019) %>%
  group_by(`Client File Number`, year) %>%
  summarize(visits=n())
unique.clients.year %>% ggplot(aes(visits)) +
  geom_histogram(binwidth = 1) +
  facet_wrap(~year)

unique.clients.decade = UMD_df %>%
  filter(1996 <= year & year <= 2019) %>%
  # filter(10 <= visits & visits <= 50)
  group_by(`Client File Number`, decade) %>%
  summarize(visits=n())
unique.clients.decade %>% ggplot(aes(visits)) +
  geom_histogram(binwidth = 1) +
  facet_wrap(~decade)

year.filtered.UMD %>%
  left_join(visits.by.client, "Client File Number") %>%
  select(year, visits.bin) %>%
  table() %>%
  prop.table(1) %>%
  knitr::kable(digits=2)


tenure %>%
  ggplot(aes(x = visit.count, y = food)) +
  geom_point()


mutate(decade = year - (year %% 10)) # Possibly ended up not using this

# known aid received
# tally missings of each column
# investigate how frequency of "low time" visitors have changed
# can filter by date: filter(formatted.date == "2011-09-06" | formatted.date == "2013-11-07") %>%
# https://ggplot2.tidyverse.org/reference/geom_histogram.html