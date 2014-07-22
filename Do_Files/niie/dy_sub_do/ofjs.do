local outdatadir $outdatadir
*****************************************************
log close
log using `outdatadir'/tab_logs/ofjs.log, text replace
*****************************************************

* Status of off-farm employment of spouse - collapse dataset to 
* yr-ofjs groups summing the wts to arrive at numbers of farms 
* (or farm holders) represented by the sample for each group. 

egen yr_ofjs = concat(year isspofffarmy), punct("_")
collapse (sum) wt, by(yr_ofjs)

* extract year and employment status information from yr_ofjs and 
* store as numeric
gen year = substr(yr_ofjs, 1, 4)
gen isspofffarmy = substr(yr_ofjs, -1, 1)
destring year isspofffarmy, replace

* calculate farms represented in each year and divide the group wts by
* this figure to arrive at percentage of farms in each group within 
* each year
bysort year: egen yr_wt_tot = sum(wt)
gen ofjs_pct = wt/yr_wt_tot
sort isspofffarmy year

* the data is now ready for a table, display then save csv for Excel
tabstat year isspofffarmy wt yr_wt_tot ofjs_pct, by(yr_ofjs)
