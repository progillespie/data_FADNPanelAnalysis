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
args standalone


* checks to see if the file is being run as a standalone.
*  If $datadir is already set, we assume some other file
*  is calling this one, and we don't reset any globals

if "$datadir" == ""{

	version 9.0
	clear
	clear matrix
	set mem 700m
	set matsize 2500
	set more off

	* Required directory macros
	global datadir G:\Data
	global project niie // name of the folder this file is in

	global databuild = 1 // <- run parameters 
	global ms "Ireland UnitedKingdom" //" "" 
	global countrylabels "msname"
	global sectors "fffadnsy==4110" 
	global oldvars "*"
	global newvars "*" 

}


* locals only apply to the file in which they were set, 
*  so either way they need to be set here
local fadnpaneldir $datadir/data_FADNPanelAnalysis
local fadnoutdatadir `fadnpaneldir'/OutData/$project
local nfspaneldir $datadir/data_NFSPanelAnalysis
local origdatadir `fadnpaneldir'/OrigData 
local fadn9907dir  `origdatadir'/FADN_1
local fadn2dir  `origdatadir'/FADN_2/TEAGSC
local fadn3dir `origdatadir'/FADN_3

* locals will appear at the bottom of the output of this
*   command (beginning with _ )
macro list

* Ensure that required directories exist
capture mkdir `fadnoutdatadir'
capture mkdir `origdatadir'
capture mkdir `fadn9907dir'
capture mkdir `fadn2dir'
capture mkdir output
capture mkdir output/docs
capture mkdir output/graphs
capture mkdir output/graphs
capture mkdir output/graphs/feed
capture mkdir logs
capture mkdir logs/results

cd `fadnpaneldir'/Do_Files/$project


********************************************************
********************************************************
* Building the panels, country by country
********************************************************

