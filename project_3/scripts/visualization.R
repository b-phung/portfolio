library(tidyverse)

# import data wrangled from python
zip2 = read_csv('data/zip.csv') 
zip2$ZC = as.character(zip2$ZC)

year2 = read_csv('data/year.csv')

hpi2 = read_csv('data/hpi_wrangled.csv')
hpi2$HPI = as.numeric(hpi2$HPI)

# Create main dataset by adding columns for the year during the given visit and HPI for the given year and ZIP code.
main = zip2 %>%
  left_join(year2, by = "EE UID") %>%
  left_join(hpi2, by = c("year" = "Year", "ZC" = "Five-Digit ZIP Code")) %>%
  drop_na() %>%
  group_by(`Client ID`) %>% 
  slice(1)   
# Note: here I make the choice to only count the first visit if a client visits multiple times,
# so as to not overrepresent ZIP codes with a lot of repeat visitors.
# However, there is an argument for not subsetting. I might explore how this affects the results.


# There are 278 unique ZIP codes, so to limit how many to plot,
# we can choose those that had at least some threshold (e.g. 15 here) clients.
length(unique(main$ZC))
min_visits = 15
# Here, I want to get an idea what the HPI is like for each ZIP code and how that might
# relate to the number of visitors UMD gets from each of them (the label at the top of each ZC).
main2 = main %>% group_by(ZC) %>% mutate(ZCcounts=n()) %>% filter(ZCcounts >= min_visits)
plot_violin = main2 %>%
  ggplot(aes(factor(ZC), HPI)) +
  geom_violin(scale = "count") +
  geom_text(aes(x=factor(ZC), y=max(HPI)+25, label=ZCcounts)) +
  xlab('ZIP Code') +
  ylab('Housing Price Index') +
  ggtitle('ZIP Codes that had >=15 visitors and violin plots of their HPI')
plot_violin
ggsave("results/plot_violin.png", width = 16/2, height = 9/2)
# Note that UMD is located in 27701.
# 276**s are in Raleigh.
# Besides from these, and 27713, 27701 is directly adjacent all the ZIP codes.

top = c(27603,27610,27701,27703,27704,27705,27707,27713)

main3 = main2 %>% group_by(ZC, year) %>% mutate(ZCyearcounts=n())

# Might be better to take a single ZIP code at a time and panel them together later.
plot_hpi = main3 %>% ggplot(aes(year, HPI, group=ZC)) +
  geom_line(aes(color=ZC)) +
  ylab('Housing Price Index') +
  ggtitle('HPI over years grouped by ZIP Code')
plot_hpi
ggsave("results/plot_hpi.png", width = 16/4, height = 9/2)

plot_visits = main3 %>% ggplot(aes(year, ZCyearcounts, group=ZC)) +
  geom_line(aes(color=ZC)) +
  ylab('visits') +
  ggtitle('Visits over years grouped by ZIP Code')
plot_visits
ggsave("results/plot_visits.png", width = 16/4, height = 9/2)


# Part 2
# adapted from https://stackoverflow.com/a/47608134
# Installing all these packages and cloning down the files might be a pain, so feel free to skip this part.
# Docker and Make should streamline this part but I haven't gotten to it yet.
library(rgdal)
library(rgeos)
library(maptools)
library(ggalt)
library(ggthemes)

# generate a list of the ZIP codes we are interested in
raleigh.durham <- c(seq(from=27701, to=27722), 
                    seq(from=27601, to = 27699))

mydata <- readOGR(dsn = "./data/cb_2018_us_zcta510_500k", layer = "cb_2018_us_zcta510_500k")
mydata <- readOGR(dsn = "./data/cb_2018_us_zcta510_500k", layer = "cb_2018_us_zcta510_500k")
mypoly <- subset(mydata, ZCTA5CE10 %in% raleigh.durham)
mymap <- fortify(mypoly)
plot(mypoly)


latlong = read_csv("https://gist.githubusercontent.com/erichurst/7882666/raw/5bdc46db47d9515269ab12ed6fb2850377fd869e/US%2520Zip%2520Codes%2520from%25202013%2520Government%2520Data")
main4 = main2 %>% select(ZC, ZCcounts) %>% unique() %>%
  left_join(latlong, by = c("ZC" = "ZIP"))
mypoly.df <- as(mypoly, "data.frame") %>%
  left_join(main4, by = c("ZCTA5CE10" = "ZC"))

# plot each polygon along with ZIP code and number of visits
plot_map = ggplot() +
  geom_cartogram(data = mymap, aes(x = long, y = lat, map_id = id), map = mymap, fill="white", color="black", size=.05) +
  geom_text(data = mypoly.df, aes(label = ZCTA5CE10, x = LNG, y = LAT), size = 1.5, nudge_y = .005) +
  geom_text(data = mypoly.df, aes(label = ZCcounts, x = LNG, y = LAT), size = 1.5, nudge_y = -.005, color = "red") +
  theme_map() +
  coord_map() +
  ggtitle("Map of ZIP Codes Durham and Raleigh with >=15 Visitors Labeled")
plot_map
ggsave("results/plot_map.png", width = 16/2, height = 9/2)
