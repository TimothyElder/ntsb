library(tidyverse)
library(magrittr)
library(lubridate)
library(batR)
library(sf)

theme_set(theme_minimal())

setwd("~/Documents/ntsb")

source("scripts/functions.r")

events <- read_csv("data/events.csv")

events %>%
  count(ev_highest_injury) %>%
  ggplot(aes(x = ev_highest_injury, y = n)) +
  geom_bar(stat = "identity")

events %>%
  count(ev_year) %>%
  ggplot(aes(x = ev_year, y = n)) +
  geom_line(stat = "identity") +
  ylim(1000, 2000)

df <- events %>%
  filter(ev_highest_injury == "FATL",
         ev_state %in% state_abbreviations)

ggplot(df, aes(x = inj_tot_t)) +
  geom_density()

df %>%
  count(ev_state, ev_year) %>%
  ggplot(aes(x = ev_year, y = n, group = ev_state)) +
  geom_line() + facet_wrap(~ev_state, nrow = 10, ncol = 5)

df %>%
  count(ev_dow) %>%
  ggplot(aes(x = ev_dow, y = n)) +
  geom_bar(stat = "identity")

df %>%
  count(light_cond) %>%
  ggplot(aes(x = light_cond, y = n)) +
  geom_bar(stat = "identity")

###############################################################################
# Maps ------------------------------------------------------------------------
###############################################################################

library(mapdata)
library(usmap)

min_lat <- 24.396308
max_lat <- 49.345786
min_lon <- -125.000000
max_lon <- -66.934570

state <- geom_polygon(aes(x = long, y = lat, group = group),
                      data = map_data('state'),
                      fill = "#e3e0e0", color = "#515151",
                      size = 0.15)

pal <- brewer.pal(n = 8, name = "Set1")

maptheme <- theme(panel.grid = element_blank()) +
  theme(axis.text = element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(axis.title = element_blank()) +
  theme(legend.position = "bottom") +
  theme(panel.grid = element_blank()) +
  theme(panel.background = element_rect(fill = "white")) +
  theme(plot.margin = unit(c(0, 0, 0.5, 0), 'cm'))

df %>%
  filter(dec_latitude > min_lat, dec_latitude < max_lat,
         dec_longitude > min_lon, dec_longitude < max_lon) %>%
  ggplot() + state + coord_fixed(1.3) +
  geom_point(aes(x = dec_longitude, y = dec_latitude, size = inj_tot_t)) +
  facet_wrap(~ev_year) +
  theme_void()

ggsave("~/Desktop/deaths.png", height = 20, width = 30, units =  "in")

df <- df %>% drop_na(dec_latitude, dec_longitude)

df <- usmap_transform(df,
                      input_names = c("dec_longitude", "dec_latitude"),
                      output_names = c("x", "y"))

us_map <- us_map(regions = "states")

ggplot(data = us_map) +
  geom_polygon(aes(x = x, y = y, group = group),
               fill = "white", color = "black") +
  geom_point(data = df  %>% filter(ev_year == 2010),
             aes(x = x, y = y), color = "black", size = 1) +
  coord_fixed(1) + theme_void() +
  labs(title = "Aircraft Crashes with Fatalities")


###############################################################################
# Injury Table ----------------------------------------------------------------
###############################################################################

injury <- read_csv("data/injury.csv")
