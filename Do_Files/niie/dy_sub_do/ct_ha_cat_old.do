gen fdairytct_ha = fdairytct/daforare
gen fdairytct_lt = fdairytct/doslmkgl

* Create cost groupings in this format: yyyy_g (i.e. 4 digit year then 
* group number). This format allows you to easily collapse the dataset 
* by year AND cost grouping (collapse usually allows only one grouping
* variable). 
* Create 3 groups of farms by total costs per hectare in each year
local i = 1995
gen str ct_ha_cat = "" //<- "" is not a typo. One indicates missing values for string variables with empty double inverted commas (double quotes)
while `i' < 2009{
	* creates grouping for the year, but missing in other years.
	xtile ct_ha_cat_`i'=fdairytct_ha [weight=wt] if year==`i', nq(3)

	* Thia's convention is to number the categories from highest cost
	* to lowest cost, so reassign values to match that by subtracting
	* from 4. 
	replace ct_ha_cat_`i' = 4 - ct_ha_cat_`i' if year==`i'

	* adds the 4 digit year to front, still missing in other years
	egen tmp_cat = concat(year ct_ha_cat_`i'), punct("_")

	* One var that fills up as you go through the loop (no missings).
	replace ct_ha_cat = tmp_cat if year == `i'
	drop ct_ha_cat_`i' tmp_cat
	local i = `i'+1
}

* Create 3 groups of farms by total costs per litre in each year
local i = 1995
gen str ct_lt_cat = "" //<- not a typo = missing value for string var
while `i' < 2009{
	* creates grouping for the year, but missing in other years.
	xtile ct_lt_cat_`i'=fdairytct_lt [weight=wt] if year==`i', nq(3)

	* Thia's convention is to number the categories from highest cost
	* to lowest cost, so reassign values to match that by subtracting
	* from 4. 
	replace ct_lt_cat_`i' = 4 - ct_lt_cat_`i' if year==`i'

	* adds the 4 digit year to front, still missing in other years
	egen tmp_cat = concat(year ct_lt_cat_`i'), punct("_")

	* One var that fills up as you go through the loop (no missings).
	replace ct_lt_cat = tmp_cat if year == `i'
	drop ct_lt_cat_`i' tmp_cat
	local i = `i'+1
}
save `outdatadir'/`intdata3', replace
