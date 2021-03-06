quiet {
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

local datasource "D:/Data\Data_FADNPanelAnalysis"
local dodir "`datasource'/Do_Files/`project'"
local outdatadir "`datasource'/OutData/`project'"
capture mkdir `outdatadir'/densities
capture mkdir `outdatadir'/logs

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

	* High land, perm crops & quota -- 1 ob 
	drop if landpermananentcropsquotas > 10000000
	
	* High feedforgrazinglivestock -- 3 obs
	drop if feedforgrazinglivestock > 400000
	
	* High flabunpd --  1 ob
	drop if flabunpd > 10000 
	
	* Teenage farmers --  2 obs
	drop if ogagehld < 20


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



	*----------------------------------
	* Proportions of farmers by age (slide 12)
	*----------------------------------
	preserve

	do dy_sub_do/age.do

	restore

	*----------------------------------
	* Differences in Farm Financials (slide 13)
	*----------------------------------
	preserve

	do dy_sub_do/fin_farm.do
	
	restore
	

	*----------------------------------
	* Gross margin per litre cost groups (slide 14)
	*----------------------------------

	replace fdairygm = fdairygo - fdairydc
	gen double fdairynm = fdairygm - fdairyoh
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

	restore	

	local filenumber = `filenumber' + 1 
}	





*====================================================================
* Combine datasets
*====================================================================
local filenumber = 1
use data`filenumber'_out.dta, clear
gen cntry = 1
local filenumber = 2
qui append using data`filenumber'_out.dta
replace cntry = 2 if cntry == .

*====================================================================
*====================================================================





* Create var with three levels (one for each region) and two for 
*  two way comparisons (SE - NI, and BMW - NI) 

* BMW region and SE region dummies 
gen bmw = cntry == 1 & subregion == 2
gen se  = cntry == 1 & subregion == 1

gen int aregion = .
replace aregion = 3 if cntry == 2
replace aregion = 2 if bmw   == 1
replace aregion = 1 if se    == 1
label define aregion 1 "SE" 2 "BMW" 3 "NI"
label val aregion aregion 
label var aregion "Analysis region"

gen int seni  = .
replace seni  = 1 if aregion == 1
replace seni  = 2 if aregion == 3
label define seni  1 "SE" 2 "NI"
label val seni  seni  

gen int bmwni = .
replace bmwni = 1 if aregion == 2
replace bmwni = 2 if aregion == 3
label define bmwni 1 "BMW" 2 "NI"
label val bmwni bmwni 



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
gen cex_rentpaid = rentpaid/cex 
gen cex_wages = wages*exchangerate/cex

gen hrs_lu = labourinputhours/totallivestockunits


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



* Store a version of these w/o exchange rate adjustment
gen double nocex_wages    = wages
gen double nocex_rentpaid = rentpaid
gen double nocex_fdairygo = fdairygo 
gen double nocex_fdairydc = fdairydc 
gen double nocex_fdairygm = fdairygm 
gen double nocex_fdairyoh = fdairyoh 
gen double nocex_fdairynm = nocex_fdairygm - nocex_fdairyoh
gen double nocex_fdairyec = fdairyec 

* Use the exchange rate adjusted version from here on
replace wages     = cex_wages
replace rentpaid  = cex_rentpaid 
replace fdairygo  = cex_fdairygo
replace fdairydc  = cex_fdairydc
replace fdairygm  = fdairygo - fdairydc //must come after GO & DC
replace fdairyoh  = cex_fdairyoh
replace fdairynm  = fdairygm - fdairyoh //must come after GM & OH
replace fdairyec  = cex_fdairyec
replace fdairytct = fdairydc + fdairyoh // must come after DC & OH

*Net economic margin (Net margin less economic costs)
capture drop fdairynem
gen double fdairynem = fdairynm - fdairyec //must come after NM & EC





*=== Program definition - testmat ===

capture program drop testmat 
program testmat, nclass
  args k_or_t matname t_vlist byvar cond

  quietly {

  * Add & to cond if it's not empty
  if "`cond'" != "" local cond "& `cond'"

  * Initialise index and matrix with a row of 0's
  local i = 1
  capture matrix drop `k_or_t'`matname'
  matrix `k_or_t'`matname' = (0 , 0)

  * Do t tests for each var in the table and store results in matrix
  foreach var of local t_vlist {

        
  	if "`k_or_t'" == "T" {

         ttest `var' if !missing(`byvar')  `cond' , by(`byvar') unequal
         local stat "`r(t)'"
         local pval "`r(p)'"
        }


  	if "`k_or_t'" == "K" {
          ksmirnov `var' if !missing(`byvar')  `cond' , by(`byvar')
         local stat "`r(D)'"
         local pval "`r(p)'"
        }

  	matrix `k_or_t'`matname'= ///
           (`k_or_t'`matname'\ `stat', round(`pval', .001))
  	local i	= `i'+1

  }

  * Remove the row of 0's we initialised the matrix with
  matrix `k_or_t'`matname'= `k_or_t'`matname'[2..`i',1..2]

  * Label the rows and the single column of the t-test matrix
  matrix rownames `k_or_t'`matname'= `t_vlist'
  matrix colnames `k_or_t'`matname'= stat p-value
  }

  matrix list `k_or_t'`matname'


end

*=== Program definition - testmat ===



*=== Program definition - testSNBN ===
* MUST come after definition of ttestmat!!!

capture program drop testSNBN 
program testSNBN, nclass
  args k_or_t matname t_vlist cond

  * Matrix of t-tests (SE-NI and BMW-NI comparisons)
  quietly {

  testmat "`k_or_t'" "`matname'1" "`t_vlist'" "seni" "`cond'"
  testmat "`k_or_t'" "`matname'2" "`t_vlist'" "bmwni" "`cond'"
  matrix `k_or_t'`matname' = (`k_or_t'`matname'1 , `k_or_t'`matname'2)
  matrix drop `k_or_t'`matname'1
  matrix drop `k_or_t'`matname'2

  matrix colnames `k_or_t'`matname' = ///
     SE-NI_stat p-value BMW-NI_stat p-value

  }
  matrix list `k_or_t'`matname'

end

*=== Program definition - testSNBN ===



local structuralvars = "`structuralvars' dpnolu"
local structuralvars = "`structuralvars' othercattlelus"
local structuralvars = "`structuralvars' totaluaa"
local structuralvars = "`structuralvars' daforare"
local structuralvars = "`structuralvars' stockingdensity"
local structuralvars = "`structuralvars' hrs_lu"
local structuralvars = "`structuralvars' milkyield"
local structuralvars = "`structuralvars' ogagehld"

}

* Tables of mean values per year
foreach var of local structuralvars {
  
  di _newline(3) "Annual mean levels of `var' by aregion"
  table   year aregion [weight=intwt], c(mean `var') format(%9.2f)

}

* Table of mean values across all years
tabstat `structuralvars' [weight=wt], by(aregion) format(%9.2f) 

* Matrix of t-tests (SE-NI and BMW-NI comparisons)
testSNBN "T" "STR" "`structuralvars'"



*---------------------------------
* Do Comparative Analysis
*----------------------------------

* Stocking Rate
capture drop lu_ha
capture gen lu_ha = dpnolu/daforare

* Labour units
capture drop labu_ha 
capture gen labu_ha = flabunpd/daforare

* Yield
capture drop lt_lu 
capture gen lt_lu = dotomkgl/dpnolu

* Milk Price (fdairygo is just milk anyway, and it has the cex correction if applied)
capture drop milk_price 
gen milk_price = fdairygo/dotomkgl

* Imputed value of own land
capture drop rentrateha 
capture drop ownlandpct 
capture drop ownlandha  
capture drop ownlandval 
gen rentrateha = rentpaid/renteduaa
gen ownlandpct = (totaluaa-renteduaa)/totaluaa
gen ownlandha  = daforare*ownlandpct
gen ownlandval = ownlandha*rentrateha



*=== Program definition - scalevar ===

capture program drop scalevar
program scalevar, rclass
  args variable outdatadir

  capture log close
  macro list _outdatadir
  log using `outdatadir'/logs/`variable'.txt, text replace

  capture drop `variable'_ha
  capture drop `variable'_lu
  capture drop `variable'_labu
  capture drop `variable'_lt
  gen `variable'_ha   = `variable'/daforare
  gen `variable'_lu   = `variable'/dpnolu
  gen `variable'_labu = `variable'/flabunpd
  gen `variable'_lt   = `variable'/dotomkgl

  di "You've created these scaled versions of `variable'..."
  ds                     ///
     `variable'_ha `variable'_lu   ///
     `variable'_labu `variable'_lt ///
     , v(32)

  di _newline(2) "Annual mean values of `variable' by aregion"
  table year aregion [weight=intwt], ///
    c(mean `variable')               ///
      format(%9.2f)

  di _newline(2) "Annual mean values of `variable'_ha by aregion"
  table year aregion [weight=intwt], ///
    c(mean `variable'_ha)            ///
      format(%9.2f)

  di _newline(2) "Annual mean values of `variable'_lu by aregion"
  table year aregion [weight=intwt], ///
    c(mean `variable'_lu )           ///
      format(%9.2f)

  di _newline(2) "Annual mean values of `variable'_labu by aregion"
  table year aregion [weight=intwt], ///
    c(mean `variable'_labu )           ///
      format(%9.2f)

  di _newline(2) "Annual mean values of `variable'_lt by aregion"
  table year aregion [weight=intwt], ///
    c(mean `variable'_lt )           ///
      format(%9.2f)

  log close


  * Uncomment to view each variables log file
  *view "`outdatadir'/logs/`variable'.txt"

end

*=== Program definition - scale ===



* Output
scalevar fdairygo "`outdatadir'" //Gross Output


* Costs
capture drop cost
gen cost = fdairydc + fdairyoh

scalevar fdairydc "`outdatadir'" // Direct Costs
scalevar fdairyoh "`outdatadir'" // Overhead Costs
scalevar cost     "`outdatadir'" // Total costs 

* -- Land-adjusted overhead costs
gen double fdairyoh_land = fdairyoh - ownlandval
scalevar fdairyoh_land "`outdatadir'" 


* Margins
scalevar fdairygm  "`outdatadir'" // Gross margin
scalevar fdairynm  "`outdatadir'" // Net margin
scalevar fdairynem "`outdatadir'" // Net economic margin


* Net margins with shortened names
gen nm_ha1        = fdairynm_ha
gen nm_lu1        = fdairynm_lu
gen nm_labu1      = fdairynm_labu
gen nm_lt1        = fdairynm_lt
gen nm_labu1_land = (fdairygm - fdairyoh - ownlandval)/flabunpd





* ==================================================================
* ==================================================================
* Price adjustment (raises/lowers gross output by the global 
*   ratio of average prices in each country in each year). Entire
*   distributions are shifted, but the shape should be the same.
* ==================================================================
* ==================================================================
quietly {



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

	} // End of foreach cntry in `cntry_list' 

  } // End of foreach yr in `yr_list'



  * Make IE milk prices like NI
  gen fdairygo_adj = fdairygo 



  foreach yr of local yr_list {

  	qui replace fdairygo_adj = /// 
          fdairygo_adj*av_fdairygo_lt`yr'_2/av_fdairygo_lt`yr'_1 ///
          if year == `yr' & cntry == 1

  } // End of foreach yr of local yr_list



} // END of quietly 

* Price-adjusted output scaled
scalevar fdairygo_adj "`outdatadir'" 
* ==================================================================
* ==================================================================





* -------------------------------
* Calculate scenario net margins
* -------------------------------
* Price-adjusted net margin
gen double nm_adj        = fdairygo_adj - fdairydc - fdairyoh
scalevar nm_adj "`outdatadir'" 

* Price-land-adjusted net margin
gen double nm_adj_land   = nm_adj - ownlandval
scalevar nm_adj_land "`outdatadir'" 

* Price-adjusted net economic margin
gen double nem_adj       = nm_adj - fdairyec
scalevar nem_adj "`outdatadir'" 






* Examine land ownership, impute opportunity cost of land, return matrices
*qui do sub_do/landownership.do




*=== Program definition - plotkden ===
*--------------------------------------------------------------------
* Creates overlaid kernel densities for NI, BMW, and SE
*	- year 2008 only
*	- Net margins per litre from -0.10 to 0.30 only
*--------------------------------------------------------------------
capture program drop plotkden 
program plotkden
  args outdatadir var yyyy UL LL limvar
  
  * Set default bounds on graph
  if "`limvar'" == "" local limvar "`var'" // limvar defaults to var
  if "`UL'"     == "" local UL "40.0001"
  if "`LL'"     == "" local LL "-40.0001"
  
  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  * Graphing command
  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  kdensity `var' if                           /// ===== Command ========
             aregion == 1                  &  ///
  	     year == `yyyy'                &  /// First plot (SE)
             `limvar'  < `UL'              &  ///
             `limvar'  > `LL'                 ///
      ,                                       ///
        legend(bplacement(neast) ring(0)      /// Legend in plot area    
               label(1 "SE")                  /// ----------------------
               label(2 "BMW")                 /// Legend labels & white
               label(3 "NI"))                 /// legend outline
        addplot(kdensity `var' if             /// =======Options========
                           aregion == 2    &  ///
                           year == `yyyy'  &  /// 
                           `limvar' < `UL' &  /// Second plot (BMW)
                           `limvar' > `LL'    ///
                ||                            /// 
                kdensity `var' if             /// ----------------------
                           aregion == 3    &  ///
                           year == `yyyy'  &  /// Third plot (NI)
                           `limvar' < `UL' &  /// 
                           `limvar' > `LL'  ) /// ----------------------          
        scheme(s2mono)                         /// Start from s2mono 

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  * Graphing command
  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  graph export `outdatadir'/densities/kden_`var'.wmf, replace
  graph drop _all
end

*=== Program definition - plotkden ===





 
 
* Only do the following if BMWonly is turned off
if `BMWonly'==0 {

  * Plot kdensities
  local kdenlist ""
  local kdenlist "`kdenlist' daforare"
  local kdenlist "`kdenlist' fdairygo_ha" 
  local kdenlist "`kdenlist' cost_ha"     
  local kdenlist "`kdenlist' nm_ha1" 	
  local kdenlist "`kdenlist' lu_ha" 
  local kdenlist "`kdenlist' fdairygo_lu" 
  local kdenlist "`kdenlist' cost_lu" 
  local kdenlist "`kdenlist' nm_lu1" 
  local kdenlist "`kdenlist' lt_lu" 
  local kdenlist "`kdenlist' fdairygo_lt" 
  local kdenlist "`kdenlist' cost_lt"  
  local kdenlist "`kdenlist' nm_lt1" 
  local kdenlist "`kdenlist' labu_ha" 
  local kdenlist "`kdenlist' fdairygo_labu" 
  local kdenlist "`kdenlist' cost_labu" 
  local kdenlist "`kdenlist' nm_labu1" 
  local kdenlist "`kdenlist' nm_adj_labu"
  local kdenlist "`kdenlist' nm_labu1_land"
  local kdenlist "`kdenlist' nm_adj_land_labu"
  local kdenlist "`kdenlist' rentrateha"
  local kdenlist "`kdenlist' ownlandval"

  foreach var of local kdenlist {

    *plotkden "`outdatadir'" `var' 2008 0.3 -0.1 nm_lt1

  }

}





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


* --------------
* Log variables 
* --------------
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
* --------------
     

* --------------
* Interactions with ni dummy variable
* --------------
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
* --------------


local do_chow = 0
if `do_chow' == 1 {
  * --------------
  * Estimate production functions
  * --------------
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
  
  * --------------
  
  
  * --------------
  * Test commands
  * --------------
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
  
}

* --------------

*******************************************************
* End of Chow tests*  
*******************************************************



*--- Program definition - yrlytests
capture program drop yrlytests
program yrlytests, nclass
  args var yr_list UL LL limvar


  * Default values for boundary arguments
  if "`limvar'" == "" local limvar "`var'"
  qui summ `limvar'
  if "`UL'"     == "" local UL     "`r(max)'"
  if "`LL'"     == "" local LL     "`r(min)'"

  capture matrix drop YT`var'
  capture matrix drop YK`var'

  matrix YT`var' = (0, 0, 0, 0)
  matrix YK`var' = (0, 0, 0, 0)
    


  local i = 1
  foreach yr of local yr_list {

    * & `limvar' < `UL' & `limvvar' > `LL'
    qui testSNBN "T" "`yr'" "`var'" "year==`yr' & `limvar' < `UL'"
    qui testSNBN "K" "`yr'" "`var'" "year==`yr' & `limvar' < `UL'"

    matrix YT`var' = (YT`var' \ T`yr')
    matrix YK`var' = (YK`var' \ K`yr')

    matrix drop T`yr'
    matrix drop K`yr'

    local i = `i' + 1
  }

  matrix YT`var' = YT`var'[2..`i', 1..4]
  matrix rownames YT`var' = `yr_list'
  matrix colnames YT`var' = ///
    SE-NI_t-stat p-value BMW-NI_stat p-value

  
  matrix YK`var' = YK`var'[2..`i', 1..4]
  matrix rownames YK`var' = `yr_list'
  matrix colnames YK`var' = ///
    SE-NI_k-stat p-value BMW-NI_k-stat p-value


end

*--- Program definition - yrlytests





*******************************************************
* K-S tests*  Per Labour Unit 
*******************************************************
local testvlist ""
local testvlist "`testvlist' nm_labu1"         // Scenario 1
local testvlist "`testvlist' nm_adj_labu"      // Scenario 2
local testvlist "`testvlist' nm_labu1_land"    // Scenario 3
local testvlist "`testvlist' nm_adj_land_labu" // Scenario 4
local testvlist "`testvlist' nem_adj_labu"     // Scenario 5
foreach var of local testvlist {

  yrlytests "`var'" "`yr_list'" "" "" ""
  matrix list YT`var'
  matrix list YK`var'

  /*
  * For monochrome graphs
  graph box `var', over(aregion) over(year) asyvars noout ///
      scheme(lean2) legend(pos(north) row(1)) ///
      ytitle("euro per hour") note("")
  */

  * For colour graphs
  graph box `var', over(aregion) over(year) asyvars noout ///
       legend(row(1)) ytitle("euro per hour") note("")

  * Export whichever is currently displayed
  graph export `outdatadir'/densities/box_`var'.wmf, replace
  graph drop _all

}

matrix dir
*******************************************************
* K-S tests*  Per Labour Unit 
*******************************************************
