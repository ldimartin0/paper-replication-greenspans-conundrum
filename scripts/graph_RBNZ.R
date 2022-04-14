d <- import("data/RBNZ_clean.Rda")
	
d_fil <- d %>% 
	filter(
		date >= lubridate::my("03-1999"),
		date <= lubridate::my("05-2012")
	)
	
d_chg <- d_fil %>% 
	select(date, contains("chg")) %>% 
	pivot_longer(cols = 2:last_col(), names_to = "series")


ggplot(d_chg, aes(x = date, y = value, linetype = series)) +
	geom_line() +
	ylim(c(-1.5,1)) +
	scale_linetype_manual(values = c("dashed", "solid")) +
	labs(title = "New Zealand 10-Year Government Bond Yield and \n RBNZ Cash Rate, March 1999 to May 2012") +
	theme_classic() +
	theme(panel.grid.major.y = element_line())