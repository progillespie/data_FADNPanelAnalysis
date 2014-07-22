* Based on msward_code_clarity.do
capture log close
capture cmdlog close
version 9.0
clear
clear matrix
set mem 700m
set matsize 5000 
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
network, this code won't run. 
*******************************************************
This version:

  - Cost results presented at 2013 Walsh Fellowship
    Seminar. 
  - Based on (copy of) msward_2013_11_22_cost.do

*******************************************************
*******************************************************/










********************************************************
* Run Analysis
********************************************************
* 4 Subsections: 
	* Data and project directories
	* Variable lists
	* Model commands 
	* Panel Specification
********************************************************

*------------------------------------------------------------
* Data and project directories
*------------------------------------------------------------

* tell the code where your Data and project Directories are

global 	datadir  D:\\Data   	// path to data directory
global 	project  multisward 	// name of the folder this file is in



*------------------------------------------------------------
* Variable lists
*------------------------------------------------------------

/*  NOTE: will automatically calculate logs for variables with "ln"
	prefix. Will calculate per hectare, LU, or litre, if var
        has "_ha", "_lu", "_lt" suffix. */

*===============================
* Output quantities (q)
*local 	lnq_vlist 	"lndotomkglndx " // measure of output (simple index)
*local 	lnq_vlist 	"lndairyproductsndx" // measure of output (physical quantity)
local 	lnq_vlist 	"lndairyproducts" // measure of output (physical quantity)
*local 	lnq_vlist 	"lndairyproducts_ha" // measure of output (physical quantity)
*local 	lnq_vlist 	"lndotomkgl " // measure of output (physical quantity)
*local 	lnq_vlist 	"lntotaloutput" // measure of output (nominal euro)
*===============================



*===============================
* Input quantities (x)
local 	lnx_vlist	"`lnx_vlist' lnfdferfil"
local 	lnx_vlist 	"`lnx_vlist' lnfeedforgrazinglivestockpurch"
*local 	lnx_vlist	"`lnx_vlist' lndaforare"
*local 	lnx_vlist	"`lnx_vlist' lnfsizuaa"
*local 	lnx_vlist	"`lnx_vlist' lnforagearea"
local 	lnx_vlist	"`lnx_vlist' lndpnolu"
local 	lnx_vlist	"`lnx_vlist' lnlabourinputhours"
*local 	lnx_vlist	"`lnx_vlist' lnmachinery_q"
*local 	lnx_vlist	"`lnx_vlist' lnbuildings_q"
*===============================



*===============================
* Cost (c)
*local 	lnc_vlist	"lntotalinputs"
local 	lnc_vlist	"lntotalspecificcosts"
*===============================



*===============================
* Prices (w)

* CALCULATED FROM FADN VARIABLES
* ------------------------------
*local 	lnw_vlist 	"`lnw_vlist' lnPLand" 
local 	lnw_vlist 	"`lnw_vlist' lnPTotalCattle" 
*local 	lnw_vlist 	"`lnw_vlist' lnPLabour"  
* EUROSTAT PRICE INDICES
* ---------------------
	* FEED
*local 	lnw_vlist 	"`lnw_vlist' lnPCompoundfeedingstuffsforcalv"
local 	lnw_vlist 	"`lnw_vlist' lnPCompoundfeedingstuffsforcatt"
*local 	lnw_vlist 	"`lnw_vlist' lnPCerealsandmillingbyproducts"
*local 	lnw_vlist 	"`lnw_vlist' lnPOilcakes"
	* FERTILISER
*local 	lnw_vlist 	"`lnw_vlist' lnPOtherfertilizerssoilimprovers"
local 	lnw_vlist 	"`lnw_vlist' lnPFERTILISERSANDSOILIMPROVERS"
*local 	lnw_vlist 	"`lnw_vlist' lnPNitrogenousfertilizers"
	* ANY REMAINING COSTS
