library(tidyverse)
library(rio)
library(janitor)
library(roll)
library(lubridate)

d <- import("data/BOE_super_clean.Rda")

d <- d %>% 
	mutate(
		gilt_yield_chg = gilt_yield - lag(gilt_yield),
		bank_rate_chg = bank_rate_end_month - lag(bank_rate_end_month)
	)

fit <- roll_lm(d$gilt_yield_chg, d$bank_rate_chg, width = 50, min_obs = 30)

fit_df <- tibble(
	r_sq = fit$r.squared,
	obs = as.double(1:length(fit$r.squared))
)

# capping observations at 50 then calculate adj_r_sq
fit_df <- fit_df %>% 
	mutate(
		obs = case_when(
			obs < 50 ~ obs,
			obs >= 50 ~ 50
		),
		adj_r_sq = (1 - ((1-r_sq)*(obs-1)/(obs-1-1)))
	)

d <- bind_cols(d, fit_df)

d_g <- select(d, date, adj_r_sq) %>% 
	mutate(adj_r_sq = as.double(adj_r_sq)) %>% 
	filter(
		date <= ymd("2002-04-01"),
		date >= ymd("1972-01-01")
	) 

ggplot(d_g, aes(x = date, y = adj_r_sq)) +
	geom_line(group = 1) +
	geom_vline(xintercept = ymd("1992-10-31")) +
	geom_hline(yintercept = 0, linetype = "dashed") +
	ylim(c(-.05, .4)) +
	# labs(subtitle = "50-Month Adjusted R-Squared Estimates from a Rolling Regression of the Change in the \n New Zealand 10-Year Government Bond Yield on the Change in the RBNZ Cash Rate,January 1986 to May 2012") +
	theme_classic() +
	theme(panel.grid.major.y = element_line())
