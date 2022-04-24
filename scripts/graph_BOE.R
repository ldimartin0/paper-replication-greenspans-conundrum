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
	) %>% 
	pivot_longer(cols = c("gilt_yield", "bank_rate"), names_to = "Series", values_to = "value")

x_date_breaks <- d$date[seq(1, length(d$date), by = 64)]

g <- ggplot(d, aes(x = date, y = value, linetype = Series)) +
	geom_line() +
	scale_linetype_manual(values = c("solid", "dashed"), labels = c("Bank Rate", "Bond Yield")) +
	scale_x_date(
		breaks = x_date_breaks,
		labels = scales::label_date("%b-%y"),
		expand = c(0,0)) +
	scale_y_continuous(limits = c(0, 20), breaks = seq(0, 20, by = 2), expand = c(0,0)) +
	labs(title = "10-Year Gilt Yield and the BOE’s Policy Rate, August 1968 to August 20007", x = NULL, y = NULL) +
	theme_classic() +
	theme(
		panel.grid.major.y = element_line(),
		axis.line.y = element_blank())

ggsave("graphs/BOE_raw_data.png", g)