*local 	lnw_vlist 	"`lnw_vlist' lnPElectricity" 
*local 	lnw_vlist 	"`lnw_vlist' lnPMotorfuels" 
*local 	lnw_vlist 	"`lnw_vlist' lnPVETERINARYEXPENSES"
*local 	lnw_vlist 	"`lnw_vlist' lnPSEEDSANDPLANTINGSTOCK"
*local 	lnw_vlist 	"`lnw_vlist' lnPMACHINERYANDOTHEREQUIPMENT"
*local 	lnw_vlist 	"`lnw_vlist' lnPMAINTENANCEOFBUILDINGS"
*local 	lnw_vlist 	"`lnw_vlist' lnPOTHERGOODSANDSERVICES"
*===============================



*===============================
* Environmental variables (z)
local 	z_vlist		"`z_vlist' lngrassratio"
*local 	z_vlist		"`z_vlist' fdratio"
*local 	z_vlist		"`z_vlist' lnogagehld"
local 	z_vlist		"`z_vlist' lnspecial"
*local 	z_vlist		"`z_vlist' lnintense"
*local   z_vlist 	"`z_vlist' lnfsizuaa"
*local 	z_vlist		"`z_vlist' forage_sh "
*===============================



*===============================
* Location dummies

/* NOTE: The country or region dummies must exist in the data. If
	 they don't exist, create them somewhere in this section 
	 of the code. 						*/ 
*local 	location_vlist 	"`location_vlist' France" 
*local 	location_vlist 	"`location_vlist' Ireland"
*local 	location_vlist 	"`location_vlist' UnitedKingdom"
*local 	location_vlist 	"`location_vlist' Bretagne"
*local 	location_vlist 	"`location_vlist' NormandieHaute"
*local 	location_vlist 	"`location_vlist' NormandieBasse"
*local 	location_vlist 	"`location_vlist' Wales"
*local 	location_vlist 	"`location_vlist' Bayern"
*===============================


*===============================
* Azone dummies
local 	azone_vlist 	"`azone_vlist' azone2"
local 	azone_vlist 	"`azone_vlist' azone3"
*===============================



local 	func_form	"translog" // CobbDouglas


* If creating indices, give the base year for them 
local 	ndxbase		=2000
*------------------------------------------------------------
* Model commands 
*------------------------------------------------------------

* Write the entire command you want to run inside double inverted 
* commas after the second word below 

local 	model1command 	"sfpanel `dep_vlist' `indep_vlist' TREND if country==3, model(bc95) cost d(tnormal) emean(`z_vlist', noconstant)" 

*REMOVED: countrycode2#year 


/* Impose linear homogeneity in prices? Will change definition of
    price variables and dependent variable. Should only be run when
    a cost model is specified. 					
 NOTE: If there is only one price specified then this does not apply
 and the pricehomogeneity code will be skipped. 		  */
local pricehomogeneity 	= 0


* Is this a cost model? If yes, set `cost' equal to "cost". 
local 	cost 		"" //cost


/* Supply appropriate vlist for your model (e.g. dep_vlist "lnq_vlist"
    indep_vlist "`lnx_vlist for a production frontier). Automatically
    selected based on cost macro set above */
if "`cost'" == "cost" {
	local 	dep_vlist 	"`lnc_vlist'" 
	local 	indep_vlist 	"`lnq_vlist' `lnw_vlist'"
}
else {
	local 	dep_vlist 	"`lnq_vlist'" 
	local 	indep_vlist 	"`lnx_vlist'"
}

* Give a name for stored estimates (e.g. "bc95")
local 	model1name 	"bc95"




* options for the predict command. At minimum give the type of 
*  TE calulation formula - jlms is standard (see help sfpanel)
local 	predict_opts 	"jlms"  // "jlms" "te" "bc"


* Do postestimation tests? (1 = yes)
local	tests		= 0 

* Create postestimation plots (takes a while)?
local	graphs		= 0 

*------------------------------------------------------------
* Panel Specification
*------------------------------------------------------------

* Run from raw FADN data? (1 = yes, all else/missing = no)

global 	databuild = 0



