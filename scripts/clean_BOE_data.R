library(tidyverse)
library(rio)
library(janitor)

d <- import("data/Bank of England Database.csv") %>% 
	clean_names() %>% 
	select(
		date,
		bank_rate_monthly_avg = monthly_average_of_official_bank_rate_a_b_iumabedr,
		bank_rate_end_month = end_month_official_bank_rate_a_b_iumbedr
	) %>% 
	mutate(
		date = lubridate::dmy(date)
	) %>% 
	as_tibble()

dd <- import("data/GLC Nominal month end data_1970 to 2015.xlsx", sheet = "4. spot curve", skip = 3) %>% 
	select( # nasty spreadsheet manipulation here - 10 refers to the bond maturity, years: is just the cell that is above the column of dates
		date = `years:`,
		gilt_yield = `10`
	) %>% 
	mutate(
		date = lubridate::ymd(date)
	) %>% 
	drop_na(date)

d_join <- full_join(d, dd, by = ("date" = "date")) %>% 
	arrange(date)

export(d_join, "data/for_manual_imputation.csv")

d_out <- read_csv("data/BOE_clean.csv") %>% 
	remove_empty(which = "cols") %>% 
	export("data/BOE_clean.Rda")

# recreate data with baserate.xls for 1970