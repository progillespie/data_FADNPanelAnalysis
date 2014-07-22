args BMWonly
matrix drop _all
mata: mata clear
version 9.0
clear
set more off
set matsize 4000

set mem 300m

local dir: pwd
local project = regexr("`dir'", "^.*[\\\/]" , "")

di "`project'"

local dodir "D:/Data\Data_FADNPanelAnalysis/Do_Files/`project'"
local outdatadir "../../OutData/`project'"
capture mkdir `outdatadir'/densities

cd "`dodir'"

* Data prep file, uncomment to run from raw data
*qui do sub_do/FADNprep.do standalone

if "`BMWonly'" == ""{
local BMWonly = 0
}

* All of the following must be looped over each of the data`filenumber'

local filenumber = 1
local cumulative_N = 0
while `filenumber' < 3{
	
	use `outdatadir'/data`filenumber', clear
	
	*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	*!!!! Temporary fix... Come back to this soon
	*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	replace feedforgrazinglivestock = fdgrzlvstk
	*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	


	*----------------------------------
	/* Remove outliers (these were extreme values observable on 
		scatterplots over time within each country  */
	*----------------------------------

	/*
	* High land, perm crops & quota -- 1 ob 
	drop if landpermananentcropsquotas > 10000000
	
	* High feedforgrazinglivestock -- 3 obs
	drop if feedforgrazinglivestock > 400000
	
	* High flabunpd --  1 ob
	drop if flabunpd > 10000 
	
	* Teenage farmers --  2 obs
	drop if ogagehld < 20
	*/


	//If left on, then slide tables are BMW - NI
	if `BMWonly'==1 {
		if country=="IRE" {

		gen  t_bmw = 0
		replace t_bmw = 1 if subregion == 2 
		keep if t_bmw == 1 
		drop t_bmw

		}
	}



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
		 if year>=2007 [weight=wt] 

	/*-- TURNED OFF ------------------
	* Same data exported to Excel
	preserve

	collapse year			    ///
		 dairycows 		    ///
		 othercattlelus		    ///
		 totaluaa 		    ///
		 daforare 		    ///
		 stockingdensity 	    ///
		 totlab_cow 		    ///
		 milkyield 		    ///
		 if year==2008 [weight=wt], by(country)

	local cumulative_N = `cumulative_N' + _N
	di `cumulative_N'
	local rownumber = 1 + `cumulative_N'
	export excel using 			            ///
	 `outdatadir'/simplified.xlsx, 	        	    ///
	sheet("slide 11")			            ///
	cell(A`rownumber')			            ///
	sheetmodify

	restore
	---- BACK ON --------------------*/


	*----------------------------------
	* Proportions of farmers by age (slide 12)
	*----------------------------------
	preserve

	do dy_sub_do/age.do

	/*-- TURNED OFF ------------------

	export excel using 			 ///
	    `outdatadir'/simplified.xlsx,        /// 
	    sheet("slide 12 (data`filenumber')") /// 
	    cell(A2)                             /// 
	    firstrow(variables)                  /// 
	    sheetmodify

	---- BACK ON --------------------*/

	restore

	*----------------------------------
	* Differences in Farm Financials (slide 13)
	*----------------------------------
	preserve

	do dy_sub_do/fin_farm.do
	
	/*-- TURNED OFF ------------------

	export excel using                      /// 
	   `outdatadir'/simplified.xlsx,        /// 
	   sheet("slide 13 (data`filenumber')") /// 
	   cell(A2)                             /// 
	   firstrow(variables)                  /// 
	   sheetmodify

	---- BACK ON --------------------*/
	restore
	

	*----------------------------------
	* Gross margin per litre cost groups (slide 14)
	*----------------------------------

	replace fdairygm = fdairygo - fdairydc
	gen fdairytct_lt = fdairytct/dotomkgl
	
	/*-----------------------------------------------
	 P.Gillespie:
	  Create cost groupings in this format: yyyy_g 
	   (i.e. 4 digit year then group number). This
	   format allows you to easily collapse the 
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
	
	*----------------------------------
	* Create a csv with 3 rows per year (one per group) with group totals 
	* per unit measures.
	*----------------------------------
	
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
	
	/*-- TURNED OFF ------------------

	export excel using 			         ///
	 `outdatadir'/simplified.xlsx		         ///
	 if year == 2007,			         ///
	sheet("slide 14 (data`filenumber')")             ///
	cell(A2)				         ///
	firstrow(variables)			         ///
	sheetmodify
		
	---- BACK ON --------------------*/
	
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

	gen othct = 		///
	   seedsandplants     + ///
	   cropprotection     +	///
	   othercropspecific  +	///
	   forestryspecificcosts

	collapse year totalspecificcosts fdgrzlvstk fertilisers ///
		 otherlivestocksp othct daforare dotomkgl 	///
		 dpnolu flabunpd 				///
		  if year>=2007, by(country)


	* suffix for naming vars in following loop
	local suffix_list ""
	local suffix_list  "`suffix_list ' pct"
	local suffix_list  "`suffix_list ' ha"
	local suffix_list  "`suffix_list ' lt"
	local suffix_list  "`suffix_list ' lu"
	local suffix_list  "`suffix_list ' labu"


	foreach suffix of local suffix_list {

	   * choose correct denominator based on suffix
	   if "`suffix'" == "pct"{
	   local denom "totalspecificcosts"
	   }
	   if "`suffix'" == "ha"{
	   local denom "daforare"
	   }
	   if "`suffix'" == "lt"{
	   local denom "dotomkgl" //dosmkgl
	   }
	   if "`suffix'" == "lu"{
	   local denom "dpnolu"
	   }
	   if "`suffix'" == "labu"{
	   local denom "flabunpd"
	   }
	   
	   gen fdgrz_`suffix' = fdgrzlvstk/`denom'
	   label var fdgrz_`suffix' "Feed"

	   gen fert_`suffix' = fertilisers/`denom'
	   label var fert_`suffix' "Fertilser"

	   gen othlvstk_`suffix' = otherlivestockspecific/`denom'
	   label var othlvstk_`suffix' "Other Livestock Costs"

	   gen othct_`suffix' = othct/`denom'
	   label var othct_`suffix' "Other Costs"
	   
	   capture drop rowname
	   gen rowname = "`suffix'"

	   mkmat fdgrz_`suffix'                         ///
		     fert_`suffix'                      ///
		     othlvstk_`suffix'                  ///
		     othct_`suffix'                     ///
		     , matrix(`suffix')                 ///
		       rownames(rowname) 
	   matrix `suffix'`filenumber' = [`suffix'']
	   matrix drop `suffix'
	}	
	

	matrix DC`filenumber' = [pct`filenumber', ha`filenumber', lt`filenumber', lu`filenumber', labu`filenumber']

	/*-- TURNED OFF ------------------

	local rownumber2 = 2 + `filenumber'
	local suffix "pct"
	export excel country fdgrz_`suffix'         	  ///
		     fert_`suffix'                        /// 
		     othlvstk_`suffix'                    /// 
		     othct_`suffix'                       /// 
		     using  `outdatadir'/simplified.xlsx, /// 
		     sheet("slide 15")                    /// 
		     cell(A`rownumber2')                  /// 
		     sheetmodify

	---- BACK ON --------------------*/

	restore	

	local filenumber = `filenumber' + 1 
}	

local filenumber = 1
use data`filenumber'_out.dta, clear
gen cntry = 1
local filenumber = 2
qui append using data`filenumber'_out.dta
replace cntry = 2 if cntry == .



*----------------------------------
* Impute costs and allocate to enterprise
*----------------------------------

*--Creates imputed costs for unpaid family factors 
do sub_do/FADNimputemethod.do     

*--Allocates costs to dairy enterprise 
do sub_do/FADNallocationmethod.do 


*----------------------------------
* Tables
*----------------------------------

/* If selecting just BMW in Ireland, then stick "bmw" in logfile 
    names. Now you won't overwrite logs for whole Ireland dataset. */
if `BMWonly'==1 {
	local bmwarg = "bmw"
}