* panel selection

global 	ms 		"Germany France Ireland UnitedKingdom" //
global 	countrylabels 	"msname"	 //ms2, ms3 for 2, 3 character abbrev.
*global 	sectors 	"fffadnsy==4110" //select desired FADN system
global 	sectors 	"principalfarmtype==41" //select desired FADN system
global 	oldvars 	"*"		 //list of desired eupanel vars. * means all.
global 	newvars 	"*"		 //list of desired FADN2 vars. * means all.
global 	grassvars 	"temporarygrassaa meadowpermpastaa roughgrazingaa "  //list of desired FADN4 vars. * means all.

* OrigData to use (1 = use, else don't)
global FADN_1 = 1
global FADN_2 = 1
global FADN_3 = 0
global FADN_4 = 1

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

* Directory check done, you can now define directory 
*   locals for this file (FADNprep.do's locals gone now)
local fadnpaneldir $datadir/data_FADNPanelAnalysis
local fadnoutdatadir `fadnpaneldir'/OutData/$project
local nfspaneldir $datadir/data_NFSPanelAnalysis
local origdatadir `fadnpaneldir'/OrigData 
local fadn9907dir  `origdatadir'/FADN_1
local fadn2dir  `origdatadir'/FADN_2/TEAGSC
local fadn3dir `origdatadir'/FADN_3
local fadn4dir  `origdatadir'/FADN_4/TEAGSC

* Prepares the FADN data. Tests if databuild = 1 first
* If directories are missing, will also make them.

* formatted data for filenames
global datestamp: di  %tdCCYY!_NN!_DD date("$S_DATE", "DMY")
global timestamp: di  %tcHhMMam clock("$S_TIME", "hms")

* get filenames of all data files created by FADNprep.do
local filelist: dir "`fadnoutdatadir'" files "data?.dta"

if $databuild == 1{
	* rename all previous versions of data`i'.dta before 
	foreach file of local filelist{
		di "`file' from previous data build renamed to old_`file'"
		copy `fadnoutdatadir'/`file' `fadnoutdatadir'/old_`file', replace
		erase `fadnoutdatadir'/`file'
	}
}


do sub_do/FADNprep.do




* if building again, append the data`i'.dta's created by 
*  FADNprep.do together and create pid, then save

if $databuild == 1{

	* get filenames of all data files created by FADNprep.do
	local filelist: dir "`fadnoutdatadir'" files "data?.dta"

	* drop all obs 
	drop if _n >= 1

	* get filenames of all data files created by FADNprep.do
	local filelist: dir "`fadnoutdatadir'" files "data?.dta"
	* loop over each filename and append all data
	foreach file of local filelist{
		macro list _file
		append using `fadnoutdatadir'/`file'	
	}
	

	/*---------------------------------------------- 
	 Project specific setup for the combined panel	
	----------------------------------------------*/ 
	

	* create a unique panel id (farmcodes repeat)
	egen pid = group(country region subregion farmcode)
	destring pid, replace
	tsset pid year
	duplicates report pid year

	label variable farmcode "ID (only unique within country)" 
	label variable pid "ID (unique for whole panel)"
	

	* labels country, year, and regions
	do sub_do/valuelabels.do



	* Check if altitudezone exists in data
	capture confirm existence altitudezone, exact
	di _rc
	
	* Do the following commands if it does, else skip
	if !_rc {
	
		* value 4 = "not available" so drop those obs
		drop if altitudezone >= 4
	
		* originally in sub_do/grassregion.do See file for details
		gen grassregion = 7
		label define grassregion  1 "Bretagne" 2 "NormandieHaute" ///
			3 "NormandieBasse" 4 "Wales" 5 "Ireland" 	  ///
			6 "Bayern" 7 "Other" 
		label value grassregion grassregion
		replace grassregion = 1 if region==163
		replace grassregion = 2 if region==133
		replace grassregion = 3 if region==135
		replace grassregion = 4 if region==421
		replace grassregion = 5 if region==380
		replace grassregion = 6 if region==90
	
	
		* generate azone, region and 
		tab(altitudezone), gen(azone)
		
	}
        
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
	
	

	* Check if grassregion exists in data
	capture confirm existence grassregion, exact

	* Do the following commands if it does, else skip
	if !_rc {
		* same idea for creating selected region dummy names 
		levelsof grassregion

		foreach value in `r(levels)' {

		di "Creating `: label (grassregion) `value'' dummy variable"
		gen `: label (grassregion) `value'' = 0
		replace `: label (grassregion) `value'' = 1 if grassregion == `value'

		}

	}



	sort country year
	

	note: Finished data for multisward paper. - PRG
	save `fadnoutdatadir'/$dataname, replace

}


else {
	use `fadnoutdatadir'/$dataname, clear
}





