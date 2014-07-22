*****************************************************
*13* Creamery producer marital status
*****************************************************
* Marital status of holder - collapse dataset to yr-marst groups, 
* summing the wts to arrive at numbers of farms (or farm holders)
* represented by the sample for each group. 

egen yr_marst = concat(year ogmarsth), punct("_")
collapse (sum) wt, by(yr_marst)

* extract year and marital status information from yr_marst and 
* store as numeric
gen year = substr(yr_marst, 1, 4)
gen ogmarsth = substr(yr_marst, -1, 1)
destring year ogmarsth, replace

* calculate farms represented in each year and divide the group wts by
* this figure to arrive at percentage of farms in each group within 
* each year
bysort year: egen yr_wt_tot = sum(wt)
gen marst_pct = wt/yr_wt_tot
sort ogmarsth year

* the data is now ready for a table, display then save csv for Excel
tabstat year ogmarsth wt yr_wt_tot marst_pct, by(yr_marst)