if $databuild == 1 {



	* Create a blank dataset to start merging process from
	gen start=1
	save blank, replace
	
	
	
	*************************
	* Top level loop
	*************************
	
	local i = 0
	foreach country of global ms {
	
		local i = `i'+1
	
		*standardising eupanel9907 data
		di "Reading csv file for `country' " ///
			"and cleaning varnames..."
		insheet using `fadn9907dir'/csv/`country'.csv,clear
		qui do sub_do/cleanvarnames.do
		qui do sub_do/labelvars.do
		sort country region subregion farmcode year
		drop if farmcode >= .
		save `fadnoutdatadir'/data`i', replace
 




		*************************
		*************************
		* FADN 2
		*************************
		*************************





		clear
	
		* gets names of all files in `fadn2dir' 
		local file: dir "`fadn2dir'" files *
	
	

		* ctry_select is the first 3 characters of 
		* the filenames in `fadn2dir' corresponding
		* to the countries chosen by $ms

		* only one of the next 27 if statements will
		* be true, so ctry_select will be assigned a
		* value only once per ms

		if "`country'" == "Austria" {
			local  ctry_select = "ost"
		}
		if "`country'" == "Belgium" {
			local   ctry_select = "bel"
		}
		if "`country'" == "Bulgaria" {
			local   ctry_select = "bgr"
		}
		if "`country'" == "Cyprus" {
			local   ctry_select = "cyp"
		}
		if "`country'" == "CzechRepublic" {
			local   ctry_select = "cze"
		}
		if "`country'" == "Denmark" {
			local   ctry_select = "dan"
		}
		if "`country'" == "Estonia" {
			local   ctry_select = "est"
		}
		if "`country'" == "Finland" {
			local   ctry_select = "suo"
		}
		if "`country'" == "France" {
			local   ctry_select = "fra"
		}
		if "`country'" == "Germany" {
			local   ctry_select = "deu"
		}
		if "`country'" == "Greece" {
			local   ctry_select = "ell"
		}
		if "`country'" == "Hungary" {
			local   ctry_select = "hun"
		}
		if "`country'" == "Ireland" {
			local   ctry_select = "ire"
		}
		if "`country'" == "Italy" {
			local   ctry_select = "ita"
		}
		if "`country'" == "Latvia" {
			local   ctry_select = "lva"
		}
		if "`country'" == "Lithuania" {
			local   ctry_select = "ltu"
		}
		if "`country'" == "Luxembourg" {
			local   ctry_select = "lux"
		}
		if "`country'" == "Malta" {
			local   ctry_select = "mlt"
		}
		if "`country'" == "Netherlands" {
			local   ctry_select = "ned"
		}
		if "`country'" == "Poland" {
			local   ctry_select = "pol"
		}
		if "`country'" == "Portugal" {
			local   ctry_select = "por"
		}
		if "`country'" == "Romania" {
			local   ctry_select = "rou"
		}
		if "`country'" == "Slovakia" {
			local   ctry_select = "svk"
		}
		if "`country'" == "Slovenia" {
			local   ctry_select = "svn"
		}
		if "`country'" == "Spain" {
			local   ctry_select = "esp"
		}
		if "`country'" == "Sweden" {
			local   ctry_select = "sve"
		}
		if "`country'" == "UnitedKingdom" {
			local   ctry_select = "uki"
		}
		
		di "ctry_select is set to: `ctry_select'"
		macro list _file	


		*************************
		* Sub loop 1 - Clean and save FADN2 data before merging
		*************************
  

		foreach filename of local file{

			* check to see if start of filename corresponds
			*   matches
			* ctry_select, and if so, load, clean, append
			*   and save

			local ctry_yr = substr("`filename'", 1, ///
			 length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				insheet using `fadn2dir'/`filename', comma clear

				di "Renaming merge vars to match eupanel data"
				qui do sub_do/cleanvarnames.do
				qui do sub_do/labelvars.do


				sort country region subregion farmcode year

				note: Intermediate dataset. Contains additional ///
					 FADN variables for merge with eupanel data

				di "Saving `ctry_yr' as `fadn2dir'/`ctry_yr'.dta"
				save `fadn2dir'/../dta/`ctry_yr'.dta, replace
			}
			
		}
		
		
		*************************
		* Sub loop 2 - Append all FADN2 years before merging with eupanel
		*************************
		
		* drop all obs but keep varnames to append without duplicating obs
		drop if _n > = 1
		
		* command should show 0 obs but the same number of vars as before
		describe, short



		foreach filename of local file{

			* check to see if start of filename matches
			* ctry_select, and if so, load, clean, append and save

			local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				append using `fadn2dir'/../dta/`ctry_yr'.dta 

				note: Intermediate dataset. Contains additional ///
					FADN variables to be merged with        ///
					eupanel data
			}
			
		}


		save `fadn2dir'/../dta/`country'.dta, replace



		* Merge eupanel and FADN2 data
		
		use `fadnoutdatadir'/data`i'.dta, clear
		sort country region subregion farmcode year
		di "Merging/appending from `country'.dta..."

		merge 1:1 country region subregion farmcode year using	///
		 `fadn2dir'/../dta/`country'.dta, nonotes nolabel 	///
		  noreport keepusing($newvars) update

		drop if [_merge == 2 | _merge == 5]
		drop _merge
			




		*************************
		*************************
		* FADN 3
		*************************
		*************************





		clear
	
		* get filenames in `fadn3dir'/TEAGASC
		local file: dir "`fadn2dir'/TEAGASC" files *


		if "`country'" == "Austria" {
			local  ctry_select = "ost"
		}
		if "`country'" == "Belgium" {
			local   ctry_select = "bel"
		}
		if "`country'" == "Bulgaria" {
			local   ctry_select = "bgr"
		}
		if "`country'" == "Cyprus" {
			local   ctry_select = "cyp"
		}
		if "`country'" == "CzechRepublic" {
			local   ctry_select = "cze"
		}
		if "`country'" == "Denmark" {
			local   ctry_select = "dan"
		}
		if "`country'" == "Estonia" {
			local   ctry_select = "est"
		}
		if "`country'" == "Finland" {
			local   ctry_select = "suo"
		}
		if "`country'" == "France" {
			local   ctry_select = "fra"
		}
		if "`country'" == "Germany" {
			local   ctry_select = "deu"
		}
		if "`country'" == "Greece" {
			local   ctry_select = "ell"
		}
		if "`country'" == "Hungary" {
			local   ctry_select = "hun"
		}
		if "`country'" == "Ireland" {
			local   ctry_select = "ire"
		}
		if "`country'" == "Italy" {
			local   ctry_select = "ita"
		}
		if "`country'" == "Latvia" {
			local   ctry_select = "lva"
		}
		if "`country'" == "Lithuania" {
			local   ctry_select = "ltu"
		}
		if "`country'" == "Luxembourg" {
			local   ctry_select = "lux"
		}
		if "`country'" == "Malta" {
			local   ctry_select = "mlt"
		}
		if "`country'" == "Netherlands" {
			local   ctry_select = "ned"
		}
		if "`country'" == "Poland" {
			local   ctry_select = "pol"
		}
		if "`country'" == "Portugal" {
			local   ctry_select = "por"
		}
		if "`country'" == "Romania" {
			local   ctry_select = "rou"
		}
		if "`country'" == "Slovakia" {
			local   ctry_select = "svk"
		}
		if "`country'" == "Slovenia" {
			local   ctry_select = "svn"
		}
		if "`country'" == "Spain" {
			local   ctry_select = "esp"
		}
		if "`country'" == "Sweden" {
			local   ctry_select = "sve"
		}
		if "`country'" == "UnitedKingdom" {
			local   ctry_select = "uki"
		}
		
		di "ctry_select is set to: `ctry_select'"
		macro list _file	



		*************************
		* Sub loop 3 - Clean and save FADN2 data before merging
		*************************
		  

		foreach filename of local file{

			* check to see if start of filename corresponds
			*   matches
			* ctry_select, and if so, load, clean, append
			*   and save

			local ctry_yr = substr("`filename'", 1, ///
			 length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				insheet using `fadn3dir'/TEAGASC/`filename', comma clear

				di "Renaming merge vars to match eupanel data"
				qui do sub_do/cleanvarnames.do
				qui do sub_do/labelvars.do


				sort country region subregion farmcode year

				note: Intermediate dataset. Contains additional ///
					 FADN variables for merge with eupanel data

				di "Saving `ctry_yr' as `fadn3dir'/TEAGASC/`ctry_yr'.dta"
				save `fadn3dir'/TEAGASC/dta/`ctry_yr'.dta, replace
			}
			
		}
		
		
		*************************
		* Sub loop 4 - Append all FADN2 years before merging with eupanel
		*************************
		
		* drop all obs but keep varnames to append without duplicating obs
		drop if _n > = 1
		
		* command should show 0 obs but the same number of vars as before
		describe, short



		foreach filename of local file{

			* check to see if start of filename matches
			* ctry_select, and if so, load, clean, append and save

			local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				append using `fadn3dir'/TEAGASC/dta/`ctry_yr'.dta 

				note: Intermediate dataset. Contains additional ///
					FADN variables to be merged with        ///
					eupanel data
			}
			
		}


		save `fadn3dir'/TEAGASC/dta/`country'.dta, replace



		* Merge eupanel and FADN2 data
		
		use `fadnoutdatadir'/data`i'.dta, clear
		sort country region subregion farmcode year
		di "Merging/appending from `country'.dta..."

		merge 1:1 country region subregion farmcode year using	///
		 `fadn2dir'/../dta/`country'.dta, nonotes nolabel 	///
		  noreport keepusing($newvars) update

		drop if [_merge == 2 | _merge == 5]
		drop _merge





















		
		* ... more cleaning
		drop if farmcode >= .

		* the following variable has 0 obs. 
		drop v201
		
		* check number of obs and vars
		describe, short
		
		* farmcode is not unique across countries
		* so create a unique panel id (only relevant
		* for multi-country panels, commented out but kept
		* for reference)
		*egen pid = group(country region subregion farmcode)
		*destring pid, replace
		*tsset pid year
		*label variable farmcode "ID (only unique within country)" 
		*label variable pid "ID (unique for whole panel)"
		

		
		*---------------------------------------------------------------*
		/* the variable for farmer's age is actually the year of birth.
		    worse, some times this is recorded as a 4 digit year, and 
		    sometimes a two digit year (within the same country-year 
		    dataset!!!). the following code fixes that and drops 0
		    observations (presumed missing or refused, as the number of
		    farmers implied to be over 100 is implausible.) The
		    caculation of the age variable is left to the do-file 
		    renameFADN.do as it will take the NFS naming convention
		    there.	*/
		
		drop if unpaidregholdermgr1yb == 0
		gen yrborn = unpaidregholdermgr1yb
		gen yearcriteria = unpaidregholdermgr1yb - 1900
		replace yrborn = unpaidregholdermgr1yb + 1900 if yearcriteria<0
		*---------------------------------------------------------------*

		* select Northern Ireland if working with UK data
		*if "`country'" == "UnitedKingdom" {
			*keep if region == 441
		*}

		* check number of obs and vars
		describe, short


		* Make compatible with NFS coding conventions
		qui do sub_do/renameFADN.do

		* check number of obs and vars
		describe, short

		qui do sub_do/doFarmDerivedFADN.do
	
		* check number of obs and vars
		describe, short


		tsset farmcode year
		note: Cleaned and merged FADN data panel for $ms		
		keep if $sectors	


		gen PLand = rentpaid/renteduaa
		replace PLabour = wagespaid/flabpaid

		save `fadnoutdatadir'/data`i'.dta, replace
			
		
		* next 3 lines list vars in the dataset for quick reference
	
		describe, replace
		save `fadnoutdatadir'/data`i'_varlist.dta, replace
		outsheet using `fadnoutdatadir'/data`i'_varlist.csv ///
			,comma replace
	}
}
********************************************************
********************************************************
*use `fadnoutdatadir'/data`i'.dta, replace
*codebook year country region