* prepare Eurostat data for merging
qui do sub_do/eurostat_apri_pi00_ina.do subdo

************************************************************

/*----------------------------------------------------------
 Need to build a list of vars to keep from Eurostat, but
    would like for it to be base on indep_vlist. 

 Basic approach is to get the intersection of the two
  varlists, i.e. ALL Eurostat vars and indep_vlist
----------------------------------------------------------*/


* First create list of vars with "ln" prefix stripped away
foreach var of local indep_vlist {

	local thisvar: di substr("`var'", 3, .)
	local indep_root_vlist "`indep_root_vlist' `thisvar'"

}


/* There can be many vars (with long varnames) in the
    Eurostat data. This will quickly exceed the character 
    limit for storing in a macro, so we can't just get
    the intersection of two varlists. Instead, we build 
    the list of vars to keep (much shorter) by checking 
    Eurostat varnames against indep_root_vlist one at 
    a time using a loop. This will ensure every Eurostat
    var is checked, but there will still be problems if 
    indep_vlist exceed the 244 character limit.         */

foreach var of varlist * {

	local thisvar		"`var'"
	local keep_vlist	"`keep_vlist' `thisvar'"
	local keep_vlist	: list keep_vlist & indep_root_vlist

}

* List of all Eurostat vars in dataset...
ds

* ... of which we'll merge (based on indep_vlist)
capture macro list _keep_vlist 

************************************************************

* Load master data and merge Eurostat vars
use `fadnoutdatadir'/$dataname, clear

drop PMotorFuels  // empty var, drop to avoid confusion
merge m:1 country year using 		    ///
    `fadnoutdatadir'/eurostat_apri_pi00_ina ///
    , keepusing(`keep_vlist')               ///
      update replace nogen noreport

*codebook `keep_vlist'               

* Deflate capital variables
gen feedforgrazinglivestockpurch = feedforgrazinglivestock - feedforgrazinglivestockhomegrown

capture confirm variable PMACHINERYANDOTHEREQUIPMENT PMAINTENANCEOFBUILDINGS, exact
if _rc==0 {
	gen machinery_q = machinery/PMACHINERYANDOTHEREQUIPMENT
	gen buildings_q = buildings/PMAINTENANCEOFBUILDINGS
}

*-----------------
* Logged variables
*-----------------
* create list of vars to log based on dep_vlist
	*  and indep_vlist. This should be run whether
	*  or not running from raw data
capture gen PLand = rentpaid/renteduaa // create unless already exists
replace PLand = rentpaid/renteduaa     // if already there, then redefine it
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

local dep_root_vlist: di substr("`dep_vlist'", 3, .)
local root_vlist "`dep_root_vlist' `indep_root_vlist'"
macro list _root_vlist

foreach var of local root_vlist {

	macro list _var
	local testdi: di substr("`var'", -3, .) 
	di "`testdi'"
	
	if substr("`var'", -3, .) == "ndx" {

		* Strip away ndx suffix
		local thisvar: di substr("`var'", 1, length("`var'")-3)
		local testlist "`testlist' `thisvar'"
		
		* Create variable which repeats the year 2000 value for each pid row
		bysort pid: gen double tmp_baseyr_1val = `thisvar' if year==`ndxbase' // "." in off years
		bysort pid: egen double tmp_baseyr_vals = mean(tmp_baseyr_1val) // value in off years

		* Drop when farm isn't in sample in base year
		drop if tmp_baseyr_vals >= . // 

		* Simple index is value/value_in_base_year
		bysort pid: gen double `thisvar'ndx =  100 * `thisvar'/tmp_baseyr_vals 
		drop tmp*
	
		
	}

}

capture macro list _testlist 



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
	    local tmp_denom "dairyproducts"
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
* This scalar just prevents error in the case of only one price
scalar define w_varcount = wordcount("`lnw_vlist'")
scalar list w_varcount


*--------------------------------------------------------------------------
* Price homogeneity
*--------------------------------------------------------------------------
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
	local model1command: list model1command - lnnumeraire
	local indep_vlist: list indep_vlist - lnnumeraire
	
	macro list _w_vlist _numeraire_price _homog_vars _homog_cost _homog_vars _lnnumeraire _dep_vlist _indep_vlist 
	
}



