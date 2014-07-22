version 9.0
clear
set more off
set matsize 4000

set mem 300m

cd "G:\data\Data_FADNPanelAnalysis\Do_Files\IGM"
local outdatadir "../../OutData/IGM"

* All of the following must be looped over each of the data`filenumber'

local filenumber = 1
local cumulative_N = 0
while `filenumber' < 3{
	
	use `outdatadir'/data`filenumber', clear
	
	* Temporary BMW region dummy for sample selection
	*gen  t_bmw = subregion == 2 if country == "IRE"
	*keep t_bmw == 1 //if left on, then slide tables are BMW - NI


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
	*export excel using 			///
	* `outdatadir'/simplified.xlsx, 	///
	*sheet("slide 11")			///
	*cell(A`rownumber')			///
	*sheetmodify

	restore


	*----------------------------------
	* Proportions of farmers by age (slide 12)
	*----------------------------------
	preserve

	do dy_sub_do/age.do

	*export excel using 			///
	* `outdatadir'/simplified.xlsx,		///
	*sheet("slide 12 (data`filenumber')")	///
	*cell(A2)				///
	*firstrow(variables)			///
	*sheetmodify

	restore

	*----------------------------------
	* Differences in Farm Financials (slide 13)
	*----------------------------------
	preserve

	do dy_sub_do/fin_farm.do

	*export excel using 			///
	* `outdatadir'/simplified.xlsx,		///
	*sheet("slide 13 (data`filenumber')")	///
	*cell(A2)				///
	*firstrow(variables)			///
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
	
	*export excel using 			///
	* `outdatadir'/simplified.xlsx		///
	* if year == 2007,			///
	*sheet("slide 14 (data`filenumber')")	///
	*cell(A2)				///
	*firstrow(variables)			///
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
	
	*export excel country fdgrz_pct fert_pct 	///
	*	     othlvstk_pct 			///
	*	     othct_pct				///
	* 	using  `outdatadir'/simplified.xlsx,   	///
	*	sheet("slide 15")			///
	*	cell(A`rownumber2')			///
	*	sheetmodify

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

* Labour units
capture gen labu_ha = flabunpd/daforare

* Yield
capture gen lt_lu = dotomkgl/dpnolu

* Milk Price
gen milk_price = doslmkgl/dotomkgl

*Gross Outpput
gen fdairygo_ha = fdairygo/daforare
capture drop fdairygo_lu
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

gen rentrateha      = rentpaid/renteduaa
gen ownlandpct    = (totaluaa-renteduaa)/totaluaa
gen ownlandha     = daforare*ownlandpct
gen ownlandval    = ownlandha*rentrateha

* Margin
gen fdairynm_lt = fdairygm/dairyproduct - fdairyoh_lt
gen fdairygm_lt = fdairygm/dairyproduct
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

* Make ROI milk prices like NI
gen fdairygo_adj = fdairygo if year == 2008 
local yr = 2008
qui replace fdairygo_adj = fdairygo_adj*av_fdairygo_lt`yr'_2/av_fdairygo_lt`yr'_1 if year == 2008 & cntry == 1

gen nm_labu_adj = (fdairygo_adj - fdairydc - fdairyoh)/flabunpd
gen nm_labu_adj_land = (fdairygo_adj - fdairydc - fdairyoh-ownlandval)/flabunpd

* BMW region and SE region dummies 
gen bmw = cntry == 1 & subregion == 2
gen se  = cntry == 1 & subregion == 1



egen ctry_year = concat(country year)

* temporarily save data EXACTLY as it is. Use restore to restore to this state.
preserve


collapse totaluaa uaainowneroccupation renteduaa commonageuaa rentrateha ownlandpct ownlandha ownlandval, by(ctry_year)
gen country = substr(ctry_year,1,3)
gen year 	= substr(ctry_year,4,.)
destring year, replace

mkmat totaluaa uaainowneroccupation renteduaa commonageuaa rentrateha ownlandpct ownlandha ownlandval if country=="IRE", matrix(IE) rownames(year)
mkmat totaluaa uaainowneroccupation renteduaa commonageuaa rentrateha ownlandpct ownlandha ownlandval if country=="UKI", matrix(NI) rownames(year)

matrix define	DIFF = IE - NI
matrix list 	DIFF


*====================================================*
mata

/* NOTE: This is how you comment inside of mata. 
	 You can also use "//" for single line and
	 end of line comments. "*" will not work.	
*/

// make stata matrices available in mata       
IE = st_matrix("IE")
NI = st_matrix("NI")

NI_GBP = NI :/ EXCHANGERATE


/* - column 2 of IE and NI is uaainowneroccupation
   - column 1 is totaluaa                          
   - the :/ operator does element-wise division as
     opposed to matrix division			
*/
OWN 	= (IE[,2] , NI[,2])
TOTAL 	= (IE[,1] , NI[,1])
PCT 	= OWN :/ TOTAL
PCT = (PCT, PCT[,1]-PCT[,2])


