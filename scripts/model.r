library(tidyverse)
library(ggExtra)
library(magrittr)
library(batR)

theme_set(theme_minimal())

setwd("~/Documents/ntsb")

source("scripts/functions.r")

narrative("20230918193076", "cause")

events <- read_csv("data/events.csv")

aircraft <- read_csv("data/aircraft.csv")

###############################################################################
# Recoding and Merges ---------------------------------------------------------
###############################################################################

aircraft %<>%
  filter(acft_category == "AIR") %>%
  select(ev_id, acft_category, acft_make, acft_model, cc_seats, damage,
         dprt_apt_id, dprt_city, dprt_state, dest_apt_id, dest_city, oper_name,
         pax_seats, total_seats, acft_year)

events %<>%
  mutate(inj_tot = inj_tot_f + inj_tot_m + inj_tot_s,
         mid_air = case_when(is.na(mid_air) == FALSE ~ 1,
                             is.na(mid_air) == TRUE ~ 0)) %>%
  filter(ev_id %in% aircraft$ev_id,
         mid_air == 0) %>%
  left_join(aircraft) %>%
  mutate(acft_age = ev_year - acft_year)

###############################################################################
# Focal Variables Visualizations ----------------------------------------------
###############################################################################

events %>%
  filter(acft_age < 900) %>%
  ggplot(aes(x = acft_age)) +
  geom_density()

events %<>%
  filter(acft_age < 900)

events %>%
  ggplot(aes(x = pax_seats)) +
  geom_density()

events %>%
  filter(total_seats < 1000) %>%
  ggplot(aes(x = total_seats)) +
  geom_density()

ggplot(events, aes(x = inj_tot)) +
  geom_density()

ggplot(events, aes(x = as.factor(mid_air))) +
  geom_histogram(stat = "count")

ggplot(events, aes(x = pax_seats, y = inj_tot)) +
  geom_point()

events %>%
  filter(total_seats < 1000) %>%
  ggplot(aes(x = total_seats, y = inj_tot)) +
  geom_point()

ggplot(events, aes(x = acft_age, y = inj_tot)) +
  geom_point()

unique(events$light_cond)
unique(events$sky_cond_nonceil)

###############################################################################
# Models ----------------------------------------------------------------------
###############################################################################

model <- glm(inj_tot ~ ev_year + total_seats + acft_age,
             data = events, family = "poisson")

#base rates
exp(model$coefficients[1])

# Example scenarios
# effect of mean year, extended suicide with mean perps
exp(model.kill$coefficients[1] + 2014 * model.kill$coefficients[2] + 1 * model.kill$coefficients[3] + 1 * model.kill$coefficients[4] + mean(events$acft_age) * model.kill$coefficients[5])

#effect of mean year, extended suicide with 10 perps
exp(model.kill$coefficients[1] + 2014 * model.kill$coefficients[2] + 1*model.kill$coefficients[3] + 1*model.kill$coefficients[4] + 20*model.kill$coefficients[5])

#effect of mean year, extended suicide with minimum perps
exp(model.kill$coefficients[1] + 2014 * model.kill$coefficients[2] + 1*model.kill$coefficients[3] + 1*model.kill$coefficients[4] + min(events$acft_age)*model.kill$coefficients[5])

#effect of mean year, not extended, not suicide with mean perps
exp(model.kill$coefficients[1] + 2014 * model.kill$coefficients[2] + 0 + 0 + 10*model.kill$coefficients[5])

model.kill$coefficients

###############################################################################
# Simulations -----------------------------------------------------------------
###############################################################################
# For fixing non-comformable arguments
# number of columns of the left matrix must be the same as the number of
# rows of the right matrix = I had to switch order in multiplication equation.
# In other words, in matrix multiplication (unlike ordinary multiplication),
# A %*% B is not the same as B %*% A.

B <- MASS::mvrnorm(1000, coef(model), vcov(model))
#B <- cbind(B,1)

age_range <- seq(min(events$acft_age), max(events$acft_age), by = 1)

age_range <- seq(1, 100, by = 1)

X <- cbind(1, mean(events$ev_year), mean(events$total_seats, na.rm = TRUE), age_range) # for suicide attacks
# X2 <- cbind(1, mean(events$ev_year), mean(events$total_seats), 0, age_range) # for non-suicide attacks

y.hat <- exp(B %*% t(X)) #simulated values into a matrix
# y.hat2 <- exp(B %*% t(X2))

y.hatsum <- apply(y.hat, 2, FUN = quantile, c(.025, 0.5, 0.975))
y.hatsum2 <- apply(y.hat2, 2, FUN = quantile, c(.025, 0.5, 0.975))

eyhat <- apply(y.hat, c(1, 2), rpois, n = 1)
emed <- apply(eyhat, 2, median)
eyhat2 <- apply(y.hat2, c(1, 2), rpois, n = 1)
emed2 <- apply(eyhat2, 2, median)

# extract and name rows
# suicide attacks
Pr.lo <- y.hatsum[1, ]
Pr.med <- y.hatsum[2, ]
Pr.hi <- y.hatsum[3, ]

# non-suicide attacks
Pr2.lo <- y.hatsum2[1, ]
Pr2.med <- y.hatsum2[2, ]
Pr2.hi <- y.hatsum2[3, ]

# df <- tibble(age_range, Pr.lo, Pr.med, Pr.hi, Pr2.lo, Pr2.med, Pr2.hi)

df <- tibble(age_range, Pr.lo, Pr.med, Pr.hi)

# plotting
ggplot(df, aes(x = age_range)) +
  geom_line(aes(y = Pr.med), color = "blue") +
  geom_ribbon(aes(ymin = Pr.lo, ymax = Pr.hi), alpha = .2, fill = "dodgerblue")
#   geom_line(aes(y = Pr2.med)) +
#   geom_ribbon(aes(ymin = Pr2.lo, ymax = Pr2.hi), alpha = .2) +
  ggtitle("Body Count By Number of Perpetrators") +
  xlab("Number of Perpetrators") +
  ylab("Number of Deaths") +
  annotate("text", x = 50, y = 6.9, label = "Suicide Attacks") +
  annotate("text", x = 50, y = 2.5, label = "Non-Suicide Attakcs")
