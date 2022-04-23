library(tidyverse)
library(rio)
library(roll)
library(lubridate)
library(fredr)

gilt_yield <- fredr(series_id = "IRLTLT01GBM156N")
bank_rate <- fredr(series_id = "BOERUKM")

d <- left_join(gilt_yield, bank_rate, by = "date") %>% 
	select(
		date,
		gilt_yield = value.x,
		bank_rate = value.y
	) %>% 
	filter(
		date >= ymd("1969-08-01"),
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

x_date_breaks <- d_g$date[seq(1, length(d_g$date), by = 24)]

g <- ggplot(d_g, aes(x = date, y = adj_r_sq_g)) +
	geom_line(group = 1) +
	geom_vline(xintercept = ymd("1992-10-31")) +
	# geom_hline(yintercept = 0, linetype = "dashed") +
	scale_x_date(
		breaks = x_date_breaks,
		labels = scales::label_date("%b-%y"),
		expand = c(0,0)) + 
	scale_y_continuous(breaks = seq(-0.05, .6, by = .05)) +
	labs(
		title = "50-Month Adjusted R-Squared Estimates from a Rolling Regression of the Change \nin the 10-Year Gilt Yield on the Change in the BOE’s Policy Rate, \nJanuary 1972 to June 2007",
		x = NULL,
		y = NULL) +
	theme_classic() +
	theme(
		panel.grid.major.y = element_line(),
		axis.line.y = element_blank())

ggsave("graphs/BOE_rolling_regression.png", g)