*--------------------------------------------------------------------------
* Imposing the CRS constraint (code only works for CD form)
*--------------------------------------------------------------------------
/*-   First use indep_vlist to write out LHS of constraint*/

foreach var of local w_vlist{

	local constr_CRS "`constr_CRS' `var' +"
	
}


/* remove trailing "+" by redefining the macro as itself less the 
    final 2 characters 						*/

local	constr_CRS	: di substr( "`constr_CRS'" , 1 , length("`constr_CRS'") - 2)


/* - Constraint's LHS side is now written as a macro, will reflect whatever
      set of vars go into indep_vlist, so this list should only include 
      the var's for which CRS apply. Now define the constraint using the 
      constraint command and the macro just created 			*/
local i = `i' + 1
constraint 1 `constr_CRS' = 1 


/* Constrained optimization will take place if constraint(1) is specified as
    an option in model1command*/

capture macro list _constr_CRS



*--------------------------------------------------------------------------
* Functional Forms
*--------------------------------------------------------------------------
* Sets primary terms and a self-reducing list of interactions (starts 
*  as identical to CobbDouglas list)
local CobbDouglas	"`indep_vlist'"
local interactions 	"`CobbDouglas'"	
local i = 0 // setting the index numbers may be unnecessary
local j = 0
local CobbDouglas_terms " "
local translog_terms	" "
local translog_eqn	" "

/* Translog is Cobb Douglas + 1/2 squares and interactions. Loop below
    uses an algorithm that takes the CobbDouglas list, calculates the 
    square and interactions for the first variable, removes that from 
    the list, then repeat. The result could be represented as a lower 
    triangular matrix of squares and interactions, reminiscent of a 
    Variance-Covariance matrix. 					*/ 

