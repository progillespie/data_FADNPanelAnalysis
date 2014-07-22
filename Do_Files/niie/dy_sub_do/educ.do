local outdatadir $outdatadir
local intdata2 $intdata2
******************************

insheet using `outdatadir'/education.csv, clear
* for worker code 1 = owner/manager, 3 = owner not manager
* these are the only ones I'm interested in, so drop the rest.
keep if [worker_code ==1]
drop if ye_ar<2008
* This data contains a number of duplicate observations. This 
* duplication goes beyond the fact that the data is multi-caret
* (speak to Anne Kinsella, Brian Moran, or John Lennon for more 
* info on this... essentially there is more that one ob per farm
* per year by design). Even when limiting the selection to only
* owner/managers, there's still more than one ob per farm per 
* year. There may well be more than one owner/manager on several 
* farms, but I'll need tolocal educ "formal_agricultural_training_yn highest_education_achieved_code highest_formal_agri_training_cod current_in_education_yn" condense this somehow.

* Should keep the obs (i.e. rows) with the fewest missing values
* Next 3 lines counts missings on each row, creates var which =
* minimum number of missings per group of duplicates, then drops
* rows which have more missings than the minimum. This step is
* necessary because duplicates tag or duplicates drop merely 
* keeps the first row in each group of duplicates, not necessarily
* the BEST row.
egen miss = rowmiss(_all)
bysort farm_code ye_ar: egen minmiss = min(miss)
drop if miss != minmiss


* The remaining rows will either be unique or will have the same
* number of missing values. Now drop  rows which are exact matches 
* for all values). 
duplicates tag _all, gen(tag)
drop if tag>0
drop tag

* Still have 40 rows for which farm_code and ye_ar do not uniquely
* identify a row. This loop finds the max value within each group of
* duplicates and drops those obs which are not equal to the max value.
* Your left with the rows with the highest values for each var in 
* `educ'. 
rename formal_agricultural_training_yn formag
rename highest_education_achieved_code hieduc
rename highest_formal_agri_training_cod hiform 
rename current_in_education_yn curr_ed
local educ "formag hieduc hiform curr_ed"

foreach var of  varlist `educ'{
	bysort farm_code ye_ar: egen max_`var' = max(`var')
	drop if `var' != max_`var'
}


* Data are now uniquely id'ed by farm_code and ye_ar. 
* Now merge the data into intdata2
rename farm_code farmcode
rename ye_ar year
keep farmcode year `educ'
sort farmcode year
save `outdatadir'/educ, replace
use `outdatadir'/`intdata2', clear
merge farmcode year using `outdatadir'/educ, unique nokeep
keep if _merge==3
drop _merge

* Now have data for 303 obs (all in 2008). Collapse and write csv's. 

* create crosstab vars to use as by var's in collapse
foreach var of varlist `educ'{
egen `var'_tg = concat(`var' teagasc), punct("_")
egen `var'_reg = concat(`var' region ), punct("_")
egen `var'_age = concat(`var' ogagehld10), punct("_")
}

save `outdatadir'/educ, replace

* creates freq table csv's for crosstabs of educ vars with teagasc,
* region, and age categories
use `outdatadir'/educ, clear
foreach var of varlist `educ'{
	* var is a varlist local type, so store current value of var 
	* as a string for recreating var after the collapse statement
	local varname = "`var'"

	* teagasc crosstabs
	use `outdatadir'/educ, clear
	collapse (sum) wt, by(`var'_tg)
	egen tot_wt = sum(wt)
	gen pct = wt/tot_wt
	gen `varname' = substr(`var'_tg, 1, 1)
	gen teagasc = substr(`var'_tg, -1,1) 
	outsheet using `outdatadir'/`var'_tg.csv, comma replace

	* region crosstabs
	use `outdatadir'/educ, clear
	collapse (sum) wt, by(`var'_reg)
	egen tot_wt = sum(wt)
	gen pct = wt/tot_wt
	gen `varname'= substr(`var'_reg,1,1)
	gen region= substr(`var'_reg, -1,1) 
	outsheet using `outdatadir'/`var'_reg.csv, comma replace

	* age crosstabs
	use `outdatadir'/educ, clear
	collapse (sum) wt, by(`var'_age)
	egen tot_wt = sum(wt)
	gen pct = wt/tot_wt
	gen `varname' = substr(`var'_age,1,1)
	gen ogagehld10 = substr(`var'_age, -2,2) 
	outsheet using `outdatadir'/`var'_age.csv, comma replace
}

