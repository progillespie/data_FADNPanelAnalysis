* Based on msward_code_clarity.do
capture log close
capture cmdlog close
version 9.0
clear
clear matrix
set mem 700m
set matsize 2500
set more off

/*******************************************************
********************************************************
       Cathal O'Donoghue, REDP Teagasc
       &
       Patrick R. Gillespie                            
       Walsh Fellow                    
       Teagasc, REDP                           
       patrick.gillespie@teagasc.ie            
********************************************************

       Cross country SFA analysis
       Using FADN Panel Data                         
       
       Code for PhD Thesis chapter
       Contribution to Multisward 
       Framework Project
                                                    
       Thesis Supervisors:
       Cathal O'Donoghue
       Stephen Hynes
       Thia Hennessey
       Fiona Thorne

********************************************************




  Commentary on goal and operation of this file
********************************************************
The purpose of this code was to run a SFA model on a 
panel of dairy farms for selected countries. 
It was written to work on raw FADN data, contained in two 
separate directories, eupanel and FADN2.

Most analyses require editing only the Run Analysis section


You can: 
 
 * create a panel of farms based on parameters you give
   in the Panel Specification subsection (e.g. country ),

 * specify a single SFA model in Model Commands,

 * specify other types of models too, although you will
 *  need to edit predict commands Under the Bonnet,

 * use either FADN or NFS var names. 


The code will generate logged vars and some per unit measures 
where needed, but the per unit measures will be wrong if 
working on a sector other than dairy. You will need to edit
Under the Bonnet; you cannot simply recalculate these. This 
may be fixed in a subsequent version. 


The input data are located in two specific directories,
namely...


Data > data_FADNPanelAnalysis > OrigData > eupanel9907 and
Data > data_FADNPanelAnalysis > OrigData > FADN2.


If you don't have these stored either locally or on a 
network, this code won't run. */
*******************************************************/








/********************************************************
* Run Analysis
********************************************************
* 4 Subsections: 
	1 Data and project directories
	2 Variable lists
	3 Model commands 
	4 Panel Specification
********************************************************/



/*------------------------------------------------------------
1 Data and project directories
------------------------------------------------------------*/

* tell the code where your Data and project Directories are

global 	datadir  D:\\Data   	// path to data directory
global 	project  multisward 	// name of the folder this file is in



/*------------------------------------------------------------
2 Variable lists
--------------------------------------------------------------
  KEY 
   c_vlist = cost vlist (LHS of cost function)
   q_vlist = output quantity vlist (LHS of production function)
   x_vlist = input quantity vlist
   p_vlist = output price vlist
   w_vlist = input price vlist
   z_vlist = environmental vars, drivers of efficiency
   control_vlist = control variables

   "ln" prefix indicates logged variable or varlist of logged vars
   "homog" prefix indicates homogenised variables or varlist

------------------------------------------------------------*/


* c VARLIST
local 	lnc_vlist 	"lntotalinputs" // measure of cost (logged euro)


* q VARLIST
local 	lnq_vlist 	"lndotomkgl " // measure of output (logged quantity)


* x VARLIST
local 	lnx_vlist 	"`lnx_vlist' lnlandval_ha " 
local 	lnx_vlist 	"`lnx_vlist' lnfdferfil_ha " 
local 	lnx_vlist 	"`lnx_vlist' lndaforare " 
local 	lnx_vlist 	"`lnx_vlist' lndpnolu_ha " 
local 	lnx_vlist 	"`lnx_vlist' lnflabpaid " 
local 	lnx_vlist 	"`lnx_vlist' lnflabunpd " 
local 	lnx_vlist 	"`lnx_vlist' ogagehld " 
local 	lnx_vlist 	"`lnx_vlist' lnfsizuaa " 
local 	lnx_vlist 	"`lnx_vlist' lnfdratio " 
*local 	lnx_vlist 	"`lnx_vlist' azone2 " 
*local 	lnx_vlist 	"`lnx_vlist' azone3 " 
*local 	lnx_vlist 	"`lnx_vlist' hasreps " 
*local 	lnx_vlist 	"`lnx_vlist' teagasc" 


* x VARLIST
local 	lnp_vlist 	"`lnp_vlist' " 


* w VARLIST 
			* CALCULATED FROM FADN VARIABLES
local 	lnw_vlist 	"`lnw_vlist' lnPLand" 
local 	lnw_vlist 	"`lnw_vlist' lnPTotalCattle" 
local 	lnw_vlist 	"`lnw_vlist' lnPLabour"  
			* EUROSTAT PRICE INDICES
					* FEED