* "bmw" passed into do files via args command. (See help file for args)
do sub_do/cex_vargen.do      `bmwarg' 	// variables for cex_ do-files

/*-- TURNED OFF ------------------

do sub_do/cex_decomp.do      `bmwarg' 	// cex is short for... 
do sub_do/cex_decomp_lt.do   `bmwarg'  	//  "Constant exchange rate adjustment"
do sub_do/cex_decomp_lu.do   `bmwarg'  	//
do sub_do/cex_decomp_ha.do   `bmwarg'  	// decomp is short for... 
do sub_do/cex_decomp_labu.do `bmwarg'  	//  "Decomposition into components"
do sub_do/cex_godecomp.do    `bmwarg'  	//  GO decomp (farm level only)

/* NOTE: 
The exchange rate adjustment is not constant in the most recent version. 
 It now just replaces the 08 and 09 exchange rates with rates that 
 follow a simple linear trend estimated from 99 to 07 (which are left
        as is).  */

---- BACK ON --------------------*/

replace fdairygo = cex_fdairygo
replace fdairydc = cex_fdairydc 
replace fdairyoh = cex_fdairyoh
replace fdairyec = cex_fdairyec

gen cex_wages = wages*exchangerate/cex


gen hrs_lu = labourinputhours/totallivestockunits



local structuralvars = "`structuralvars' dpnolu"
local structuralvars = "`structuralvars' othercattlelus"
local structuralvars = "`structuralvars' totaluaa"
local structuralvars = "`structuralvars' daforare"
local structuralvars = "`structuralvars' stockingdensity"
local structuralvars = "`structuralvars' hrs_lu"
local structuralvars = "`structuralvars' milkyield"
local structuralvars = "`structuralvars' ogagehld"
local  i = 1
matrix TTESTS = (0 , 0)

