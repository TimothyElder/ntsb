library(tidyverse)
library(magrittr)
library(lubridate)
library(mapdata)
library(usmap)
library(batR)
library(sf)

"20080107X00027"

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
  ylim(1000, 2000) +
  labs(title = "Events over time")

events %>%
  filter(ev_highest_injury == "FATL") %>%
  count(ev_year) %>%
  ggplot(aes(x = ev_year, y = n)) +
  geom_line(stat = "identity") +
  labs(title = "Events with fatalities over time", x = "Count", y = "Count")

events %>%
  count(mid_air)

events %>%
  count(on_ground_collision)

events %>%
  count(gust_ind)

###############################################################################
# Fatal Accidents -------------------------------------------------------------
###############################################################################

df <- events %>%
  filter(ev_highest_injury == "FATL",
         ev_state %in% state_abbreviations)

ggplot(df, aes(x = inj_tot_t)) +
  geom_density() +
  labs(
    title = "Distribution of total number of injuries for events with fatality")

df %>%
  count(ev_state, ev_year) %>%
  ggplot(aes(x = ev_year, y = n, group = ev_state)) +
  geom_line() + facet_wrap(~ev_state, nrow = 10, ncol = 5)

df$ev_dow <- factor(df$ev_dow,
                    levels = c("Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"))

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

events <- events %>%
  drop_na(dec_latitude, dec_longitude) %>%
  filter(dec_latitude < 1000, dec_longitude > -1000)

events <- usmap_transform(events,
                      input_names = c("dec_longitude", "dec_latitude"),
                      output_names = c("x", "y"))

min_lat <- 24.396308
max_lat <- 49.345786
min_lon <- -125.000000
max_lon <- -66.934570

state <- geom_polygon(aes(x = long, y = lat, group = group),
                      data = map_data('state'),
                      fill = "#e3e0e0", color = "#515151",
                      size = 0.15)

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

events %>%
  filter(dec_latitude > min_lat, dec_latitude < max_lat,
         dec_longitude > min_lon, dec_longitude < max_lon,
         is.na(ev_highest_injury) == FALSE) %>%
  ggplot() +
  state +
  coord_fixed(1.3) +
  geom_point(aes(x = dec_longitude, y = dec_latitude,
                 size = inj_tot_t, color = ev_highest_injury)) +
  facet_wrap(~ev_highest_injury) +
  theme_void()

ggsave("~/Desktop/deaths.png", height = 20, width = 30, units =  "in")

df <- df %>%
  drop_na(dec_latitude, dec_longitude)

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

ggplot(data = us_map) +
  geom_polygon(aes(x = x, y = y, group = group),
               fill = "white", color = "black") +
  geom_point(data = events %>% filter(ev_state %in% state_abbreviations),
             aes(x = x, y = y, color = ev_highest_injury), size = 1) +
  coord_fixed(1) +
  theme_void() +
  facet_wrap(~ev_year) +
  labs(title = "Aircraft Crashes with Fatalities")

ggplot(data = us_map) +
  geom_polygon(aes(x = x, y = y, group = group),
               fill = "white", color = "black") +
  geom_point(data = events %>%
             filter(ev_state %in% state_abbreviations,
                    is.na(ev_highest_injury) == FALSE),
             aes(x = x, y = y, color = ev_highest_injury), size = 1) +
  coord_fixed(1) +
  theme_void() +
  facet_wrap(~ev_highest_injury) +
  labs(title = "Aircraft Crashes with Fatalities")

ggsave("~/Desktop/map.png", height = 20, width = 30, units =  "in")

###############################################################################
# Injury Table ----------------------------------------------------------------
###############################################################################

injury <- read_csv("data/injury.csv")

###############################################################################
# Aircraft Table --------------------------------------------------------------
###############################################################################

aircraft <- read_csv("data/aircraft.csv")

aircraft %>%
  count(acft_category)

aircraft %<>%
  filter(acft_category == "AIR")

aircraft %>%
  filter(total_seats < 1000) %>%
  ggplot(aes(x = total_seats)) +
  geom_density()

events %>%
  select(ev_id, inj_tot_f, inj_tot_s, inj_tot_n, inj_tot_t) %>%
  right_join(aircraft) %>%
  drop_na(total_seats, inj_tot_f) %>%
  filter(total_seats < 1000) %>%
  { cor(.$total_seats, .$inj_tot_f) }

events %>%
  select(ev_id, inj_tot_f, inj_tot_s, inj_tot_n, inj_tot_t) %>%
  right_join(aircraft) %>%
  drop_na(total_seats, inj_tot_t) %>%
  filter(total_seats < 1000) %>%
  { cor(.$total_seats, .$inj_tot_t) }

events %>%
  select(ev_id, inj_tot_f, inj_tot_s, inj_tot_n, inj_tot_t) %>%
  right_join(aircraft) %>%
  drop_na(total_seats, inj_tot_t) %>%
  filter(total_seats < 1000) %>%
  ggplot(aes(x = total_seats, y = inj_tot_t)) +
  geom_point() +
  geom_smooth(method = "lm")

events %>%
  select(ev_id, inj_tot_f, inj_tot_s, inj_tot_n, inj_tot_t) %>%
  right_join(aircraft) %>%
  drop_na(total_seats, inj_tot_t) %>%
  filter(total_seats < 1000) %>%
  ggplot(aes(x = total_seats, y = inj_tot_f)) +
  geom_point()

aircraft %>%
  mutate(acft_make = str_to_lower(acft_make)) %>%
  count(acft_make) %>%
  slice_max(n = 20, order_by = n) %>%
  ggplot(aes(x = reorder(acft_make, n), y = n)) +
  geom_bar(stat = "identity") +
  coord_flip()

###############################################################################
# Narratives Table ------------------------------------------------------------
###############################################################################

narratives <- read_csv("data/narratives.csv")

narrative("20080107X00027", "summary")