local 	lnw_vlist 	"`lnw_vlist' lnPCompoundfeedingstuffsforcalv"
local 	lnw_vlist 	"`lnw_vlist' lnPCompoundfeedingstuffsforcatt"
local 	lnw_vlist 	"`lnw_vlist' lnPCerealsandmillingbyproducts"
local 	lnw_vlist 	"`lnw_vlist' lnPOilcakes"
					* FERTILISER
*local 	lnw_vlist 	"`lnw_vlist' lnPOtherfertilizerssoilimprovers"
local 	lnw_vlist 	"`lnw_vlist' lnPFERTILISERSANDSOILIMPROVERS"
					* ANY REMAINING COSTS
local 	lnw_vlist 	"`lnw_vlist' lnPElectricity" 
local 	lnw_vlist 	"`lnw_vlist' lnPMotorfuels" 
local 	lnw_vlist 	"`lnw_vlist' lnPVETERINARYEXPENSES"
local 	lnw_vlist 	"`lnw_vlist' lnPSEEDSANDPLANTINGSTOCK"
local 	lnw_vlist 	"`lnw_vlist' lnPMACHINERYANDOTHEREQUIPMENT"
local 	lnw_vlist 	"`lnw_vlist' lnPMAINTENANCEOFBUILDINGS"
local 	lnw_vlist 	"`lnw_vlist' lnPOTHERGOODSANDSERVICES"


* z VARLIST
local 	z_vlist		"fdratio"


* CONTROL VARLIST
local 	control_vlist 	"i.countrycode2 year"
/* TURNED OFF SPECIFIC REGION DUMMIES
local 	location_vlist 	"`control_vlist' France" 
local 	location_vlist 	"`control_vlist' Ireland"
local 	location_vlist 	"`control_vlist' UnitedKingdom"
local 	location_vlist 	"`control_vlist' Bretagne"
local 	location_vlist 	"`control_vlist' NormandieHaute"
local 	location_vlist 	"`control_vlist' NormandieBasse"
local 	location_vlist 	"`control_vlist' Wales"
local 	location_vlist 	"`control_vlist' Bayern"
*/

* List of vars to log
local to_log_vlist "`lnc_vlist'`lnq_vlist' `lnx_vlist' `lnp_vlist' `lnw_vlist'"



/*------------------------------------------------------------
3 Model commands 
------------------------------------------------------------*/

local 	SFAmodeltype	"bc95"

/* Write the entire model command inside double inverted commas */

* Production function 	-> Estimates TE
local 	TEmodelcommand	"sfpanel `lnq_vlist' `lnx_vlist'  , model(`SFAmodeltype') cost d(tnormal) emean(`z_vlist', noconstant)  usigma(`z_vlist', noconstant) vsigma(`z_vlist', noconstant) marginal(`z_vlist')" 


* Cost function 	-> Estimates CE 
local 	CEmodelcommand 	"sfpanel `lnc_vlist' `lnq_vlist' `lnw_vlist', model(`SFAmodeltype') cost d(tnormal) emean(`z_vlist', noconstant)  usigma(`z_vlist', noconstant) vsigma(`z_vlist', noconstant) marginal(`z_vlist')" 

local efficiency_list "TE CE"

*REMOVED: countrycode2#year 


/* Impose linear homogeneity in prices? Will change definition of
    price variables and dependent variable. Should only be run when
    a cost model is specified. 					
 NOTE: If there is only one price specified then this does not apply
 and the pricehomogeneity code will be skipped. 		  */
local pricehomogeneity 		=1






* options for the predict command. At minimum give the type of 
*  TE calulation formula - jlms is standard (see help sfpanel)
local 	predict_opts 	"jlms"  // "jlms" "te" "bc"


* Do postestimation tests? (1 = yes)
local	tests		= 0 



/*------------------------------------------------------------
4 Panel Specification
------------------------------------------------------------*/

* Run from raw FADN data? (1 = yes, all else/missing = no)

global 	databuild = 0



* panel selection

global 	ms 		"France Germany Ireland UnitedKingdom" 
global 	countrylabels 	"msname"	 //ms2, ms3 for 2, 3 character abbrev.
global 	sectors 	"fffadnsy==4110" //select desired FADN system
global 	oldvars 	"*"		 //list of desired eupanel vars. * means all.
global 	newvars 	"*"		 //list of desired FADN2 vars. * means all.