if "`func_form'" == "translog" {
	
	* First, demean the variables in the CobbDouglas list, and
	*  take logs again

	
	local tdepvar : di substr("`dep_vlist'", 3, .)
	qui summ `tdepvar'
	replace `tdepvar' = `tdepvar' - `r(mean)'
	replace `dep_vlist' = ln(`tdepvar') 

	foreach lnvar of local CobbDouglas {
	
		local var : di substr("`lnvar'", 3, .)
		qui summ `var'
		replace `var' = `var'-`r(mean)'
		replace ln`var' = ln(`var')
	}

	* Now create translog terms and compile a new list of vars for
        *  the model.
	foreach lnvar of local CobbDouglas {
	
		local i = `i' + 1
		local j = `i' 
		local var : di substr("`lnvar'", 3, .)
	
		
		foreach lnvar2 of local interactions {
	
			* Generates X_i^2, then interactions
			local var2 : di substr("`lnvar2'", 3, .)
			gen X_`i'`j' = `var' * `var2' 
	
			* Terms enter function as 0.5 * logs
			gen half_lnX_`i'`j' = 0.5 * log(X_`i'`j')
			label variable 	half_lnX_`i'`j' 	///
				"0.5 * log(`var' * `var2')"
			
			* Compile in a handy list
			local translog_terms "`translog_terms' half_lnX_`i'`j'"
	
			* iterate j
			local j = `j'+ 1
	
		}
	
		gen CD_`i'   = `var' 	
		gen lnCD_`i' = `lnvar'	
		local CobbDouglas_terms "`CobbDouglas_terms' CD_`i'"
		local interactions: list interactions - lnvar
	}
	
	
	local translog_eqn "`CobbDouglas_terms' `translog_terms'"
	local indep_vlist  "`translog_eqn'"
	macro list _CobbDouglas_terms _translog_terms _translog_eqn _func_form _indep_vlist
	
	
	* Use describe and the var labels to ensure correct calculation
	describe half*
}

encode country, gen(countrycode2)
qui sum year
scalar define min_year = `r(min)'
gen TREND =year-min_year+1

* grass proxy
capture drop fdratio 
capture drop forage_sh 
capture drop lnfdratio 
capture drop intwt
gen fdratio = (feedforgrazinglivestockhomegrown/feedforgrazinglivestock)
gen grass_sh = (temporarygrassaa+meadowpermpastaa+roughgrazingaa)/foragecropsuaa
gen grassratio = fdratio * grass_sh * 100
gen special    = dpallocgo * 100
gen intense    = (dairyproduct/daforare) *100
gen lnfdratio = ln(fdratio)
gen lngrassratio = ln(grassratio)
gen lnspecial = ln(special)
gen lnintense = ln(intense)
gen intwt = int(farmsrepresented)

	
*===============================*
* Define Biogeographical Zones
*===============================*

* Atlantic Plains
gen 	atl_plains = 0 if region==133
replace atl_plains = 1 if region==133
replace atl_plains = 1 if region==135
replace atl_plains = 1 if region==163
replace atl_plains = 1 if region==421 
replace atl_plains = 1 if region==431 
replace atl_plains = 1 if region==441 
replace atl_plains = 1 if region==380 

label define atl_plains 0 "Not in Atlantic Plains" 1 "In Atlantic Plains" 
label value atl_plains atl_plains 

* Continental Europe
gen 	cont_eur= 0
replace cont_eur= 1 if atl_plains!=1

label define cont_eur 0 "Not in Continental Europe" 1 "In Continental Europe" 
label value cont_eur cont_eur 


sort country year

********************************************************
* End of Data prep and other setup
********************************************************







********************************************************
* MODELLING               
********************************************************

sort pid year


* turn on logs 
log using logs/$project$datestamp.txt, append text
di  "Job  Started  at  $S_TIME  on $S_DATE"
cmdlog using logs/$project$datestamp.cmd.txt, append 




preserve


drop country
gen int country = countrycode2
keep pid year country `dep_vlist' `indep_vlist' `z_vlist' TREND

outsheet _all using `fadnoutdatadir'/exported_data.csv, comma replace nolabel
save `fadnoutdatadir'/exported_data.dta, replace nolabel

restore



* ===================
* MODEL COMMANDS HERE
* ===================
if "`cost'"=="cost"{
	local 	tech_or_cost	"cost"
}
else{
	local 	tech_or_cost	"tech"
}
/*
sfpanel `dep_vlist' `indep_vlist' TREND if country == "DEU",  `cost' model(bc95) d(tnormal) posthessian robust emean(`z_vlist') vsigma(TREND)
estimates store `model1name'_DEU_`tech_or_cost'
estimates save `fadnoutdatadir'/`model1name'_DEU_`tech_or_cost'_$datestamp$timestamp.ster, replace
di `e(converged)'

sfpanel `dep_vlist' `indep_vlist' TREND if country == "FRA",  `cost' model(bc95) d(tnormal) posthessian robust emean(`z_vlist') usigma(`z_vlist') vsigma(TREND)
estimates store `model1name'_FRA_`tech_or_cost' 
estimates save `fadnoutdatadir'/`model1name'_FRA_`tech_or_cost'_$datestamp$timestamp.ster, replace
di `e(converged)'
*/
xtreg  `dep_vlist' `indep_vlist' TREND, re
sfpanel `dep_vlist' `indep_vlist' TREND if country == "IRE",  `cost' model(tre) d(tnormal) posthessian robust svfrontier(e(b))// emean(`z_vlist') usigma(`z_vlist') 
estimates store `model1name'_IRE_`tech_or_cost'
estimates save `fadnoutdatadir'/`model1name'_IRE_`tech_or_cost'_$datestamp$timestamp.ster, replace
di `e(converged)'
/*
sfpanel `dep_vlist' `indep_vlist' TREND if country == "UKI",  `cost' model(bc95) d(tnormal) posthessian robust emean(`z_vlist') usigma(`z_vlist')
estimates store `model1name'_UKI_`tech_or_cost'
estimates save `fadnoutdatadir'/`model1name'_UKI_`tech_or_cost'_$datestamp$timestamp.ster, replace
di `e(converged)'

sfpanel `dep_vlist' `indep_vlist' TREND if atl_plains == 1, `cost'  model(bc95) d(tnormal) posthessian robust emean(`z_vlist') usigma(`z_vlist') vsigma(TREND)
estimates store `model1name'_ATL_`tech_or_cost'
estimates save `fadnoutdatadir'/`model1name'_ATL_`tech_or_cost'_$datestamp$timestamp.ster, replace
di `e(converged)'

sfpanel `dep_vlist' `indep_vlist' TREND if cont_eur == 1,   `cost' model(bc95) d(tnormal) posthessian robust emean(`z_vlist') usigma(`z_vlist') 
estimates store `model1name'_CEU_`tech_or_cost'
estimates save `fadnoutdatadir'/`model1name'_CEU_`tech_or_cost'_$datestamp$timestamp.ster, replace
di `e(converged)'

* BEST RESULT Effect on Mu parameter = -0.0054 Sigma U Parameter = 2.308268 need to figure out partial effect for this. Non-monotonic effect of grass. HARD CODE for reference. 
*sfpanel lntotalspecificcosts lndairyproducts lnPTotalCattle lnPCompoundfeedingstuffsforcatt lnPFERTILISERSANDSOILIMPROVERS TREND , cost model(bc95) d(tnormal) posthessian robust emean(lngrassratio lnspecial) usigma(lngrassratio lnspecial) vsigma(TREND)

sfpanel `dep_vlist' `indep_vlist' TREND , `cost' model(bc95) d(tnormal) posthessian robust emean(`z_vlist') usigma(`z_vlist') vsigma(TREND)
estimates store `model1name'_ALL_`tech_or_cost'
estimates save `fadnoutdatadir'/`model1name'_ALL_`tech_or_cost'_$datestamp$timestamp.ster, replace
di `e(converged)'
*/
log close
cmdlog close
STOP!!
* ===================



*create list of price parameters to sum for homogeneity test
local est_vlist: colnames e(b)
local lnhomog_w: list lnhomog_w & est_vlist
foreach lnw_var of local lnhomog_w {
	local homog_w_test "`homog_w_test' _b[`lnw_var'] +"
}
* remove trailing "+" from homog_w_test
local homog_w_test: di substr("`homog_w_test'", 1, length("`homog_w_test'")-1)


