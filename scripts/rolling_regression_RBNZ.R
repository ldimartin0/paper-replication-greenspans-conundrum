library(tidyverse)
library(rio)
library(roll)
library(lubridate)

d <- import("data/RBNZ_clean.Rda")

d <- d %>% 
	filter(
		date <= lubridate::my("05-2012")
		) %>% 
	drop_na(cash_rate_chg, bond_rate_10yr_chg)

# rolling regression
fit <- roll_lm(d$cash_rate_chg, d$bond_rate_10yr_chg, width = 50, min_obs = 10)

# dataframe with r-squares for each regression

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

d_g <- d %>% 
	select(date, adj_r_sq) %>% 
	mutate(
		date = as_date(date),
		adj_r_sq_g = lead(adj_r_sq, n = 50)
		) %>% 
	filter(
		date >= ymd("1986-01-01"),
		date <= ymd("2008-05-01")
	) %>% 
	mutate(
		date = date + days(1)
	)

g <- ggplot(d_g, aes(x = date, y = adj_r_sq_g)) +
	geom_line() +
	geom_vline(xintercept = ymd("1999-03-01")) +
	geom_hline(yintercept = 0, linetype = "dashed") +
	scale_x_date(
		breaks = d_g$date[seq(1, length(d_g$date), by = 19)],
		labels = scales::label_date("%b-%y"),
		expand = c(0,0)) + 
	scale_y_continuous(
		limits = c(-.05, .45),
		breaks = seq(-.05, .45, by = .05),
		expand = c(0,0)) +
	labs(
		title = "50-Month Adjusted R-Squared Estimates from a Rolling Regression of the Change \n in the New Zealand 10-Year Government Bond Yield on the Change \nin the RBNZ Cash Rate, January 1986 to May 2012",
		y = NULL,
		x = NULL) +
	theme_classic() +
	theme(
		panel.grid.major.y = element_line()
		) +
	theme(axis.line.y = element_blank())

ggsave("graphs/RBNZ-overlay.png", g, bg = "transparent")