* name the panel (use the name of this file)
global 	dataname 	"$project.dta"

********************************************************
* End of Run Analysis section
*
* There is no need to edit code below this point for 
* most applications of this model. 
********************************************************







********************************************************
********************************************************
* 	Under the bonnet
********************************************************
********************************************************
* Only edit below if you are familiar with this code
********************************************************
*	|	|	|	|	|	|
*	V	V	V	V	V	V
********************************************************









********************************************************
* Data prep and other setup
********************************************************

* Prepares the FADN data. Tests if databuild = 1 first
* If directories are missing, will also make them.

* formatted data for filenames
global datestamp: di  %tdCCYY!_NN!_DD date("$S_DATE", "DMY")
global timestamp: di  %tcHhMMam clock("$S_TIME", "hms")

do sub_do/FADNprep.do


* Directory check done, you can now define directory 
*   locals for this file (FADNprep.do's locals gone now)
local fadnpaneldir $datadir/data_FADNPanelAnalysis
local fadnoutdatadir `fadnpaneldir'/OutData/$project
local nfspaneldir $datadir/data_NFSPanelAnalysis
local origdatadir `fadnpaneldir'/OrigData 
local fadn9907dir  `fadnpaneldir'/OrigData/eupanel9907
local fadn2dir  `fadnpaneldir'/OrigData/FADN_2/TEAGSC


* if building again, append the data`i'.dta's created by 
*  FADNprep.do together and create pid, then save

if $databuild == 1{

	* drop all obs 
	drop if _n >= 1

	* get filenames of all data files created by FADNprep.do
	local filelist: dir "`fadnoutdatadir'" files "data?.dta"

	* loop over each filename and append all data
	foreach file of local filelist{
		append using `fadnoutdatadir'/`file'	
		di "`file'"
	}
	

	/*---------------------------------------------- 
	 Project specific setup for the combined panel	
	----------------------------------------------*/ 
	

	* create a unique panel id (farmcodes repeat)
	egen pid = group(country region subregion farmcode)
	destring pid, replace
	tsset pid year


	label variable farmcode "ID (only unique within country)" 
	label variable pid "ID (unique for whole panel)"
	

	* labels country, year, and regions
	do sub_do/valuelabels.do


	* value 4 = "not available" so drop those obs
	drop if altitudezone >= 4


	* originally in sub_do/grassregion.do See file for details
	gen grassregion = 7
	label define grassregion  1 "Bretagne" 2 "NormandieHaute" 3 "NormandieBasse" 4 "Wales" 5 "Ireland" 6 "Bayern" 7 "Other" 
	label value grassregion grassregion
	replace grassregion = 1 if region==163
	replace grassregion = 2 if region==133
	replace grassregion = 3 if region==135
	replace grassregion = 4 if region==421
	replace grassregion = 5 if region==380
	replace grassregion = 6 if region==90


	* generate azone, region and 
	tab(altitudezone), gen(azone)
	
        
	* this code gives more descriptive country dummy names than 
	*  tab, gen() would. Uses levels of countrycode for dummy varnames.
	levelsof countrycode
	foreach value in `r(levels)' {
	di "Creating `: label (countrycode) `value'' dummy variable"
	gen `: label (countrycode) `value'' = 0
	replace `: label (countrycode) `value'' = 1 if countrycode == `value'
	}


	capture drop Bretagne 
	capture drop NormandieHaute 
	capture drop NormandieBasse 
	capture drop Wales 
	capture drop Ireland 
	capture drop Bayern 
	capture drop Other // in case of single region countries
	
	
	* same idea for creating selected region dummy names 
	levelsof grassregion
	foreach value in `r(levels)' {
	di "Creating `: label (grassregion) `value'' dummy variable"
	gen `: label (grassregion) `value'' = 0
	eplace `: label (grassregion) `value'' = 1 if grassregion == `value'
	}

	* grass proxy
	gen fdratio = feedforgrazinglivestockhomegrown/feedforgrazinglivestock
	gen intwt = int(farmsrepresented)

	sort country year
	

	note: Finished data for multisward paper. - PRG
	save `fadnoutdatadir'/$dataname, replace

}


else {
	*use `fadnoutdatadir'/$dataname, clear
}





* prepare Eurostat data for merging
qui do sub_do/eurostat_apri_pi00_ina.do subdo


************************************************************

