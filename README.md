# Further Evidence on Greenspan's Conundrum - A Replication Project
This is a project to replicate "Further Evidence on Greenspan's Conundrum," a paper published by [Cletus C. Coughlin](https://research.stlouisfed.org/econ/coughlin/sel/) and [Daniel L. Thornton](https://research.stlouisfed.org/econ/thornton/jp/) at the Federal Reserve Bank of St. Louis.

### Original Paper

The original paper is [here](https://research.stlouisfed.org/publications/review/2021/11/16/further-evidence-on-greenspans-conundrum).

### Data

Monthly data from the Royal Bank of New Zealand on cash rates and bond yields can be found [here](https://www.rbnz.govt.nz/statistics/b2).

Monthly data from the Bank of England can be accessed from the St. Louis Federal Reserve website found [here](https://fred.stlouisfed.org/). The Series ID's for gilt rate and bank rate are `IRLTLT01GBM156N` and `BOERUKM`.

### Dependencies

This code is not packaged, so it makes library calls directly for the following R packages:

* `tidyverse` (`dplyr`, `tidyr`, `ggplot2`, and `lubridate` should be sufficient)
* `rio`
* `janitor`
* `roll`
* `fredr`

Note that `fredr` requires a developer key from FRED. If you'd rather not do that, the series can be downloaded directly from FRED.


 
 