tabstat `structuralvars' [weight=wt], by(country)

* Do t tests for each var in the table and store t-stat in a matrix
foreach var of local structuralvars{
	ttest `var'	   	    , by(country) unequal
	matrix TTESTS = (TTESTS \ `r(t)', round(`r(p)', .001))
	local i	= `i'+1
}
matrix TTESTS = TTESTS[2..`i',1..2]
* Label the rows and the single column of the t-test matrix
matrix rownames TTESTS = `structuralvars'
matrix colnames TTESTS = t-stat p-value


matrix list TTESTS






*----------------------------------
* Do Comparative Analysis
*----------------------------------

* Stocking Rate
capture gen lu_ha = dpnolu/daforare

* Labour units
capture gen labu_ha = flabunpd/daforare

* Yield
capture gen lt_lu = dotomkgl/dpnolu

* Milk Price (fdairygo is just milk anyway, and it has the cex correction if applied)
gen milk_price = fdairygo/dotomkgl

*Gross Output
gen fdairygo_ha = fdairygo/daforare
capture drop fdairygo_lu
gen fdairygo_lu = fdairygo/dpnolu
gen fdairygo_labu = fdairygo/flabunpd
capture drop fdairygo_lt
gen fdairygo_lt = fdairygo/dotomkgl

* Costs
gen fdairydc_lt = fdairydc/dotomkgl
gen fdairydc_lu = fdairydc/dpnolu
gen fdairydc_ha = fdairydc/daforare
gen fdairydc_labu = fdairydc/flabunpd

gen fdairyoh_lt = fdairyoh/dotomkgl
gen fdairyoh_lu = fdairyoh/dpnolu
gen fdairyoh_ha = fdairyoh/daforare
gen fdairyoh_labu = fdairyoh/flabunpd

gen cost_lt =  fdairydc_lt+ fdairyoh_lt
gen cost_lu =  (fdairydc + fdairyoh)/dpnolu
gen cost_ha =  (fdairydc + fdairyoh)/daforare
gen cost_labu =  (fdairydc + fdairyoh)/flabunpd

gen rentrateha      = rentpaid/renteduaa
gen ownlandpct    = (totaluaa-renteduaa)/totaluaa
gen ownlandha     = daforare*ownlandpct
gen ownlandval    = ownlandha*rentrateha

* Margin
gen fdairynm    = fdairygm - fdairyoh
gen fdairynm_lt = fdairygm/dotomkgl - fdairyoh_lt
gen fdairygm_lt = fdairygm/dotomkgl
gen fdairygm_labu = fdairygm/flabunpd

gen nm_lt1 = fdairynm_lt
gen nm_lu1 = (fdairygm - fdairyoh)/dpnolu
gen nm_ha1 = (fdairygm - fdairyoh)/daforare
gen nm_labu1 = (fdairygm - fdairyoh)/flabunpd
gen nm_labu1_land = (fdairygm - fdairyoh-ownlandval)/flabunpd

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

* Make IE milk prices like NI

gen fdairygo_adj = fdairygo 

foreach yr of local yr_list {
	qui replace fdairygo_adj = fdairygo_adj*av_fdairygo_lt`yr'_2/av_fdairygo_lt`yr'_1 if year == `yr' & cntry == 1
}

gen fdairygo_lt_adj = fdairygo_adj/doslmkgl
gen fdairygo_lu_adj = fdairygo_adj/dpnolu
gen fdairygo_ha_adj = fdairygo_adj/daforare
gen fdairygo_labu_adj = fdairygo_adj/flabunpd

gen fdairyoh_land    = fdairyoh - ownlandval
gen fdairyoh_lt_land = fdairyoh_land/doslmkgl
gen fdairyoh_lu_land = fdairyoh_land/dpnolu
gen fdairyoh_ha_land = fdairyoh_land/daforare
gen fdairyoh_labu_land = fdairyoh_land/flabunpd

gen nm_lt_adj   = (fdairygo_adj - fdairydc - fdairyoh)/doslmkgl
gen nm_lu_adj   = (fdairygo_adj - fdairydc - fdairyoh)/dpnolu
gen nm_ha_adj   = (fdairygo_adj - fdairydc - fdairyoh)/daforare
gen nm_labu_adj = (fdairygo_adj - fdairydc - fdairyoh)/flabunpd

gen nem_lt_adj   = (fdairygo_adj - fdairydc - ///
                    fdairyoh - fdairyec)/doslmkgl
gen nem_lu_adj   = (fdairygo_adj - fdairydc - ///
                    fdairyoh - fdairyec)/dpnolu
gen nem_ha_adj   = (fdairygo_adj - fdairydc - ///
                    fdairyoh - fdairyec)/daforare
gen nem_labu_adj = (fdairygo_adj - fdairydc - ///
                    fdairyoh - fdairyec)/flabunpd

gen nm_lt_adj_land    = (fdairygo_adj - fdairydc - fdairyoh - ownlandval)/doslmkgl
gen nm_lu_adj_land    = (fdairygo_adj - fdairydc - fdairyoh - ownlandval)/dpnolu
gen nm_ha_adj_land    = (fdairygo_adj - fdairydc - fdairyoh - ownlandval)/daforare
gen nm_labu_adj_land = (fdairygo_adj - fdairydc - fdairyoh - ownlandval)/flabunpd

* REMINDER: cex_ variables and cex are defined in sub_do/cex_vargen.do
gen cex_ownlandval   = ownlandval*exchangerate/cex
gen cex_nm_lt_land   = (cex_fdairygo - cex_fdairydc - cex_fdairyoh - cex_ownlandval)/dotomkgl
gen cex_nm_lu_land   = (cex_fdairygo - cex_fdairydc - cex_fdairyoh - cex_ownlandval)/dpnolu
gen cex_nm_ha_land   = (cex_fdairygo - cex_fdairydc - cex_fdairyoh - cex_ownlandval)/daforare
gen cex_nm_labu_land = (cex_fdairygo - cex_fdairydc - cex_fdairyoh - cex_ownlandval)/flabunpd




* BMW region and SE region dummies 
gen bmw = cntry == 1 & subregion == 2
gen se  = cntry == 1 & subregion == 1


* Examine land ownership, impute opportunity cost of land, return matrices
*qui do sub_do/landownership.do


* Only do the following if BMWonly is turned off
if `BMWonly'==0 {

/*-- TURNED OFF ------------------

	*******************************************************
	* Per Ha
	*******************************************************
	*---------------------------------
	* Using daforare 
	*---------------------------------
	* daforare Kernel Density IE- NI
	kdensity daforare if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_daforare_IE.wmf, replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov daforare if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

	* daforare Kernel Density BMW- NI
	kdensity daforare if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_daforare_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov daforare if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* daforare Kernel Density SE- NI
	kdensity daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_daforare_SENI.wmf, replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* daforare Kernel Density SE- BMW
	kdensity daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_daforare_SEBMW.wmf, replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov daforare if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	*---------------------------------
	* Using fdairygo_ha 
	*---------------------------------
	* GO Kernel Density IE- NI
	kdensity fdairygo_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_ha_IE.wmf, replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov fdairygo_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density BMW- NI
	kdensity fdairygo_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_ha_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov fdairygo_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- NI
	kdensity fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_ha_SENI.wmf, replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- BMW
	kdensity fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_ha_SEBMW.wmf, replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov fdairygo_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	*---------------------------------
	* Using cost_ha 
	*---------------------------------
	* Cost Kernel Density IE- NI
	kdensity cost_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_cost_ha_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov cost_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density BMW- NI
	kdensity cost_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_cost_ha_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov cost_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- NI
	kdensity cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_ha_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- BMW
	kdensity cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_ha_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov cost_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	*---------------------------------
	* Using nm_ha1 
	*---------------------------------
	* NM Kernel Density IE- NI
	kdensity nm_ha1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_nm_ha1_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_ha1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity nm_ha1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_nm_ha1_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_ha1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_ha1_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_ha1_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov nm_ha1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	
	
	
	*******************************************************
	* Per LU
	*******************************************************
	*---------------------------------
	* Using lu_ha 
	*---------------------------------
	* lu_ha Kernel Density IE- NI
	kdensity lu_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_lu_ha_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov lu_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* lu_ha Kernel Density BMW- NI
	kdensity lu_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_lu_ha_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov lu_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* lu_ha Kernel Density SE- NI
	kdensity lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_lu_ha_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* lu_ha Kernel Density SE- BMW
	kdensity lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_lu_ha_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov lu_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	*---------------------------------
	* Using fdairygo_lu 
	*---------------------------------
	* GO Kernel Density IE- NI
	kdensity fdairygo_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lu_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov fdairygo_lu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density BMW- NI
	kdensity fdairygo_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lu_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov fdairygo_lu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- NI
	kdensity fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lu_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- BMW
	kdensity fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lu_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov fdairygo_lu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	*---------------------------------
	* Using cost_lu 
	*---------------------------------
	* Cost Kernel Density IE- NI
	kdensity cost_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_cost_lu_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov cost_lu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density BMW- NI
	kdensity cost_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_cost_lu_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov cost_lu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- NI
	kdensity cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_lu_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- BMW
	kdensity cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_lu_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov cost_lu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	*---------------------------------
	* Using nm_lu1 
	*---------------------------------
	* NM Kernel Density IE- NI
	kdensity nm_lu1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_nm_lu1_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_lu1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity nm_lu1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_nm_lu1_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_lu1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_lu1_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_lu1_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov nm_lu1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	
	
	
	*******************************************************
	* Per LT
	*******************************************************
	*---------------------------------
	* Using lt_lu 
	*---------------------------------
	* lt_lu Kernel Density IE- NI
	kdensity lt_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_lt_lu_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov lt_lu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* lt_lu Kernel Density BMW- NI
	kdensity lt_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_lt_lu_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov lt_lu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* lt_lu Kernel Density SE- NI
	kdensity lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_lt_lu_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* lt_lu Kernel Density SE- BMW
	kdensity lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_lt_lu_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov lt_lu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	

	*---------------------------------
	* Using fdairygo_lt 
	*---------------------------------
	* GO Kernel Density IE- NI
	kdensity fdairygo_lt if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lt_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov fdairygo_lt if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density BMW- NI
	kdensity fdairygo_lt if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lt_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov fdairygo_lt if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- NI
	kdensity fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lt_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- BMW
	kdensity fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_lt_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov fdairygo_lt if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	

	*---------------------------------
	* Using cost_lt 
	*---------------------------------
	* Cost Kernel Density IE- NI
	kdensity cost_lt if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_cost_lt_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov cost_lt if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density BMW- NI
	kdensity cost_lt if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_cost_lt_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov cost_lt if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- NI
	kdensity cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_lt_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- BMW
	kdensity cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_lt_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW) ksmirnov cost_lt if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	

	*---------------------------------
	* Using nm_lt1 
	*---------------------------------
	* NM Kernel Density IE- NI
	kdensity nm_lt1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_nm_lt1_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_lt1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity nm_lt1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_nm_lt1_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_lt1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity nm_lt1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_lt1_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov nm_lt1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity nm_lt1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_lt1_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov nm_lt1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	
	
	
	*******************************************************
	* Per Labour Unit
	*******************************************************
	*---------------------------------
	* Using labu_ha 
	*---------------------------------
	* labu_ha Kernel Density IE- NI
	kdensity labu_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_labu_ha_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov labu_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* labu_ha Kernel Density BMW- NI
	kdensity labu_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_labu_ha_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov labu_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* labu_ha Kernel Density SE- NI 
	kdensity labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_labu_ha_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* labu_ha Kernel Density SE- BMW
	kdensity labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_labu_ha_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov labu_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	

	*---------------------------------
	* Using fdairygo_labu 
	*---------------------------------
	* GO Kernel Density IE- NI
	kdensity fdairygo_labu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_labu_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov fdairygo_labu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density BMW- NI
	kdensity fdairygo_labu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_labu_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov fdairygo_labu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- NI
	kdensity fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_labu_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* GO Kernel Density SE- BMW
	kdensity fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_fdairygo_labu_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov fdairygo_labu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	

	*---------------------------------
	* Using cost_labu 
	*---------------------------------
	* Cost Kernel Density IE- NI
	kdensity cost_labu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_cost_labu_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov cost_labu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density BMW- NI
	kdensity cost_labu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_cost_labu_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov cost_labu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- NI
	kdensity cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_labu_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* Cost Kernel Density SE- BMW
	kdensity cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_cost_labu_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov cost_labu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	

	*---------------------------------
	* Using nm_labu1 
	*---------------------------------
	* NM Kernel Density IE- NI
	kdensity nm_labu1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu1_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_labu1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity nm_labu1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu1_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_labu1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu1_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu1_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov nm_labu1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	
	
	
	*******************************************************
	* Per Labour Unit (Adjusted Price)
	*******************************************************
	*---------------------------------
	* Using nm_labu_adj
	*---------------------------------
	* NM Kernel Density IE- NI
	kdensity nm_labu_adj if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu_adj_IE.wmf , replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_labu_adj if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity nm_labu_adj if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu_adj_BMW.wmf , replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_labu_adj if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu_adj_SENI.wmf , replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
	graph export `outdatadir'/densities/kden_nm_labu_adj_SEBMW.wmf , replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov nm_labu_adj if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	

	*---------------------------------
	* Using nm_labu1_land
	*---------------------------------
	* NM Kernel Density IE- NI
	kdensity nm_labu1_land if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu1_land_IE.wmf, replace
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_labu1_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity nm_labu1_land if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu1_land_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_labu1_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity nm_labu1_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))  scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu1_land_SENI.wmf, replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov nm_labu1_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity nm_labu1_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu1_land_SEBMW.wmf, replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov nm_labu1_land if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	






	*---------------------------------
	* Using nm_labu_adj_land
	*---------------------------------
	* NM Kernel Density IE- NI
	kdensity nm_labu_adj_land if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_adj_land_IE.wmf, replace  
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_labu_adj_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity nm_labu_adj_land if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_adj_land_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_labu_adj_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity nm_labu_adj_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_adj_land_SENI.wmf, replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov nm_labu_adj_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity nm_labu_adj_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_adj_land_SEBMW.wmf, replace
	 *select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov nm_labu_adj_land if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	
	
---- BACK ON --------------------*/










/*-- TURNED OFF ------------------
	
	*******************************************************
	* Rent paid per hectare rented
	*******************************************************
	
	* NM Kernel Density IE- NI
	kdensity rentrateha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_rentrateha_IE.wmf, replace  
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov rentrateha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI
	kdensity rentrateha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_rentrateha_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov rentrateha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI
	kdensity rentrateha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_rentrateha_SENI.wmf, replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov rentrateha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW
	kdensity rentrateha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_rentrateha_SEBMW.wmf, replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov rentrateha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	
	
	
	
	
	*******************************************************
	* Imputed value of owned land
	*******************************************************
	
	* NM Kernel Density IE- NI 
	kdensity ownlandval if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_ownlandval_IE.wmf, replace  
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov ownlandval if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density BMW- NI 
	kdensity ownlandval if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_ownlandval_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov ownlandval if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- NI 
	kdensity ownlandval if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_ownlandval_SENI.wmf, replace
	* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
	ksmirnov ownlandval if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 
	
	* NM Kernel Density SE- BMW 
	kdensity ownlandval if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_ownlandval_SEBMW.wmf, replace
	* select farms in IE in 2008 (SE, BMW), compare by country (in effect SE to BMW)
	ksmirnov ownlandval if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 
	

---- BACK ON --------------------*/
	


















/*-- TURNED OFF ------------------
	/* 
	Get price and quantity effects. Do file takes the following arguments 
	
		yourprice yourquantity youroutput ID time weight

	The last three arguments have the following default values if left 
	unspecified. 
	
			farmcode	 year 	wt
			
	which is appropriate for this dataset.
	*/

	* Get price and quantity effects for gross output
	capture drop milkprice
	gen milkprice = fdairygo/dotomkgl
	qui do sub_do/pqeffects.do milkprice dotomkgl fdairygo
	matrix rename A PQeffGO`filenumber'
	
	* Get price and quantity effects for total cost (quantity still refers to output)
	capture drop inputprice
	gen inputprice = totalinputs/dotomkgl
	qui do sub_do/pqeffects.do inputprice dotomkgl totalinputs 
	matrix rename A PQeffCT`filenumber'
---- BACK ON --------------------*/


}






