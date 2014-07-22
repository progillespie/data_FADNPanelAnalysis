/****************************************************
*****************************************************

 Calculate cost categories (thirds)

*****************************************************
****************************************************/

local outdatadir $outdatadir1/data$filenumber
*local intdata3 $intdata3


*log close
*log using `outdatadir'/tab_logs/ct_cat.log, text replace


/*-----------------------------------------------
 P.Gillespie:
  Fixed (overhead) costs are not broken out by 
   enterprise. Creating allocation weight for the
   dairy enterprise to apply to fixed costs. 
   After 2005, the weight should remove the 
   Single Farm Payment and Disadvantaged Area 
   Payments from the denominator. Then apply the 
   allocation weight to generate fixed costs and
   total costs for the dairy enterprise. Then 
   break into per hectare and per litre. 
-----------------------------------------------*/

*gen d_alloc_wt = fdairygo/farmgo


*replace d_alloc_wt = fdairygo/(farmgo - sfp - lfa) if year>=2005

*capture drop fdairyoh 
*capture drop fdairytct
*gen fdairyoh = farmohct*d_alloc_wt
*gen fdairytct = fdairydc + fdairyoh


/*-----------------------------------------------
 P.Gillespie:
  Upon further review, I've realised that this 
   cost grouping is inconsistent with the per 
   litre cost grouping and is misleading. More 
   intensive producers will have higher costs 
   per hectare but lower costs per litre, and 
   consequently higher margin per litre. The 
   effect of using per ha cost could be to mix 
   groups of farms that are too different to 
   belong together. Furthermore, the cost grouping
   should be consistent no matter which measure of
   GM (per ha or per litre), so as to ensure that 
   the graphs are in fact comparable. Code was 
   changed to reflect these decisions on 
   12 Oct,2012. 
-----------------------------------------------*/
gen fdairytct_lt = fdairytct/dairyproduct


/*-----------------------------------------------
 P.Gillespie:
  Create cost groupings in this format: yyyy_g 
   (i.e. 4 digit year then group number). This 
   format allows you to easily collapse the 
   dataset by year AND cost grouping (collapse 
   usually allows only one grouping variable). 
-----------------------------------------------*/
*log close
*log using `outdatadir'/tab_logs/sex.log, text replace


* Create 3 groups of farms by total costs per hectare in each year
gen str ct_lt_cat = "" //<- "" purposefully set to empty string


* Create 3 groups of farms by total costs per litre in each year
local i = 1999
while `i' < 2008{


	* creates grouping for the year, but missing in other years.
	xtile ct_lt_cat_`i'=fdairytct_lt [weight=wt] if year==`i' /*
  	*/    , nq(3)


	/* Thia's convention is to number the categories from highest 
	    cost to lowest cost, so reassign values to match that by 
	    subtracting from 4. */ 
	replace ct_lt_cat_`i' = 4 - ct_lt_cat_`i' if year==`i'


	* adds the 4 digit year to front, still missing in other years
	egen tmp_cat = concat(year ct_lt_cat_`i'), punct("_")


	* One var that fills up as you go through the loop (no missings)
	replace ct_lt_cat = tmp_cat if year == `i'
	drop ct_lt_cat_`i' tmp_cat
	local i = `i'+1


}


*save `outdatadir'/`intdata3', replace


******************************
* Create a csv with 3 rows per year (one per group) with group totals 
* per unit measures.
******************************

*------------
* Per hectare
*------------
* gsort allows descending order, sort does not
gsort year -fdairytct_lt

preserve
collapse (sum) daforare fdairygo fdairydc fdairyoh fdairygm /*
*/                                  [weight=wt], by(ct_lt_cat)


/* Generate per ha measures using sums of each group in each
    year which is what you have from the collapse statement */
foreach var in fdairygo fdairydc fdairyoh fdairygm {


	gen `var'_ha = `var'/daforare


}

* separate year and group info in ct_lt_cat
gen year = substr(ct_lt_cat, 1, 4)


replace ct_lt_cat = substr(ct_lt_cat, -1, 1)


* then store as numeric vars instead of strings and create the csv
destring year ct_lt_cat, replace


sort ct_lt_cat year


outsheet using `outdatadir'/ct_cat_ha.csv, comma replace

export excel using 		///
 `outdatadir'/simplified.xlsx, 	///
sheet("slide 14 (data`i')")	///
cell(A2)			///
firstrow(variables)		///
sheetmodify

restore
*use `outdatadir'/`intdata3', clear



*------------
* Per litre
*------------
* gsort allows descending order, sort does not
gsort year -fdairytct_lt

preserve
collapse (sum) doslmkgl fdairygo fdairydc fdairyoh fdairygm /*
*/       [weight=wt], by(ct_lt_cat)


* generate per ha measures using sums of each group in each year
* which is what you have from the collapse statement
foreach var in fdairygo fdairydc fdairyoh fdairygm {

	gen `var'_lt = `var'/doslmkgl

}


* separate year and group info in ct_lt_cat
gen year = substr(ct_lt_cat, 1, 4)
replace ct_lt_cat = substr(ct_lt_cat, -1, 1)


* then store as numeric vars instead of strings and create the csv
destring year ct_lt_cat, replace


sort ct_lt_cat year


outsheet using `outdatadir'/ct_cat_lt.csv, comma replace

export excel using 		///
 `outdatadir'/simplified.xlsx, 	///
sheet("slide 14 (data`i')")	///
cell(N2)			///
firstrow(variables)		///
sheetmodify
	

restore



collapse (mean) ogagehld [weight=wt], by(ct_lt_cat)


* separate year and group info in ct_lt_cat
gen year = substr(ct_lt_cat, 1, 4)
replace ct_lt_cat = substr(ct_lt_cat, -1, 1)


* then store as numeric vars instead of strings and create the csv
destring year ct_lt_cat, replace


sort ct_lt_cat year
outsheet using `outdatadir'/ct_cat_lt_mean_age.csv, comma replace
macro list _outdatadir
*use `outdatadir'/`intdata3', clear
