*****************************************************
*log close
*log using `outdatadir'/tab_logs/sex.log, text replace
*****************************************************

* Sex of holder - collapse dataset to yr-sex groups, summing the wts
* to arrive at numbers of farms (or farm holders) represented by the 
* sample for each group. 
egen yr_sex = concat(year ogsexhld), punct("_")
collapse (sum) wt, by(yr_sex)

* extract year and sex information from yr_sex and store as numeric
gen year = substr(yr_sex, 1, 4)
gen ogsexhld = substr(yr_sex, -1, 1)
destring year ogsexhld, replace

* calculate farms represented in each year and divide the group wts by
* this figure to arrive at percentage of farms in each group within each 
* year
bysort year: egen yr_wt_tot = sum(wt)
gen sex_pct = wt/yr_wt_tot
sort ogsexhld year

* the data is now ready for a table, display then save csv for Excel
tabstat year ogsexhld wt yr_wt_tot sex_pct, by(yr_sex)