/*-- TURNED OFF ------------------


*----------------------------------
* Dispay matrices
*----------------------------------

* Display mata matrices. No need to enter mata environment.
mata:OWN
mata:TOTAL
mata:PCT
mata:IE
mata:NI

* Display Stata matrices (more descriptive and more relevant)
matrix list LAND_IE 
matrix list LAND_NI
matrix list LANDdiff
matrix list DC1
matrix list DC2
matrix list DCdiff

* Get rid of matrices when done with them
*matrix drop _all // For Stata matrices
*mata:mata clear  // For mata matrices


---- BACK ON --------------------*/





/*-- TURNED OFF ------------------

* IE vs. NI
	* NM Kernel Density IE- NI (adjusted milk price)
	kdensity nm_labu_adj_land if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_adj_land_IE.wmf, replace  
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_labu_adj_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 


	* NM Kernel Density IE- NI (all exchange rate adjusted)
	kdensity cex_nm_labu_land if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "IE") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_cex_land_IE.wmf, replace  
	* select all farms in 2008 (SE, BMW, NI), compare by country (IE = SE + BMW to  NI)
	ksmirnov nm_labu_adj_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

*BMW vs. NI
	* NM Kernel Density (adjusted milk price)
	kdensity nm_labu_adj_land if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_adj_land_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_labu_adj_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

	* NM Kernel Density (all exchange rate adjusted)
	kdensity cex_nm_labu_land if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
	graph export `outdatadir'/densities/kden_nm_labu_cex_land_BMW.wmf, replace
	* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
	ksmirnov nm_labu_adj_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

capture graph drop _all 
	

	matrix KSdaforare = 0
	matrix KSdaforare = (KSdaforare \ `r(p_cor)' )	
	matrix rownames KSdaforare = "IE - NI"
	matrix colnames KSdaforare = "Corrected Combine p-value"

---- BACK ON --------------------*/


