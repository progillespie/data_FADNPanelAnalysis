version 9.0
clear
set more off
set matsize 4000

set mem 300m

cd "D:\data\Data_FADNAnalysis\Do_Files\IGM"
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
	*export excel using 		///
	* `outdatadir'/simplified.xlsx, 	///
	*sheet("slide 11")		///
	*cell(A`rownumber')		///
	*sheetmodify


	restore

	*----------------------------------
	* Proportions of farmers by age (slide 12)
	*----------------------------------
	preserve

	do dy_sub_do/age.do

	*export excel using 		///
	* `outdatadir'/simplified.xlsx, 	///
	*sheet("slide 12 (data`filenumber')")	///
	*cell(A2)			///
	*firstrow(variables)		///
	*sheetmodify

	restore

	*----------------------------------
	* Differences in Farm Financials (slide 13)
	*----------------------------------
	preserve

	do dy_sub_do/fin_farm.do

	*export excel using 		///
	* `outdatadir'/simplified.xlsx, 	///
	*sheet("slide 13 (data`filenumber')")	///
	*cell(A2)			///
	*firstrow(variables)		///
	*sheetmodify

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
	
	save data`filenumber'_out.dta, replace
	
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
	
	*export excel using 		///
	* `outdatadir'/simplified.xlsx	///
	* if year == 2007,		///
	*sheet("slide 14 (data`filenumber')")	///
	*cell(A2)			///
	*firstrow(variables)		///
	*sheetmodify
		
	
	restore
	
	
	
	preserve
	collapse (mean) ogagehld [weight=wt], by(ct_lt_cat)
	
	
	* separate year and group info in ct_lt_cat
	gen year = substr(ct_lt_cat, 1, 4)
	replace ct_lt_cat = substr(ct_lt_cat, -1, 1)
	
	
	* then store as numeric vars instead of strings and create the csv
	destring year ct_lt_cat, replace
	
	
	sort ct_lt_cat year
	outsheet using `outdatadir'/ct_cat_lt_mean_age`filenumber'.csv, comma replace
	macro list _outdatadir
	*use `outdatadir'/`intdata3', clear


	restore

	save data`filenumber'_out.dta, replace

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
	
	*export excel country fdgrz_pct fert_pct ///
	*	     othlvstk_pct 	///
	*	     othct_pct		///
	 * using  `outdatadir'/simplified.xlsx,   ///
	*sheet("slide 15")	///
	*cell(A`rownumber2')		///
	*sheetmodify

	restore	

	local filenumber = `filenumber' + 1 
}	

local filenumber = 1
use data`filenumber'_out.dta, clear
gen cntry = 1
local filenumber = 2
append using data`filenumber'_out.dta
replace cntry = 2 if cntry == .

* Do Comparative Analysis

* Stocking Rate
capture gen lu_ha = dpnolu/daforare

* Yield
capture gen lt_lu = 

* Milk Price
gen milk_price = doslmkgl/dotomkgl

*Gross Outpput
gen fdairygo_ha = fdairygo/daforare
gen fdairygo_lu = fdairygo/dpnolu
gen fdairygo_labu = fdairygo/flabunpd
capture drop fdairygo_lt
gen fdairygo_lt = fdairygo/dairyproduct

* Costs
gen fdairydc_lt = fdairydc/dairyproduct
gen fdairyoh_lt = fdairyoh/dairyproduct

gen cost_lt =  fdairydc_lt+ fdairyoh_lt
gen cost_lu =  (fdairydc + fdairyoh)/dpnolu
gen cost_ha =  (fdairydc + fdairyoh)/daforare
gen cost_labu =  (fdairydc + fdairyoh)/flabunpd

* Margin
gen fdairynm_lt = fdairygm/dairyproduct - fdairyoh_lt
gen fdairygm_lt = fdairygm/dairyproduct
gen fdairygm_labu = fdairygm/flabunpd

gen nm_lt1 = fdairynm_lt
gen nm_lu1 = (fdairygm - fdairyoh)/dpnolu
gen nm_ha1 = (fdairygm - fdairyoh)/daforare
gen nm_labu1 = (fdairygm - fdairyoh)/flabunpd

* Adjusted Net Margin

sort cntry year
by cntry year: egen av_fdairygo_lt = mean(fdairygo_lt)
local yr_list = "1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009"
local cntry_list = "1 2"
foreach yr in `yr_list' {
	foreach cntry in `cntry_list' {
			gen tav_fdairygo_lt`yr'_`cntry' = av_fdairygo_lt if cntry == `cntry' & year == `yr'
			qui replace tav_fdairygo_lt`yr'_`cntry' = 0 if tav_fdairygo_lt`yr'_`cntry' == .
			egen av_fdairygo_lt`yr'_`cntry' = max(tav_fdairygo_lt`yr'_`cntry')
			drop tav_fdairygo_lt`yr'_`cntry'
		}
}