predict xb, xb
predict u, u
qui reg `dep_vlist' xb u
di "R-squared for reg of predictions + u on `dep_vlist' is `e(r2)'. "
qui xtreg `dep_vlist' `indep_vlist', fe
di "R-squared for xtreg of equivalent spec is `e(r2)'"









* Get the AIC and BIC estimates for the fitted model
estimates stats




qui estimates save  `fadnoutdatadir'/`model1name'$datestamp$timestamp.ster, replace
qui capture drop te_`model1name'





* constructs ind. level CI's for TE scores
*qui frontier_teci te_`model1name'_ci 

/*
* store estimates and predict ind. TE scores
qui estimates store `model2name'
qui estimates save  `model2name'$datestamp.ster, replace
qui capture drop te_`model2name'
qui predict te_`model2name', `predict_opts'
*/

save `fadnoutdatadir'/$datanameSFApost, replace


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
	     H0: Constant variance (i.e. homoscedasticity)   */ 
	estimates restore fixed
	qui xttest3
	local wald_heterosc = "Prob>chi2 = `r(p)'"


}

if `graphs' ==1 {
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
}

estimates restore bc95
*sfpanel
qui predict `model1name'_te, `predict_opts'
*qui predict te_ct_`modelname', ci
predict `model1name'_xb, xb
predict `model1name'_u, u 
gen `model1name'_e = `dep_vlist'-`model1name'_xb
gen `model1name'_v =`model1name'_e - `model1name'_u


local var = "`model1name'_e"
kdensity `var ', normal
graph export `fadnoutdatadir'/normality_`var '.pdf, asis replace
graph drop _all
tw sc `var' xb , yline(0)
graph export `fadnoutdatadir'/heteroscedasticity_`var '.pdf, asis replace
graph drop _all


