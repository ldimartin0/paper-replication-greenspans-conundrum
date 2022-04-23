library(tidyverse)
library(rio)
library(roll)
library(lubridate)
library(fredr)

# gilt_yield <- fredr(series_id = "IRLTLT01GBM156N")
# gilt_yield_2 <- fredr(series_id = "INTGSBGBM193N")
# bank_rate <- fredr(series_id = "BOERUKM")

d <- left_join(gilt_yield, bank_rate, by = "date") %>% 
	select(
		date,
		gilt_yield = value.x,
		bank_rate = value.y
	) %>% 
	filter(
		date >= ymd("1972-01-01"),
		date <= ymd("2007-08-31")
	) %>% 
	mutate(
		gilt_yield_chg = gilt_yield - lag(gilt_yield),
		bank_rate_chg = bank_rate - lag(bank_rate)
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
	mutate(
		adj_r_sq = as.double(adj_r_sq),
		adj_r_sq_g = lead(adj_r_sq, 50)
	) %>% 
	drop_na()

ggplot(d_g, aes(x = date, y = adj_r_sq_g)) +
	geom_line(group = 1) +
	geom_vline(xintercept = ymd("1992-10-31")) +
	geom_hline(yintercept = 0, linetype = "dashed") +
	ylim(c(-.05, .75)) +
	scale_x_date(
		date_breaks = "20 months",
		labels = scales::label_date("%m-%Y"),
		expand = c(0,0)) + 
	labs(subtitle = "50-Month Adjusted R-Squared Estimates from a Rolling Regression of the Change in the \n  10-Year Government Bond Yield on the Change in the RBNZ Cash Rate,January 1986 to May 2012") +
	theme_bw() +
	theme(
		panel.grid.major.y = element_line(),
		plot.margin = margin(0, 0, 0, 0, "pt"),
		axis.line.y = element_blank())

