local outdatadir $outdatadir
*****************************************************
log close
log using `outdatadir'/tab_logs/ofjb.log, text replace
*****************************************************

* Status of off-farm employment of both - collapse dataset to 
* yr-ofjb groups summing the wts to arrive at numbers of farms 
* (or farm holders) represented by the sample for each group. 

egen yr_ofjb = concat(year bothwork), punct("_")
collapse (sum) wt, by(yr_ofjb)

* extract year and employment status information from yr_ofjb and 
* store as numeric
gen year = substr(yr_ofjb, 1, 4)
gen bothwork = substr(yr_ofjb, -1, 1)
destring year bothwork, replace

* calculate farms represented in each year and divide the group wts by
* this figure to arrive at percentage of farms in each group within 
* each year
bysort year: egen yr_wt_tot = sum(wt)
gen ofjb_pct = wt/yr_wt_tot
sort bothwork year

* the data is now ready for a table, display then save csv for Excel
tabstat year bothwork wt yr_wt_tot ofjb_pct, by(yr_ofjb)