* Make ROI milk prices like NI
gen fdairygo_adj = fdairygo if year == 2008 
local yr = 2008
qui replace fdairygo_adj = fdairygo_adj*av_fdairygo_lt`yr'_2/av_fdairygo_lt`yr'_1 if year == 2008 & cntry == 1

gen nm_labu_adj = (fdairygo_adj - fdairydc - fdairyoh)/flabunpd


* BMW Region
gen bmw = cntry == 1 & subregion == 2

*******************************************************
* Per Ha
*******************************************************
* daforare Kernel Density ROI- NI
kdensity daforare if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* daforare Kernel Density BMW- NI
kdensity daforare if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* daforare Kernel Density SE- NI
kdensity daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* daforare Kernel Density SE- BMW
kdensity daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* GO Kernel Density ROI- NI
kdensity fdairygo_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* GO Kernel Density BMW- NI
kdensity fdairygo_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* GO Kernel Density SE- NI
kdensity fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* GO Kernel Density SE- BMW
kdensity fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* Cost Kernel Density ROI- NI
kdensity cost_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* Cost Kernel Density BMW- NI
kdensity cost_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* Cost Kernel Density SE- NI
kdensity cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* Cost Kernel Density SE- BMW
kdensity cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* NM Kernel Density ROI- NI
kdensity nm_ha1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* NM Kernel Density BMW- NI
kdensity nm_ha1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* NM Kernel Density SE- NI
kdensity nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* NM Kernel Density SE- BMW
kdensity nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

*******************************************************
* Per LU
*******************************************************

* lu_ha Kernel Density ROI- NI
kdensity lu_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* lu_ha Kernel Density BMW- NI
kdensity lu_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* lu_ha Kernel Density SE- NI
kdensity lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* lu_ha Kernel Density SE- BMW
kdensity lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* GO Kernel Density ROI- NI
kdensity fdairygo_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* GO Kernel Density BMW- NI
kdensity fdairygo_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* GO Kernel Density SE- NI
kdensity fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* GO Kernel Density SE- BMW
kdensity fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* Cost Kernel Density ROI- NI
kdensity cost_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* Cost Kernel Density BMW- NI
kdensity cost_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* Cost Kernel Density SE- NI
kdensity cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* Cost Kernel Density SE- BMW
kdensity cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* NM Kernel Density ROI- NI
kdensity nm_lu1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* NM Kernel Density BMW- NI
kdensity nm_lu1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* NM Kernel Density SE- NI
kdensity nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* NM Kernel Density SE- BMW
kdensity nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))


*******************************************************
* Per LT
*******************************************************
* lt_lu Kernel Density ROI- NI
kdensity lt_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* lt_lu Kernel Density BMW- NI
kdensity lt_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* lt_lu Kernel Density SE- NI
kdensity lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* lt_lu Kernel Density SE- BMW
kdensity lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* GO Kernel Density ROI- NI
kdensity fdairygo_lt if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* GO Kernel Density BMW- NI
kdensity fdairygo_lt if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* GO Kernel Density SE- NI
kdensity fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* GO Kernel Density SE- BMW
kdensity fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* Cost Kernel Density ROI- NI
kdensity cost_lt if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* Cost Kernel Density BMW- NI
kdensity cost_lt if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* Cost Kernel Density SE- NI
kdensity cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* Cost Kernel Density SE- BMW
kdensity cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* NM Kernel Density ROI- NI
kdensity nm_lt1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* NM Kernel Density BMW- NI
kdensity nm_lt1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* NM Kernel Density SE- NI
kdensity nm_lt1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* NM Kernel Density SE- BMW
kdensity nm_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

*******************************************************
* Per Labour Unit
*******************************************************

* labu_ha Kernel Density ROI- NI
kdensity labu_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* labu_ha Kernel Density BMW- NI
kdensity labu_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* labu_ha Kernel Density SE- NI
kdensity labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* labu_ha Kernel Density SE- BMW
kdensity labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* GO Kernel Density ROI- NI
kdensity fdairygo_labu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* GO Kernel Density BMW- NI
kdensity fdairygo_labu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* GO Kernel Density SE- NI
kdensity fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* GO Kernel Density SE- BMW
kdensity fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* Cost Kernel Density ROI- NI
kdensity cost_labu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* Cost Kernel Density BMW- NI
kdensity cost_labu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* Cost Kernel Density SE- NI
kdensity cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* Cost Kernel Density SE- BMW
kdensity cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))

* NM Kernel Density ROI- NI
kdensity nm_labu1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* NM Kernel Density BMW- NI
kdensity nm_labu1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* NM Kernel Density SE- NI
kdensity nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* NM Kernel Density SE- BMW
kdensity nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))


*******************************************************
* Per Labour Unit (Adjusted Price
*******************************************************

* NM Kernel Density ROI- NI
kdensity nm_labu_adj if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))

* NM Kernel Density BMW- NI
kdensity nm_labu_adj if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))

* NM Kernel Density SE- NI
kdensity nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))

* NM Kernel Density SE- BMW
kdensity nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