/*----------------------------------------------------------
 Need to build a list of vars to keep from Eurostat, but
    would like for it to be based on indep_vlist. 

 Basic approach is to get the intersection of the two
  varlists, i.e. ALL Eurostat vars and indep_vlist
----------------------------------------------------------*/

* Create list of price vars with "ln" prefix stripped away
foreach lnw_var of local lnw_vlist {

	local w_var	: di substr("`lnw_var'", 3, .)
	local w_vlist 	"`w_vlist' `w_var'"

}


/* There can be many vars (with long varnames) in the
    Eurostat data. This will quickly exceed the character 
    limit for storing in a macro, so we can't just get
    the intersection of two varlists. Instead, we build 
    the list of vars to keep (much shorter) by checking 
    Eurostat varnames against w_vlist one at 
    a time using a loop. This will ensure every Eurostat
    var is checked, but there will still be problems if 
    w_vlist exceed the 244 character limit.         */

foreach var of varlist * {

	local thisvar		"`var'"
	local keep_vlist	"`keep_vlist' `thisvar'"
	local keep_vlist	: list keep_vlist & w_vlist

}

* List of all Eurostat vars in dataset...
ds

* ... of which we'll merge (based on indep_vlist)
macro list _keep_vlist 

************************************************************

* Load master data and merge Eurostat vars
use `fadnoutdatadir'/$dataname, clear

drop PMotorFuels  // empty var, drop to avoid confusion
merge m:1 country year using 		    ///
    `fadnoutdatadir'/eurostat_apri_pi00_ina ///
    , keepusing(`keep_vlist')               ///
      update replace nogen noreport
      

*codebook `keep_vlist'               

*-----------------
* Logged variables
*-----------------
* create list of vars to log based on dep_vlist
	*  and indep_vlist. This should be run whether
	*  or not running from raw data

local lnvars: di substr("`dep_vlist'", 3,.)
foreach var of local indep_vlist{
	if substr("`var'", 1,2) == "ln"{
	local tmp_lnvar:  di substr("`var'", 3, .)
	di "`tmp_lnvar'"
	local lnvars "`lnvars' `tmp_lnvar'"
	di "`lnvars'"
	}
macro drop _tmp_lnvar
}

*-----------------
* Unit variables
*-----------------
* create list of vars to put into based on 
	*  . This should be run whether
	*  or not running from raw data
	
foreach var of local lnvars{

	local tmp_unit: di substr("`var'", -3,.)
modelcommand
	if "`tmp_unit'" == "_lu" | "`tmp_unit'" == "_ha" | "`tmp_unit'" == "_lt" {
	  local tmp_unitvar: di substr("`var'", 1, length("`var'")-3 )

	  local unitvars "`unitvars' `tmp_unitvar'"
	  di "`unitvars'"

	  capture drop `tmp_unitvar'`tmp_unit'

	  if "`tmp_unit'" == "_lu"{
	    local tmp_denom "dpnolu"
	  }
	  if "`tmp_unit'" == "_ha"{
	    local tmp_denom "fsizuaa"
	  }
	  if "`tmp_unit'" == "_lt"{
	    local tmp_denom "dotomkgl"
	  }

	  gen `tmp_unitvar'`tmp_unit' = `tmp_unitvar'/`tmp_denom'

	}

macro drop _tmp_unitvar _tmp_unit _tmp_denom

}


* now create those logs if they're not there
foreach var in `lnvars'{
	capture drop ln`var'
	gen ln`var' = ln(`var')
}

/*------------------------------------------------------------------- 
Impose linear homogeneity in prices for Cobb-Douglas
    (This will recalculate logs for prices, so must come after
     the command << gen ln`var'= ln(`var') >>                              
-------------------------------------------------------------------*/ 

scalar define w_varcount = wordcount("`lnw_vlist'")
scalar list w_varcount


if `pricehomogeneity' == 1 & w_varcount > 1 & w_varcount < . {

macro list _lnw_vlist 

	foreach lnw_var of local lnw_vlist {
	
		/* create new local without "ln" prefix, and
		make a list of these "w_var's"            */ 
		local w_var: di substr("`lnw_var'", 3, .)
		local w_vlist "`w_vlist' `w_var'"
		macro list _lnw_var _w_var 

	}
	

	macro list _w_vlist 
	

	local numeraire_price: word 1 of `w_vlist' // define numeraire price
	local lnnumeraire "ln`numeraire_price'"
	local w_vlist    : list w_vlist - numeraire_price // remaining prices
	local homog_cost : di substr("`dep_vlist'", 3, .)
	local homog_vars "`w_vlist' `homog_cost'"
	
	
	
	
	foreach w_var of local homog_vars {
	
		replace ln`w_var' = ln(`w_var'/`numeraire_price')
		local lnhomog_w "`lnhomog_w' ln`w_var'"
	
	}
	
	
	/* Prices are now homogenous, and you have a list of logged vars which 
	    excludes the numeraire price (lnhomog_w). The same varnames were used 
	    for these vars however, so we can continue to use dep_vlist and
	    indep_vlist, but we need to remove the logged numeraire price from 
	    the model1command we specified above because that was in indep_vlist
            at that point.*/ 
	local TEmodelcommand: list TEmodelcommand - lnnumeraire
	
	macro list _w_vlist _numeraire_price _homog_vars _homog_cost _homog_vars _lnnumeraire _dep_vlist _indep_vlist 
	
}


