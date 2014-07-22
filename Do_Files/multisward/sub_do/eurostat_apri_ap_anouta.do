
/*******************************************************
       Patrick R. Gillespie                            
       Walsh Fellow                    
       Teagasc, REDP                           
       patrick.gillespie@teagasc.ie            
********************************************************

	Clean up and import Eurostat data

		- requires data downloaded from 
		  Eurostat, stored in OrigData/Eurostat

		- `series' is the name of the folder
		  containing csv data files (select
		  "Full extraction" and "Multiple Files"
		  on Eurostat webapp). The series number
		  will be on the zip file you download.

		- separate do file for each `series', as
		  format of csv's can change for each.
		  These do files will be broadly similar, 
		  but each will have been 'tweaked' to 
		  get the specified series in correctly. 
		  
*******************************************************/



/*-----------------------------------------------------
 Test whether subdo mode is turned on, and set macros
  if not.
-----------------------------------------------------*/

/* First tell Stata to look for value of `runningmode' 
    in the "do" command that called this do-file. If none
    exists, or if its not set to "subdo" then code in the
    "else" block will run, and necessary macros will be 
    set there. If "subdo" is set then global macros already
    exist and a message is displayed to acknowledge this. */
args runningmode


if "`runningmode'" == "subdo" {

	di "Subdo mode turned on. Using macros from master file."

}


else {
	* Directory parameters
	global 	datadir  	"G:\\Data"   	// path to data directory
	global 	project  	"multisward" 	// folder this file is in
	
	
	* Databuild parameters
	global countrylabels 	"ms2"
	global 	ms 		"France Germany Ireland UnitedKingdom" 
	
	* Define the label ms2 for the country variable
	capture label define ms2 ///
	1  "BE" 		 ///
	2  "BG" 		 ///
	3  "CY" 		 ///
	4  "CZ" 		 ///
	5  "DK" 		 ///
	6  "DE" 		 ///
	7  "ES" 		 ///
	8  "EE" 		 ///
	9  "FR" 		 ///
	10 "HU" 		 ///
	11 "IT" 		 ///
	12 "LT" 		 ///
	13 "LU" 		 ///
	14 "LV" 		 ///
	15 "NL" 		 ///
	16 "AT" 		 ///
	17 "PL" 		 ///
	18 "PT" 		 ///
	19 "FI" 		 ///
	20 "RO" 		 ///
	21 "SE" 		 ///
	22 "SK" 		 ///
	23 "SI" 		 ///
	24 "UK" 		 ///
	25 "IE" 


	di "Running mode not set to subdo. Using globals defined in this file for a standalone run."
	macro list datadir project countrylabels ms
}

/*--------------------------------------------------------
 Running mode established. Global macros available.
--------------------------------------------------------*/



/*--------------------------------------------------------
 Set locals in either case
--------------------------------------------------------*/

local 	series 		"apri_ap_anouta"
local  	dropincomplete	=0
local 	prefix		"P"