*******************************************************
* Chow tests*  
*******************************************************
gen ie = country=="IRE"
gen ni = country=="UKI"

capture drop lndotomkgl
capture drop lnlandval_ha   
capture drop lnfdferfil_ha
capture drop lndaforare_lu   
capture drop lnfdgrzlvstk_lu   
capture drop lnflabpaid_lu     
capture drop lnflabunpd_lu     
*ogagehld is not logged
capture drop lnfsizuaa     
*hasreps is not logged 
capture drop lnmin_temp     
*azone2 is not logged 




drop if  landval_ha    <= 0
drop if  fdferfil_ha   <= 0
drop if  daforare_lu   <= 0
drop if  fdgrzlvstk_lu <= 0
drop if  flabunpd_lu   <= 0
drop if  fsizuaa       <= 0
drop if  min_temp      <= 0

/* Lose a lot of the sample if we drop 0's for paid labour
     but we can set equal to 1 paid hour p.a. for these farms*/
replace flabpaid = 1 if  flabpaid_lu   <= 0


gen lndotomkgl 	      = ln(dotomkgl)
gen lnlandval_ha      = ln(landval_ha)
gen lnfdferfil_ha     = ln(fdferfil_ha)
gen lndaforare_lu     = ln(daforare_lu)
gen lnfdgrzlvstk_lu   = ln(fdgrzlvstk_lu)
gen lnflabpaid_lu     = ln(flabpaid_lu)
gen lnflabunpd_lu     = ln(flabunpd_lu)
*ogagehld is not logged
gen lnfsizuaa         = ln(fsizuaa)
*hasreps is not logged
gen lnmin_temp        = ln(min_temp)
*azone2 is not logged
     