encode country, gen(countrycode2)

********************************************************
* End of Data prep and other setup
********************************************************







********************************************************
* MODELLING               
********************************************************

sort pid year

* turn on logs 
log using logs/$project$datestamp.txt, replace
di  "Job  Started  at  $S_TIME  on $S_DATE"
cmdlog using logs/$project$datestamp.cmd.txt, replace

m
foreach effiency_type of local efficiency_list {

* Give a name for stored estimates (e.g. "bc95")
local 	modelname 	"`efficiency_type'_`SFAmodeltype'"


* model you selected above is run here
macro list _`"`efficiency_type'modelcommand"'
`"`efficiency_type'modelcommand"' 


* store estimates and predict ind. TE scores
qui estimates store `modelname'


* Get the AIC and BIC estimates for the fitted model
estimates stats


qui estimates save  `fadnoutdatadir'/`modelname'$datestamp$timestamp.ster, replace
qui capture drop eff_`modelname'


* constructs ind. level CI's for TE scores
*qui frontier_teci te_`model1name'_ci 


save `fadnoutdatadir'/$datanameSFApost, replace

}

********************************************************
* End of MODELLING section              
********************************************************









********************************************************
* POSTESTIMATION 
********************************************************

if `tests' == 1 {


	qui xtreg `dep_vlist' `indep_vlist', fe
	estimates store fixed
	
	
	qui xtreg `dep_vlist' `indep_vlist', re
	estimates store random
	
	
	/* Hausman specification test 
	    H0: difference in coef not systematic (i.e. OK to use RE) */ 
	qui hausman fixed random
	local hausman_test = "Prob>chi2 = `r(p)'"
	
	
	/* Test for time fixed effects 
	    H0: Joint test of year effects =0   */ 
	qui xtreg `dep_vlist' `indep_vlist' i.year, fe
	qui testparm i.year
	local time_FE = "Prob>F = `r(p)'"
	
	
	/* Breusch-Pagan LM test of RE vs OLS 
	    H0: Variances across entities are 0 
	      (i.e. no panel effect)            */ 
	estimates restore random
	qui xttest0
	local BreuschPagan_LM_RE = "Prob>chi2 = `r(p)'"
	
	
	/* Wald test for groupwise heteroscedasticity (for FE)
	     H0: Constant variance (i.e. homoscedasticity   */ 
	estimates restore fixed
	qui xttest3
	local wald_heterosc = "Prob>chi2 = `r(p)'"


}