* Directory check done, you can now define directory 
*   locals for this file (FADNprep.do's locals gone now)
local fadnpaneldir 	$datadir/data_FADNPanelAnalysis
local fadnoutdatadir 	`fadnpaneldir'/OutData/$project
local nfspaneldir 	$datadir/data_NFSPanelAnalysis
local origdatadir 	`fadnpaneldir'/OrigData 
local fadn9907dir  	`fadnpaneldir'/OrigData/eupanel9907
local fadn2dir  	`fadnpaneldir'/OrigData/FADN_2/TEAGSC
local estatdir		`origdatadir'/Eurostat/`series' 	



local 	eurostat_filelist	: dir "`estatdir'" files "*data*"

/*--------------------------------------------------------
 Locals set
--------------------------------------------------------*/



/*--------------------------------------------------------
 CREATING tmp_ files for merging
--------------------------------------------------------*/

foreach file of local eurostat_filelist	{

	di "Reading `estatdir'/`file'"
	
	insheet using `estatdir'/`file', comma clear double
	
	
	gen 	country     = ""
	replace country = "OST"  if geo == "Austria"
	replace country = "BEL"  if geo == "Belgium"
	replace country = "BGR"  if geo == "Bulgaria"
	replace country = "CYP"  if geo == "Cyprus"
	replace country = "CZE"  if geo == "Czech Republic"
	replace country = "DAN"  if geo == "Denmark"
	replace country = "EST"  if geo == "Estonia"
	replace country = "SUO"  if geo == "Finland"
	replace country = "FRA"  if geo == "France"
	replace country = "DEU"  if word(geo, 1) == "Germany" 
	replace country = "ELL"  if geo == "Greece"
	replace country = "HUN"  if geo == "Hungary"
	replace country = "IRE"  if geo == "Ireland"
	replace country = "ITA"  if geo == "Italy"
	replace country = "LVA"  if geo == "Latvia"
	replace country = "LTU"  if geo == "Lithuania"
	replace country = "LUX"  if geo == "Luxembourg"
	replace country = "MLT"  if geo == "Malta"
	replace country = "NED"  if geo == "Netherlands"
	replace country = "POL"  if geo == "Poland"
	replace country = "POR"  if geo == "Portugal"
	replace country = "ROU"  if geo == "Romania"
	replace country = "SVK"  if geo == "Slovakia"
	replace country = "SVN"  if geo == "Slovenia"
	replace country = "ESP"  if geo == "Spain"
	replace country = "SVE"  if geo == "Sweden"
	replace country = "UKI"  if geo == "United Kingdom"
	*label values country $countrylabels 
	
	
	ds
	local prod_var : word 4 of `r(varlist)'
	
	
	local 	prodvar	: di `prod_var'[1]
	local 	short_prodvar	/*
	*/	: di subinstr("`prodvar'", " ","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", ":","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", "-","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", "(","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", ")","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", "%","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", ";","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", ",","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", ".","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", "+","", .)
	local 	short_prodvar	/*
	*/	: di subinstr("`short_prodvar'", "/","_", .)
	local 	short_prodvar	/*
	*/	: di substr("`short_prodvar'", 1, 30)
	
	
	local 	currency	: di currency[1]
	macro 	list 		_currency
	local 	currency	/*
	*/ 	: di substr("`currency'", 1, strpos("`currency'", " ")-1)
	macro 	list 		_currency
	
	
	local 	varlabel	: di "`prodvar' (`currency')"
	macro 	list 		_varlabel
	
	
	rename 	time 	year


	rename 	value 	`prefix'`short_prodvar'
	label variable `prefix'`short_prodvar' "`varlabel'"


	* Create a list recording new varnames
	local prod_vlist "`prod_vlist' `prefix'`short_prodvar'"
	
	
	keep country year geo `prefix'`short_prodvar'
	sort country year
	
	
	local 	thisfilename		/*
	*/	: di substr("`file'", 1, strpos("`file'", ".csv") -1)
	
	local 	tmp_filelist	"`tmp_filelist' `thisfilename'"
	macro list _thisfilename _fadnoutdatadir
	save `fadnoutdatadir'/tmp_`thisfilename', replace

}

/*--------------------------------------------------------
 END OF LOOP - tmp_ FILES CREATED
--------------------------------------------------------*/



* The print to screen to visually inspect varnames and filenames
macro list _prod_vlist _tmp_filelist


* Keep just the key variables to start merge from 
keep year country


* Merge the tmp_ files to a master file, then erase tmp's
foreach file of local tmp_filelist{

	merge 1:1 country year using `fadnoutdatadir'/tmp_`file'
	drop _merge
	save `fadnoutdatadir'/eurostat_`series', replace
 	erase `fadnoutdatadir'/tmp_`file'.dta 

}




* Remove some common non-numeric charactrers
foreach var of varlist `prefix'* {

	replace `var' = subinstr(`var', ":", "", .)
	replace `var' = subinstr(`var', ",", "", .)

}

keep if country =="FRA" | country=="UKI" | country=="IRE" | country=="DEU"
keep if year <= 2007


/* Change to appropriate data types for string vars (should be numeric)
    `prefix'* will give the list of all vars bar country, year, and geo.
     The destring must be done here for the missing test to work because
     misstable only works with numeric vars.			      */
destring `prefix'*, replace 


* DROPPING INCOMPLETE VARIABLES
foreach var of varlist `prefix'* {

	* Creates table of missing values for `var' (i.e. ".", ">.", etc)
	misstable summarize `var'
	

	/* Save total number of missings (all categories) as scalar. The
      	    macros on the right hand side are created by misstable.   
	    The macros themselves are...
		r(N_eq_dot) -> # of `var' obs whose value = "."
		r(N_gt_dot) -> # of `var' obs whose value > "."        */
	scalar define missing_count = `r(N_eq_dot)' + `r(N_gt_dot)'


	/* Drop variable (entire column) if any ob is missing
	    NOTE: drop if `var' >= . would just drop rows with missings 
                   which is NOT what we want here.                     */
	if missing_count > 0 & missing_count < . & `dropincomplete' == 1 {

		drop `var'

	}
	

	scalar drop missing_count

}


/* Save the master data, which should have year, country, geo, and all 
    of the `prefix' vars (previously called value) in a single dataset */
save `fadnoutdatadir'/eurostat_`series', replace


/* If the next command causes Stata to tell you that there are no vars 
    matching this pattern, then all the vars in the underlying data have
    missing values for the panel  you're studying. Setting the local 
    dropincomplete to 0 (or anything other than 1) will get the vars 
    back, but they will all have at least one missing value.           */
describe `prefix'*