gen lnlandval_ha_ni    = lnlandval_ha      * ni
gen lnfdferfil_ha_ni   = lnfdferfil_ha     * ni
gen lndaforare_lu_ni   = lndaforare_lu     * ni
gen lnfdgrzlvstk_lu_ni = lnfdgrzlvstk_lu   * ni
gen lnflabpaid_lu_ni   = lnflabpaid_lu     * ni
gen lnflabunpd_lu_ni   = lnflabunpd_lu     * ni
gen ogagehld_ni        = ogagehld          * ni
gen lnfsizuaa_ni       = lnfsizuaa         * ni
gen hasreps_ni         = hasreps           * ni
gen lnmin_temp_ni      = lnmin_temp        * ni
gen azone2_ni 	       = azone2            * ni




* Irish time invariant SF model
xtfrontier 	lndotomkgl	///
	lnlandval_ha		///
	lnfdferfil_ha		///
	lndaforare_lu		///
	lnfdgrzlvstk_lu		///
	lnflabpaid_lu		///
	lnflabunpd_lu		///
	ogagehld		///
	lnfsizuaa		///
	hasreps			///
	lnmin_temp		///
	azone2			///
	if country == "IRE"     ///
	, ti


* N. Irish time invariant SF model
xtfrontier 	lndotomkg	///
	lnlandval_ha		///
	lnfdferfil_ha		///
	lndaforare_lu		///
	lnfdgrzlvstk_lu		///
	lnflabpaid_lu		///
	lnflabunpd_lu		///
	ogagehld		///
	lnfsizuaa		///
	hasreps			///
	lnmin_temp		///
	azone2			///
	if country == "UKI"     ///
	, ti


* Interacted model for Chow tests
qui xtfrontier 	lndotomkgl	///
	lnlandval_ha		///
	lnfdferfil_ha		///
	lndaforare_lu		///
	lnfdgrzlvstk_lu		///
	lnflabpaid_lu		///
	lnflabunpd_lu		///
	ogagehld		///
	lnfsizuaa		///
	hasreps			///
	lnmin_temp		///
	azone2			///
	lnlandval_ha_ni		///
	lnfdferfil_ha_ni	///
	lndaforare_lu_ni	///
	lnfdgrzlvstk_lu_ni	///
	lnflabpaid_lu_ni	///
	lnflabunpd_lu_ni	///
	ogagehld_ni		///
	lnfsizuaa_ni		///
	hasreps_ni		///
	lnmin_temp_ni		///
	azone2_ni		///
	ni		        ///
	, ti 



