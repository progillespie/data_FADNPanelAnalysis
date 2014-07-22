local outdatadir $outdatadir
*****************************************************
log close
log using `outdatadir'/tab_logs/teagasc.log, text replace
*****************************************************

* Status of Teagasc advisory utilisation - collapse dataset to
* yr-teagasc groups summing the wts to arrive at numbers of farms 
* (or farm holders) represented by the sample for each group. 

egen yr_teagasc = concat(year teagasc), punct("_")
collapse (sum) wt, by(yr_teagasc)

* extract year and employment status information from yr_teagasc and 
* store as numeric
gen year = substr(yr_teagasc, 1, 4)
gen teagasc = substr(yr_teagasc, -1, 1)
destring year teagasc, replace

* calculate farms represented in each year and divide the group wts by
* this figure to arrive at percentage of farms in each group within 
* each year
bysort year: egen yr_wt_tot = sum(wt)
gen teagasc_pct = wt/yr_wt_tot
sort teagasc year

* the data is now ready for a table, display then save csv for Excel
tabstat year teagasc wt yr_wt_tot teagasc_pct, by(yr_teagasc)
