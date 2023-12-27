library(tidygeocoder)
library(tidyverse)
library(mapdata)
library(batR)

theme_set(theme_minimal())

setwd("~/Documents/ntsb")

source("scripts/functions.r")

events <- read_csv("data/events.csv")

aircraft <- read_csv("data/aircraft.csv")

###############################################################################
# Recoding and Merges ---------------------------------------------------------
###############################################################################

aircraft %<>%
  filter(acft_category == "AIR") %>%
  select(ev_id, acft_category, acft_make, acft_model, cc_seats, damage,
         dprt_apt_id, dprt_city, dprt_state, dprt_country, dest_apt_id,
         dest_city, dest_state, dest_country, oper_name, pax_seats,
         total_seats, acft_year)

events %<>%
  mutate(inj_tot = inj_tot_f + inj_tot_m + inj_tot_s,
         mid_air = case_when(is.na(mid_air) == FALSE ~ 1,
                             is.na(mid_air) == TRUE ~ 0)) %>%
  filter(ev_id %in% aircraft$ev_id,
         mid_air == 0) %>%
  left_join(aircraft) %>%
  mutate(acft_age = ev_year - acft_year, 
         dprt_addr = paste0(dprt_city, ", ", dprt_state),
         dest_addr = paste0(dest_city, ", ", dest_state))

# Geocoding
lat_longs <- events %>%
  filter(dprt_country == "USA", dest_country == "USA") %>%
  sample_n(size = 100) %>%
  geocode(dprt_addr, method = 'osm', lat = dprt_latitude , long = dprt_longitude) %>%
  geocode(dest_addr, method = 'osm', lat = dest_latitude , long = dest_longitude)


###############################################################################
# Network Map -----------------------------------------------------------------
###############################################################################

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

lat_longs %>%
    filter(dprt_latitude != dest_latitude, ev_state %in% state_abbreviations) %>%
    filter(dest_latitude > min_lat, dest_latitude < max_lat,
         dest_longitude > min_lon, dest_longitude < max_lon) %>%
    drop_na(dprt_latitude, dprt_longitude, dest_latitude, dest_longitude) %>%
    ggplot() +
    borders("state") +
    coord_fixed(1.3) +
    geom_curve(aes(x = dprt_longitude, y = dprt_latitude,
                   xend = dest_longitude, yend = dest_latitude),
               alpha = 1, curvature = 0.1, linewidth = .5)
    geom_point(aes(x = longitude, y = latitude, size = Outdegree, fill = Eig))


ggsave("~/Desktop/map.jpg")