// display the PCT matrix just by typing its name  
PCT


/* NOTE: The mata (PCT,TOTAL,OWN, etc.) will persist
		 even after you leave the mata environment
		 using the end command below. To clear them 
		 out use the following...
mata clear										
*/

end 
*====================================================*

* restore data as preserved (i.e. EXACTLY as immediately before collapse)
restore




*******************************************************
* Per Ha
*******************************************************
*---------------------------------
* Using daforare 
*---------------------------------
* daforare Kernel Density ROI- NI
kdensity daforare if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov daforare if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* daforare Kernel Density BMW- NI
kdensity daforare if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov daforare if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* daforare Kernel Density SE- NI
kdensity daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* daforare Kernel Density SE- BMW
kdensity daforare if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity daforare if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov daforare if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using fdairygo_ha 
*---------------------------------
* GO Kernel Density ROI- NI
kdensity fdairygo_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov fdairygo_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density BMW- NI
kdensity fdairygo_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov fdairygo_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- NI
kdensity fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- BMW
kdensity fdairygo_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov fdairygo_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using cost_ha 
*---------------------------------
* Cost Kernel Density ROI- NI
kdensity cost_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov cost_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density BMW- NI
kdensity cost_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov cost_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- NI
kdensity cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- BMW
kdensity cost_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov cost_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using nm_ha1 
*---------------------------------
* NM Kernel Density ROI- NI
kdensity nm_ha1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov nm_ha1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity nm_ha1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov nm_ha1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity nm_ha1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov nm_ha1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 





*******************************************************
* Per LU
*******************************************************
*---------------------------------
* Using lu_ha 
*---------------------------------
* lu_ha Kernel Density ROI- NI
kdensity lu_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov lu_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* lu_ha Kernel Density BMW- NI
kdensity lu_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov lu_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* lu_ha Kernel Density SE- NI
kdensity lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* lu_ha Kernel Density SE- BMW
kdensity lu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lu_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov lu_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using fdairygo_lu 
*---------------------------------
* GO Kernel Density ROI- NI
kdensity fdairygo_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov fdairygo_lu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density BMW- NI
kdensity fdairygo_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov fdairygo_lu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- NI
kdensity fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- BMW
kdensity fdairygo_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov fdairygo_lu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using cost_lu 
*---------------------------------
* Cost Kernel Density ROI- NI
kdensity cost_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov cost_lu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density BMW- NI
kdensity cost_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov cost_lu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- NI
kdensity cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- BMW
kdensity cost_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov cost_lu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using nm_lu1 
*---------------------------------
* NM Kernel Density ROI- NI
kdensity nm_lu1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov nm_lu1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity nm_lu1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov nm_lu1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity nm_lu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov nm_lu1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 





*******************************************************
* Per LT
*******************************************************
*---------------------------------
* Using lt_lu 
*---------------------------------
* lt_lu Kernel Density ROI- NI
kdensity lt_lu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov lt_lu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* lt_lu Kernel Density BMW- NI
kdensity lt_lu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov lt_lu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* lt_lu Kernel Density SE- NI
kdensity lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* lt_lu Kernel Density SE- BMW
kdensity lt_lu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity lt_lu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov lt_lu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using fdairygo_lt 
*---------------------------------
* GO Kernel Density ROI- NI
kdensity fdairygo_lt if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov fdairygo_lt if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density BMW- NI
kdensity fdairygo_lt if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov fdairygo_lt if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- NI
kdensity fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- BMW
kdensity fdairygo_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov fdairygo_lt if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using cost_lt 
*---------------------------------
* Cost Kernel Density ROI- NI
kdensity cost_lt if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov cost_lt if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density BMW- NI
kdensity cost_lt if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov cost_lt if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- NI
kdensity cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- BMW
kdensity cost_lt if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW) ksmirnov cost_lt if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using nm_lt1 
*---------------------------------
* NM Kernel Density ROI- NI
kdensity nm_lt1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov nm_lt1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity nm_lt1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov nm_lt1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity nm_lt1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov nm_lt1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity nm_lt1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_lt if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov nm_lt1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 





*******************************************************
* Per Labour Unit
*******************************************************
*---------------------------------
* Using labu_ha 
*---------------------------------
* labu_ha Kernel Density ROI- NI
kdensity labu_ha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov labu_ha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* labu_ha Kernel Density BMW- NI
kdensity labu_ha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov labu_ha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* labu_ha Kernel Density SE- NI kdensity labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* labu_ha Kernel Density SE- BMW
kdensity labu_ha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity labu_ha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov labu_ha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using fdairygo_labu 
*---------------------------------
* GO Kernel Density ROI- NI
kdensity fdairygo_labu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov fdairygo_labu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density BMW- NI
kdensity fdairygo_labu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov fdairygo_labu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- NI
kdensity fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* GO Kernel Density SE- BMW
kdensity fdairygo_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity fdairygo_labu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov fdairygo_labu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using cost_labu 
*---------------------------------
* Cost Kernel Density ROI- NI
kdensity cost_labu if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov cost_labu if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density BMW- NI
kdensity cost_labu if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov cost_labu if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- NI
kdensity cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* Cost Kernel Density SE- BMW
kdensity cost_labu if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity cost_labu if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov cost_labu if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using nm_labu1 
*---------------------------------
* NM Kernel Density ROI- NI
kdensity nm_labu1 if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov nm_labu1 if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity nm_labu1 if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov nm_labu1 if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity nm_labu1 if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1 if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov nm_labu1 if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 





