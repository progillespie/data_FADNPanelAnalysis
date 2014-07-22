local outdatadir $outdatadir
*****************************************************
log close
log using `outdatadir'/tab_logs/npers.log, text replace

* npers variables count the number of people falling into age groups
* in each farm household. Create a total figure for calculating %
* of the farm household for each category
gen totnpers = npers04 + npers515 + npers1519 + npers2024 + npers2544 + npers4564 + npers65

* now calculate the perctages
foreach var of varlist nper*{
	gen `var'_pct = `var'/totnpers
}

* Display the weighted per farm averages, then collapse the data
* so that it matches the table and write a csv for Excel.
tabstat *nper* [weight=wt], by(year)
collapse (mean) *npers* [weight=wt], by(year)
