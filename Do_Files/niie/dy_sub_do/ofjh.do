local outdatadir $outdatadir
*****************************************************
log close
log using `outdatadir'/tab_logs/ofjh.log, text replace
*****************************************************

* Status of off-farm employment of holder - collapse dataset to 
* yr-ofjh groups summing the wts to arrive at numbers of farms 
* (or farm holders) represented by the sample for each group. 

egen yr_ofjh = concat(year isofffarmy), punct("_")
collapse (sum) wt, by(yr_ofjh)

* extract year and employment status information from yr_ofjh and 
* store as numeric
gen year = substr(yr_ofjh, 1, 4)
gen isofffarmy = substr(yr_ofjh, -1, 1)
destring year isofffarmy, replace

* calculate farms represented in each year and divide the group wts by
* this figure to arrive at percentage of farms in each group within 
* each year
bysort year: egen yr_wt_tot = sum(wt)
gen ofjh_pct = wt/yr_wt_tot
sort isofffarmy year

* the data is now ready for a table, display then save csv for Excel
tabstat year isofffarmy wt yr_wt_tot ofjh_pct, by(yr_ofjh)