*******************************************************
* Per Labour Unit (Adjusted Price)
*******************************************************
*---------------------------------
* Using nm_labu_adj
*---------------------------------
* NM Kernel Density ROI- NI
kdensity nm_labu_adj if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1))
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov nm_labu_adj if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity nm_labu_adj if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1))
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov nm_labu_adj if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity nm_labu_adj if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1))
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov nm_labu_adj if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using nm_labu1_land
*---------------------------------
* NM Kernel Density ROI- NI
kdensity nm_labu1_land if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_nm_labu1_land_ROI.wmf, replace
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov nm_labu1_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity nm_labu1_land if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_nm_labu1_land_BMW.wmf, replace
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov nm_labu1_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity nm_labu1_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1))  scheme(s2color)
graph export `outdatadir'/kden_nm_labu1_land_SENI.wmf, replace
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov nm_labu1_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity nm_labu1_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu1_land if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_nm_labu1_land_SEBMW.wmf, replace
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov nm_labu1_land if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


*---------------------------------
* Using nm_labu_adj_land
*---------------------------------
* NM Kernel Density ROI- NI
kdensity nm_labu_adj_land if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_nm_labu_adj_land_ROI.wmf, replace  
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov nm_labu_adj_land if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity nm_labu_adj_land if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_nm_labu_adj_land_BMW.wmf, replace
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov nm_labu_adj_land if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity nm_labu_adj_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_nm_labu_adj_land_SENI.wmf, replace
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov nm_labu_adj_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity nm_labu_adj_land if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity nm_labu_adj_land if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_nm_labu_adj_land_SEBMW.wmf, replace
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov nm_labu_adj_land if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 





*******************************************************
* Rent paid per hectare rented
*******************************************************

* NM Kernel Density ROI- NI
kdensity rentrateha if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_rentrateha_ROI.wmf, replace  
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov rentrateha if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI
kdensity rentrateha if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_rentrateha_BMW.wmf, replace
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov rentrateha if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI
kdensity rentrateha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_rentrateha_SENI.wmf, replace
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov rentrateha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW
kdensity rentrateha if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity rentrateha if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_rentrateha_SEBMW.wmf, replace
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov rentrateha if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 





*******************************************************
* Imputed value of owned land
*******************************************************

* NM Kernel Density ROI- NI 
kdensity ownlandval if cntry == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "ROI") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_ownlandval_ROI.wmf, replace  
* select all farms in 2008 (SE, BMW, NI), compare by country (ROI = SE + BMW to  NI)
ksmirnov ownlandval if year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density BMW- NI 
kdensity ownlandval if bmw == 1  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "BMW") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_ownlandval_BMW.wmf, replace
* select farms not in SE in 2008 (BMW, NI), compare by country (in effect BMW to NI)
ksmirnov ownlandval if se == 0 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- NI 
kdensity ownlandval if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if cntry == 2 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "NI") label(1 "SE") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_ownlandval_SENI.wmf, replace
* select farms not in BMW in 2008 (BMW, NI), compare by country (in effect SE to NI)
ksmirnov ownlandval if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(cntry) 

* NM Kernel Density SE- BMW 
kdensity ownlandval if bmw == 0  & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, plot(kdensity ownlandval if bmw == 1 & year == 2008 & nm_lt1  < 0.3 & nm_lt1  > -0.1) legend(label(2 "BMW") label(1 "SE") rows(1)) scheme(s2color)
graph export `outdatadir'/kden_ownlandval_SEBMW.wmf, replace
* select farms in ROI in 2008 (SE, BMW), compare by country (in effect SE to BMW)
ksmirnov ownlandval if cntry ==1 & year == 2008 & nm_lt1  < 0.3  & nm_lt1  > -0.1, by(bmw) 


graph drop _all


/* REMINDER for myself.

   If using VIM and ^M characters appear at the end of a line you can do 

	:1,$s/^V^M//

   where ^V is the key combination CTRL-V and ^M is CTRL-M
   it will type out as ^M before you hit enter. This is a regex that just 
   replaces all instances of ^M with nothing.

   If those characters appeared, that means that the text file was 
   formatted as a UNIX text file in VIM. You can set it back to DOS with 

	:set ff=dos

*/ 
