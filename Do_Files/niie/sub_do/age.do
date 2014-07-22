*****************************************************
*12* Creamery producer age
*****************************************************
* Age of holder - collapse dataset to yr-age groups, summing the wts
* to arrive at numbers of farms (or farm holders) represented by the 
* sample for each group. 

* NOTE: ogagehld10 is a variable capturing 10 year age ranges from 
* 20 to 70+ which is created by doFarmDerivedVars.do.

egen yr_age = concat(year ogagehld10), punct("_")
collapse (sum) wt, by(yr_age)

* extract year and age information from yr_age and store as numeric
gen year = substr(yr_age, 1, 4)
gen ogagehld10 = substr(yr_age, -2, 2)
destring year ogagehld10, replace

* calculate farms represented in each year and divide the group wts by
* this figure to arrive at percentage of farms in each group within 
* each year
bysort year: egen yr_wt_tot = sum(wt)
gen age_pct = wt/yr_wt_tot
sort ogagehld10 year

* the data is now ready for a table, display then save csv for Excel
tabstat year ogagehld10 wt yr_wt_tot age_pct, by(yr_age)

