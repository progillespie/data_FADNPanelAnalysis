cd "G:/Data/data_FADNPanelAnalysis/Do_Files/IGM"
local outdatadir "../../OutData/IGM"

* All of the following must be looped over each of the data`filenumber'

local filenumber = 1
local cumulative_N = 0
while `filenumber' < 3{
	
	use `outdatadir'/data`filenumber', clear
	
	*----------------------------------
	* Structural Differences (slide 11)
	*----------------------------------
	
	* For viewing in Stata
	gen totlab_cow = labourinputhours/dairycows
	tabstat  dairycows 		///
		 othercattlelus		///
		 totaluaa 		///
		 daforare 		///
		 stockingdensity 	///
		 totlab_cow 		///
		 milkyield 		///
		 if year==2008 [weight=wt]
	
	* Same data exported to Excel
	preserve

	collapse year			///
		 dairycows 		///
		 othercattlelus		///
		 totaluaa 		///
		 daforare 		///
		 stockingdensity 	///
		 totlab_cow 		///
		 milkyield 		///
		 if year==2008 [weight=wt], by(country)

	local cumulative_N = `cumulative_N' + _N
	di `cumulative_N'
	local rownumber = 1 + `cumulative_N'
	export excel using 		///
	 `outdatadir'/simplified.xlsx, 	///
	sheet("slide 11")		///
	cell(A`rownumber')		///
	sheetmodify


	restore

	*----------------------------------
	* Proportions of farmers by age (slide 12)
	*----------------------------------
	preserve

	do dy_sub_do/age.do

	export excel using 		///
	 `outdatadir'/simplified.xlsx, 	///
	sheet("slide 12 (data`filenumber')")	///
	cell(A2)			///
	firstrow(variables)		///
	sheetmodify

	restore

	*----------------------------------
	* Differences in Farm Financials (slide 13)
	*----------------------------------
	preserve

	do dy_sub_do/fin_farm.do

	export excel using 		///
	 `outdatadir'/simplified.xlsx, 	///
	sheet("slide 13 (data`filenumber')")	///
	cell(A2)			///
	firstrow(variables)		///
	sheetmodify

	restore

	*----------------------------------
	* Gross margin per litre cost groups (slide 14)
	*----------------------------------

	replace fdairygm = fdairygo - fdairydc
	gen fdairytct_lt = fdairytct/dairyproduct
	
	/*-----------------------------------------------
	 P.Gillespie:
	  Create cost groupings in this format: yyyy_g 
	   (i.e. 4 digit year then group number). This format allows you to easily collapse the 
	   dataset by year AND cost grouping (collapse 
	   usually allows only one grouping variable). 
	-----------------------------------------------*/
	
	
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
	
	
	******************************
	* Create a csv with 3 rows per year (one per group) with group totals 
	* per unit measures.
	******************************
	
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
	
	
	*outsheet using `outdatadir'/ct_cat_lt.csv, comma replace
	
	export excel using 		///
	 `outdatadir'/simplified.xlsx	///
	 if year == 2007,		///
	sheet("slide 14 (data`filenumber')")	///
	cell(A2)			///
	firstrow(variables)		///
	sheetmodify
		
	
	restore
	
	
	
	preserve
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


	restore



	*----------------------------------
	* Decomposition of Direct Costs (slide 15)
	*----------------------------------

	preserve

	gen othct = seedsandplants + cropprotection +  othercropspecific +  forestryspecificcosts

	collapse totalspecificcosts fdgrzlvstk fertilisers otherlivestocksp othct if year==2008, by(country)


	gen fdgrz_pct = fdgrzlvstk/totalspecificcosts
	label var fdgrz_pct "Feed"

	gen fert_pct = fertilisers/totalspecificcosts
	label var fert_pct "Fertilser"

	gen othlvstk_pct = otherlivestockspecific/totalspecificcosts
	label var othlvstk_pct  "Other Livestock Costs"

	gen othct_pct = othct/totalspecificcosts
	label var othct_pct  "Other Costs"
	
	
	local rownumber2 = 2 + `filenumber'
	
	export excel country fdgrz_pct fert_pct ///
		     othlvstk_pct 	///
		     othct_pct		///
	  using  `outdatadir'/simplified.xlsx,   ///
	sheet("slide 15")	///
	cell(A`rownumber2')		///
	sheetmodify

	restore	

	local filenumber = `filenumber' + 1 
}	

use `outdatadir'/data1, clear
append using `outdatadir'/data2



*----------------------------------
* Farm size distributions (slide 16)
*----------------------------------
graph tw (kdensity totaluaa if country=="IRE", legend(label(1 "IRE"))) (kdensity totaluaa if country=="UKI", legend( label(2 "UKI"))), title("Farm size distributions") xtitle("Total UAA in hectares") ytitle("Density")
graph export `outdatadir'/uaa_densities.pdf

*----------------------------------
* distributions (slide 17)
*----------------------------------
gen cost_ha = totalinputs/totaluaa
graph tw (kdensity cost_ha if country=="IRE", legend(label(1 "IRE"))) (kdensity cost_ha if country=="UKI", legend( label(2 "UKI"))), title("Cost distributions") xtitle("Total costs per hectare") ytitle("Density")
graph export `outdatadir'/cost_densities.pdf

*----------------------------------
* Milk yield distributions (slide 18)
*----------------------------------

graph tw (kdensity milkyield if country=="IRE", legend(label(1 "IRE"))) (kdensity milkyield if country=="UKI", legend( label(2 "UKI"))), title("Milk yield distributions") xtitle("Litres milk equivalent per cow") ytitle("Density")
graph export `outdatadir'/yield_densities.pdf