* Individual parameter tests
testparm lnlandval_ha_ni
testparm lnfdferfil_ha_ni
testparm lndaforare_lu_ni
testparm lnfdgrzlvstk_lu_ni
testparm lnflabpaid_lu_ni
testparm lnflabunpd_lu_ni
testparm ogagehld_ni
testparm lnfsizuaa_ni
testparm hasreps_ni
testparm lnmin_temp_ni
testparm azone2_ni
testparm ni



* Joint test
testparm 			///
	lnlandval_ha_ni		///
	lnfdferfil_ha_ni	///
	lndaforare_lu_ni	///
	lnfdgrzlvstk_lu_ni	///
	lnflabpaid_lu_ni	///
	lnflabunpd_lu_ni	///
	ogagehld_ni		///
	lnfsizuaa_ni		///
	hasreps_ni		///
	lnmin_temp_ni		///
	azone2_ni		///
	ni




*******************************************************
* K-S tests*  Per Labour Unit (no price adjustment)
*******************************************************

*---------------------------------
* Using nm_labu1 
*---------------------------------

local var "nm_labu1"
matrix KS_`var' = (0, 0)
matrix TT_`var' = (0, 0)
local i = 0
foreach yr of local yr_list{
	
	local j = 1 
	while `j' < 3{
	   matrix KSROW = (0,0)
	   matrix TTROW = (0,0)
	   * NM K-S and T tests IE- NI
	   qui ksmirnov `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,1] = round(`r(p_cor)',.001)
	   qui ttest `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,1] = round(`r(p)',.001)
	
	   * NM K-S and T tests BMW- NI
	   qui ksmirnov `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,2] = round(`r(p_cor)',.001)
	   qui ttest `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,2] = round(`r(p)',.001)

	   local j = `j' + 1
	}
	
	matrix KS_`var' = (KS_`var' \ KSROW)
	matrix TT_`var' = (TT_`var' \ TTROW)
	local i = `i' + 1
}
local i = `i' + 1
matrix KS_`var' = KS_`var'[2..`i', 1..2]
matrix TT_`var' = TT_`var'[2..`i', 1..2]
matrix rownames KS_`var' = `yr_list'
matrix colnames KS_`var' = "IE - NI" "BMW - NI"
matrix rownames TT_`var' = `yr_list'
matrix colnames TT_`var' = "IE - NI" "BMW - NI"



*******************************************************
* K-S tests*  Per Labour Unit (Adjusted Price)
*******************************************************
*---------------------------------
* Using nm_labu_adj
*---------------------------------
local var "nm_labu_adj"
matrix KS_`var' = (0, 0)
matrix TT_`var' = (0, 0)
local i = 0
foreach yr of local yr_list{
	
	local j = 1 
	while `j' < 3{
	   matrix KSROW = (0,0)
	   matrix TTROW = (0,0)
	   * NM K-S and T tests IE- NI
	   qui ksmirnov `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,1] = round(`r(p_cor)',.001)
	   qui ttest `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,1] = round(`r(p)',.001)
	
	   * NM K-S and T tests BMW- NI
	   qui ksmirnov `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,2] = round(`r(p_cor)',.001)
	   qui ttest `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,2] = round(`r(p)',.001)

	   local j = `j' + 1
	}
	
	matrix KS_`var' = (KS_`var' \ KSROW)
	matrix TT_`var' = (TT_`var' \ TTROW)
	local i = `i' + 1
}
local i = `i' + 1
matrix KS_`var' = KS_`var'[2..`i', 1..2]
matrix TT_`var' = TT_`var'[2..`i', 1..2]
matrix rownames KS_`var' = `yr_list'
matrix colnames KS_`var' = "IE - NI" "BMW - NI"
matrix rownames TT_`var' = `yr_list'
matrix colnames TT_`var' = "IE - NI" "BMW - NI"





*---------------------------------
* Using nm_labu1_land
*---------------------------------
local var "nm_labu1_land"
matrix KS_`var' = (0, 0)
matrix TT_`var' = (0, 0)
local i = 0
foreach yr of local yr_list{
	
	local j = 1 
	while `j' < 3{
	   matrix KSROW = (0,0)
	   matrix TTROW = (0,0)
	   * NM K-S and T tests IE- NI
	   qui ksmirnov `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,1] = round(`r(p_cor)',.001)
	   qui ttest `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,1] = round(`r(p)',.001)
	
	   * NM K-S and T tests BMW- NI
	   qui ksmirnov `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,2] = round(`r(p_cor)',.001)
	   qui ttest `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,2] = round(`r(p)',.001)

	   local j = `j' + 1
	}
	
	matrix KS_`var' = (KS_`var' \ KSROW)
	matrix TT_`var' = (TT_`var' \ TTROW)
	local i = `i' + 1
}
local i = `i' + 1
matrix KS_`var' = KS_`var'[2..`i', 1..2]
matrix TT_`var' = TT_`var'[2..`i', 1..2]
matrix rownames KS_`var' = `yr_list'
matrix colnames KS_`var' = "IE - NI" "BMW - NI"
matrix rownames TT_`var' = `yr_list'
matrix colnames TT_`var' = "IE - NI" "BMW - NI"



*---------------------------------
* Using nm_labu_adj_land
*---------------------------------
local var "nm_labu_adj_land"
matrix KS_`var' = (0, 0)
matrix TT_`var' = (0, 0)
local i = 0
foreach yr of local yr_list{
	
	local j = 1 
	while `j' < 3{
	   matrix KSROW = (0,0)
	   matrix TTROW = (0,0)
	   * NM K-S and T tests IE- NI
	   qui ksmirnov `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,1] = round(`r(p_cor)',.001)
	   qui ttest `var' if year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,1] = round(`r(p)',.001)
	
	   * NM K-S and T tests BMW- NI
	   qui ksmirnov `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
	   matrix KSROW[1,2] = round(`r(p_cor)',.001)
	   qui ttest `var' if se == 0 & year == `yr' & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) unequal
	   matrix TTROW[1,2] = round(`r(p)',.001)

	   local j = `j' + 1
	}
	
	matrix KS_`var' = (KS_`var' \ KSROW)
	matrix TT_`var' = (TT_`var' \ TTROW)
	local i = `i' + 1
}
local i = `i' + 1
matrix KS_`var' = KS_`var'[2..`i', 1..2]
matrix TT_`var' = TT_`var'[2..`i', 1..2]
matrix rownames KS_`var' = `yr_list'
matrix colnames KS_`var' = "IE - NI" "BMW - NI"
matrix rownames TT_`var' = `yr_list'
matrix colnames TT_`var' = "IE - NI" "BMW - NI"





foreach var of varlist nm_labu1  nm_labu_adj  nm_labu1_land  nm_labu_adj_land{
	matrix list KS_`var'
	matrix list TT_`var'

}


* Kernel density plot - all years (cut and paste onto command line)

*kdensity nm_labu_adj_land if cntry == 1  & nm_labu_adj_land > -10 & nm_labu_adj_land < 30  , plot(kdensity nm_labu_adj_land if cntry == 2 &  nm_labu_adj_land > -10 & nm_labu_adj_land < 30  || kdensity nm_labu_adj_land if bmw == 1 & nm_labu_adj_land > -10 & nm_labu_adj_land < 30 ) title("") xtitle("Euro/hour") legend(label(1 "IE") label(2 "NI") label(3 "BMW") rows(1)) saving(adj_land.gph, replace) name("adj_land") scheme("s2mono")

*kdensity nm_labu1 if cntry == 1  & nm_labu1 > -10 & nm_labu1 < 30  , plot(kdensity nm_labu1 if cntry == 2 &  nm_labu1 > -10 & nm_labu1 < 30  || kdensity nm_labu1 if bmw == 1 & nm_labu1 > -10 & nm_labu1 < 30 ) title("") xtitle("Euro/hour") legend(label(1 "IE") label(2 "NI") label(3 "BMW") rows(1)) saving(labu1.gph, replace) name("labu1") scheme("s2mono")

*kdensity nm_labu1 if cntry == 1  & nm_labu1 > -10 & nm_labu1 < 30  , plot(kdensity nm_labu1 if cntry == 2 &  nm_labu1 > -10 & nm_labu1 < 30  || kdensity nm_labu1 if bmw == 1 & nm_labu1 > -10 & nm_labu1 < 30 ) legend(off) title("") xtitle("")  note("") saving("labu1.gph", replace) name("labu1")

*graph combine labu1 adj_land, cols(1) xcom ycom commonscheme scheme("s2mono")  title("Net margin per hour") sub("Scenario 1 - Top, Scenario 4 - Bottom")

*kdensity nm_labu_adj_land if cntry == 1  & nm_labu_adj_land > -10 & nm_labu_adj_land < 30  , plot(kdensity nm_labu_adj_land if cntry == 2 &  nm_labu_adj_land > -10 & nm_labu_adj_land < 30  || kdensity nm_labu_adj_land if bmw == 1 & nm_labu_adj_land > -10 & nm_labu_adj_land < 30 ) title("") xtitle("Euro/hour") legend(label(1 "IE") label(2 "NI") label(3 "BMW") rows(1)) scheme("s2mono")

*

/*-- TURNED OFF ------------------
*---------------------------------
* Using nm_labu_adj
*---------------------------------
* NM Kernel Density IE- NI
ksmirnov nm_labu_adj if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 

* NM Kernel Density BMW- NI
ksmirnov nm_labu_adj if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 

*---------------------------------
* Using nm_labu1_land
*---------------------------------
* NM Kernel Density IE- NI
ksmirnov nm_labu1_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 

* NM Kernel Density BMW- NI
ksmirnov nm_labu1_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 

*---------------------------------
* Using nm_labu_adj_land
*---------------------------------
* NM Kernel Density IE- NI
ksmirnov nm_labu_adj_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 

* NM Kernel Density BMW- NI
ksmirnov nm_labu_adj_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 
---- BACK ON --------------------*/


*---------------------------------
* Using nem_labu_adj
*---------------------------------
* NM Kernel Density IE- NI
ksmirnov nem_labu_adj if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 

* NM Kernel Density BMW- NI
ksmirnov nem_labu_adj if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1 , by(cntry) 


label var nm_labu_adj  "Adjusted net margin per hour (€)"
label var nem_labu_adj "Adjusted net economic margin per hour (€)"

*qui do sub_do/kden_regions  nem_labu_adj 2009