foreach lnw_var of local lnw_vlist {

	tw (sc `dep_vlist' `lnw_var') (lfit `dep_vlist' `lnw_var')
	graph export `fadnoutdatadir'/scplot_dep_`lnw_var'.pdf, asis replace
	graph drop _all

}

*keep `dep_vlist' `indep_vlist' `z_vlist' pid year farmcode country countrycode2

set matsize 5000

foreach var of varlist `dep_vlist' `indep_vlist' `z_vlist' {

	kdensity `var', normal
	graph export `fadnoutdatadir'/normality_`var'.pdf, asis replace
	graph drop _all

}


qui predict te_`model1name', `predict_opts'
*qui predict `modelname'_ci, ci
predict xb, xb
predict u, u 
gen e = `dep_vlist'-xb
gen v = e - u


local var = "e"
kdensity `var ', normal
graph export `fadnoutdatadir'/normality_`var '.pdf, asis replace
graph drop _all
tw sc `var' xb , yline(0)
graph export `fadnoutdatadir'/heteroscedasticity_`var '.pdf, asis replace
graph drop _all


local var = "v"
kdensity `var ', normal
graph export `fadnoutdatadir'/normality_`var '.pdf, asis replace
graph drop _all
tw sc `var' xb , yline(0)
graph export `fadnoutdatadir'/heteroscedasticity_`var '.pdf, asis replace
graph drop _all


local var = "u"
kdensity `var ', normal
graph export `fadnoutdatadir'/normality_`var '.pdf, asis replace
graph drop _all
tw sc `var' xb , yline(0)
graph export `fadnoutdatadir'/heteroscedasticity_`var '.pdf, asis replace
graph drop _all



/*----------- Check theoretical properties (Cost Functions)----------
		NOTE: See Coelli et al (2005, p. 23)
  1. Nonnegativity	: c(w,q) > 0
  2. Nondecreasing in w	: if w0  >= w1, then c(w0,q) >= c(w1,q)
  3. Nondecreasing in q	: if q0  >= q1, then c(w,q0) >= c(w,q1)
  4. Homgeneity		: c(kw,q) = kc(w,q) for k>0	
  5. Concave in w	: c([theta]w0 + [1-theta]w1,q) 
			    >= [theta]c(w0,q)+[1-theta]c(w1,q)

My translation of concavity (point 5 above) is this: The cost of a 
production technique which employs both (all) inputs in fixed shares 
will be at least as much as the share weighted sum of multiple 
production techniques employing each individual input in the same 
proportions as in the single technique. So inputs are used in the 
same proportions in either case (single vs multiple technique), but 
the single technique will always be at least as costly (and possibly 
moreso). 
-------------------------------------------------------------------*/
* Checking 1 is simple (shouldn't see any obs < 0)
count if totalinputs < 0


/* Checking 2 means dC/dw >= 0 (depends on functional form)
-- For Cobb-Douglas dC/dw = C*([Beta]/w), so if all three terms
    on the right hand side > 0, so too will dC/dw. Checked C above
    so its just w and Beta's to check now.
    */	

* checking w's
foreach lnw_var of local lnw_vlist {
	
	/* we want to check w's not their logs, so
	create new local without "ln" prefix, and
	make a list of these w_var's while your at it  */
	local w_var: di substr("`lnw_var'", 3, .)
	local w_vlist "`w_vlist' `w_var'"

	count if `w_var' < 0 
}

* checking [Betas] ... inspect the parameter estimates for negative
*  signs
*--------------------------------------------------------------------

/* Display exponentiated parameters for convenience 
 (currently All, whether that makes sense or not...
  will not change actual stored estimates)          */ 
matrix define B = e(b)
matrix define expB = B

local i = 1
while `i' <= colsof(B) {

	matrix define expB[1,`i'] = exp(B[1,`i'])

	local i = `i' + 1
}
matrix define Bcomb = [B, expB]
matrix define Bcomb = Bcomb' 

* for supporting discussion of positive sign on hasreps in
* production function (unexpected)
corr `dep_vlist' `indep_vlist'


* some descriptives of the TE scores
tabstat te_`model1name', stats(mean sem) by(country)

* describes the relationsip of fdratio to te_tfe
tw (sc `modelname' fdratio) (lfit `modelname' fdratio, lwidth(thick))
graph export `fadnoutdatadir'/scplot_te_fdratio.pdf, asis replace
graph drop _all
** shows weak relation to mean, but stronger for heterscedasiticy
** therefore, put z's into sigma_u


save `fadnoutdatadir'/$datanameSFApost, replace

********************************************************
* End of POSTESTIMATION section
********************************************************









********************************************************
* CLEANING UP             
********************************************************

* report the model parameters you selected in the log
capture macro list _dep_vlist _indep_vlist _location_vlist _model1command _model1name _predict_opts databuild ms sectors dataname datadir project 


*clear
capture erase blank.dta
capture log close
capture cmdlog close

********************************************************
*** End of CLEANING UP section
********************************************************







********************************************************
* OUTPUT WILL BE IN THE OUTPUT FOLDER. LOGS WILL BE IN
* THE LOGS FOLDER. 
********************************************************

if `tests' == 1 {

macro list _hausman_test  _time_FE  _BreuschPagan_LM_RE  _wald_heterosc

}


* Here are the model results. Ignore syntax error if using sfpanel
di "Results from model (`model1name')"
matrix list Bcomb 

macro drop _all
