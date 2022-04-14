library(tidyverse)
library(rio)
library(janitor)

d <- import("data/hb2-monthly.xlsx", skip = 4)

d <- d %>% 
	select(date = `Series Id`,  cash_rate = INM.MN.NZK, bond_rate_10yr = INM.MG110.N) %>% 
	mutate(
		cash_rate_chg = cash_rate - lag(cash_rate),
		bond_rate_10yr_chg = bond_rate_10yr - lag(bond_rate_10yr)
	)

export(d, "data/RBNZ_clean.Rda")

