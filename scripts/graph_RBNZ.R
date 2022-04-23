library(tidyverse)
library(rio)
library(scales)


d <- import("data/RBNZ_clean.Rda")
	
d_fil <- d %>% 
	filter(
		date >= lubridate::my("03-1999"),
		date <= lubridate::my("05-2012")
	)
	
d_chg <- d_fil %>% 
	select(date, contains("chg")) %>% 
	pivot_longer(cols = 2:last_col(), names_to = "Series") %>% 
	mutate(date = as_date(date))

x_date_breaks <- d_chg$date[seq(1, length(d_chg$date), by = 30)]

g <- ggplot(d_chg, aes(x = date, y = value, linetype = Series)) +
	geom_line() +
	scale_linetype_manual(values = c("dashed", "solid"), labels = c("Bond Yield", "Cash Rate")) +
	scale_x_date(
		breaks = x_date_breaks,
		labels = scales::label_date("%b-%y"),
		expand = c(0,0)) +
	scale_y_continuous(limits = c(-1.5, 1), breaks = seq(-1.5, 1, by = .5), expand = c(0,0)) +
	labs(title = "New Zealand 10-Year Government Bond Yield and RBNZ Cash Rate, \nMarch 1999 to May 2012", x = NULL, y = NULL) +
	theme_classic() +
	theme(
		panel.grid.major.y = element_line(),
		axis.line.y = element_blank())

ggsave("graphs/RBNZ_raw_data.png", g)