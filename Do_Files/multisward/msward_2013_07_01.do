capture log close
capture cmdlog close
version 9.0
clear
clear matrix
set mem 700m
set matsize 2500
set more off

********************************************************
********************************************************
*       Cathal O'Donoghue, REDP Teagasc
*       &
*       Patrick R. Gillespie                            
*       Walsh Fellow                    
*       Teagasc, REDP                           
*       patrick.gillespie@teagasc.ie            
********************************************************
* Farm Level Microsimulation Model
*       Cross country SFA analysis
*       Using FADN Panel Data                         
*       
*       Code for PhD Thesis chapter
*       Contribution to Multisward 
*       Framework Project
*                                                    
*       Thesis Supervisors:
*       Cathal O'Donoghue
*       Stephen Hynes
*       Thia Hennessey
*       Fiona Thorne
*
********************************************************
* READ THE README.txt FILE BEFORE CHANGING ANYTHING!!!
********************************************************
* Tasks
*    - run from D:\ on laptop
*    - 
*------------------------------------------------------


********************************************************
********************************************************
* Key Parameters
********************************************************
********************************************************


*------------------------------------------------------------
* Give the varnames of the dependent and the explanatory vars
*------------------------------------------------------------
local dep_vlist "lnfdairygo_lu" // lndotomkgl 
 
local indep_vlist "lnlandval_ha lnfdferfil_ha lndaforare lndpnolu_ha lnflabpaid lnflabunpd ogagehld lnfsizuaa lnfdratio azone2 azone3 hasreps teagasc"

local location_vlist "France Ireland UnitedKingdom Bretagne NormandieHaute NormandieBasse Wales Bayern" // <- may have to rethink region dummies

 


*------------------------------------------------------------
* SFA model commands (will be run in the code below)
*------------------------------------------------------------
local model1command "xtfrontier `dep_vlist' `indep_vlist' `location_vlist', ti" 
*local model1command "sfpanel `dep_vlist' `indep_vlist' `location_vlist', model(bc95)" 
*emean(`indep_vlist') usigma(`indep_vlist')"

* for naming stored estimates
local model1name "bc95"

* options for the predict command. At minimum give the type of 
*  TE calulation formula - jlms is standard (see help sfpanel)
local predict_opts "te"  //"jlms"

 
*------------------------------------------------------------
* Panel Specification
*------------------------------------------------------------
* Run from raw FADN data? (1 = yes)
global databuild = 1


* panel selection
global ms "France Germany Ireland UnitedKingdom" 
global countrylabels "msname"
global sectors "fffadnsy==4110" 
global oldvars "*"
global newvars "*"


global datadir D:\\Data  // path to data directory
global project multisward // name of the folder this file is in


* name the panel (use the name of this file)
global dataname "$project.dta"
********************************************************
********************************************************





*--------------------------------------------
* Data prep and other setup
*--------------------------------------------
* Prepares the FADN data. Tests if data build = 1 first
* If directories are missing, will also make them.

* formatted data for filenames
global datestamp: di  %tdCCYY!_NN!_DD date("$S_DATE", "DMY")

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
	

	*---------------------------------------------- 
	* Project specific setup for the combined panel	
	*---------------------------------------------- 


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
	replace `: label (grassregion) `value'' = 1 if grassregion == `value'
	}

	* grass proxy
	gen fdratio = feedforgrazinglivestockhomegrown/feedforgrazinglivestock
	gen intwt = int(farmsrepresented)


	note: Finished data for multisward paper. - PRG
	save `fadnoutdatadir'/$dataname, replace
}


else{
	use `fadnoutdatadir'/$dataname, clear
}


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

sum landval dpnolu ln*_ha


*--------------------------------------------
*--------------------------------------------






********************************************************
********************************************************
* MODELLING               
********************************************************
********************************************************


* turn on logs 
log using logs/$project$datestamp.txt, replace
di  "Job  Started  at  $S_TIME  on $S_DATE"
cmdlog using logs/$project$datestamp.cmd.txt, replace


* model you selected above is run here
di "`model1command'"
qui `model1command' // <- needs a grass variable


* store estimates and predict ind. TE scores
qui estimates store `model1name'
qui capture drop te_`model1name'
qui predict te_`model1name', `predict_opts'


* constructs ind. level CI's for TE scores
qui frontier_teci te_`model1name'_ci 


save `fadnoutdatadir'/$datanameSFA_post, replace


********************************************************
********************************************************
* End of MODELLING section              
********************************************************
********************************************************







********************************************************
********************************************************
* GENERATING DESCRIPTIVES 
********************************************************
********************************************************


* for supporting discussion of positive sign on hasreps in
* production function (unexpected)
corr `dep_vlist' `indep_vlist'


* some descriptives of the TE scores
tabstat te_`model1name', stats(mean sem) by(country)


********************************************************
********************************************************
* End of GENERATING DESCRIPTIVES section
********************************************************
********************************************************







********************************************************
********************************************************
* CLEANING UP             
********************************************************
********************************************************
* report the model parameters you selected in the log
macro list _dep_vlist _indep_vlist _location_vlist _model1command _model1name _predict_opts databuild ms sectors dataname datadir project 


*clear
capture erase blank.dta
capture log close
capture cmdlog close


********************************************************
********************************************************
*** End of CLEANING UP section
********************************************************
********************************************************





********************************************************
********************************************************
* OUTPUT WILL BE IN THE OUTPUT FOLDER. LOGS WILL BE IN
* THE LOGS FOLDER. DID YOU UNCOMMENT ALL THE PARTS YOU
* WANTED TO RUN?
********************************************************
********************************************************


* You ran the following command


* Here are the model results.
di "Results from model (`model1name')"
di "Actual model command:"
di "`model1command'"
estimates replay `model1name'


qui macro drop _all