local var = "`model1name'_v"
kdensity `var ', normal
graph export `fadnoutdatadir'/normality_`var '.pdf, asis replace
graph drop _all
tw sc `var' xb , yline(0)
graph export `fadnoutdatadir'/heteroscedasticity_`var '.pdf, asis replace
graph drop _all


local var = "`model1name'_u"
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
/*1* Checking 1 is simple (shouldn't see any obs < 0) */

foreach lnc_var of local lnc_vlist {
	
	/* we want to check c's not their logs, so
	create new local without "ln" prefix, and
	make a list of these c_var's while you're at it  */
	local c_var: di substr("`lnc_var'", 3, .)
	local c_vlist "`c_vlist' `c_var'"

	count if `c_var' < 0 
}


/*2* Checking 2 means dC/dw >= 0 (depends on functional form)
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

/*3* As q is a regressor, the check is the same is in 2, i.e. check that
      q is always > 0, that _b[q] > 0, and we've already checked C. */

foreach lnq_var of local lnq_vlist {
	
	/* we want to check q not its log, so
	create new local without "ln" prefix, and
	make a list of these q_var's while your at it  */
	local q_var: di substr("`lnq_var'", 3, .)
	local q_vlist "`q_vlist' `q_var'"

	count if `q_var' < 0 
}

/*4* For a Cobb-Douglas, linear homogeneity in prices is satisfied if
           sum(_b[W]) = 1  <- not literal code here, just shorthand
      where W is the whole vector of input prices.       */ 

/* homog_w_test tells the command <test> the prices you used */
capture test `homog_w_test' = 1

/*5* Concavity - You can always check the diagonal of the Hessian
        matrix to determine this. If the Hessian is negative semi-definite
        (i.e. the elements of the diagonal are each < 0) then the cost 
        frontier is convex to the origin. */ 

estimates restore `model1name'_DEU_`tech_or_cost'
matrix list e(hessian)



estimates restore `model1name'_FRA_`tech_or_cost'
matrix list e(hessian)



estimates restore `model1name'_IRE_`tech_or_cost'
matrix list e(hessian)



estimates restore `model1name'_UKI_`tech_or_cost'
matrix list e(hessian)



estimates restore `model1name'_ATL_`tech_or_cost'
matrix list e(hessian)



estimates restore `model1name'_CEU_`tech_or_cost'
matrix list e(hessian)



estimates restore `model1name'_ALL_`tech_or_cost'
matrix list e(hessian)
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
tabstat `model1name'_te, stats(mean sem) by(country)

* describes the relationsip of fdratio to te_tfe
tw (sc `model1name'_te fdratio) (lfit `model1name'_te fdratio, lwidth(thick))
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



* You ran the following command
di "`cmd'"

* Here are the model results. Ignore syntax error if using sfpanel
di "Results from model (`model1name')"
matrix list Bcomb 

macro drop _all
