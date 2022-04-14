library(tidyverse)
library(rio)
library(roll)

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

d_g <- select(d, date, adj_r_sq)

ggplot(d_g, aes(x = date, y = adj_r_sq)) +
	geom_line() +
	geom_vline(xintercept =  lubridate::as_datetime(lubridate::ymd("1999-03-31"))) +
	geom_hline(yintercept = 0, linetype = "dashed") +
	ylim(c(-.1, .45)) +
	scale_x_datetime(date_breaks = "20 months") + 
	labs(subtitle = "50-Month Adjusted R-Squared Estimates from a Rolling Regression of the Change in the \n New Zealand 10-Year Government Bond Yield on the Change in the RBNZ Cash Rate,January 1986 to May 2012") +
	theme_classic() +
	theme(panel.grid.major.y = element_line())

