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
	global ms "Ireland UnitedKingdom" 
	global countrylabels "msname"
	global sectors "fffadnsy==4110" 
	global oldvars "*"
	global newvars "*" 

}		 // closes "if "$datadir" == ..."



* locals only apply to the file in which they were set, 
*  so either way they need to be set here
local fadnpaneldir $datadir/data_FADNPanelAnalysis
local fadnoutdatadir `fadnpaneldir'/OutData/$project
local nfspaneldir $datadir/data_NFSPanelAnalysis
local origdatadir `fadnpaneldir'/OrigData 
local fadn9907dir  `fadnpaneldir'/OrigData/eupanel9907
local fadn2dir  `fadnpaneldir'/OrigData/FADN_2/TEAGSC


* locals will appear at the bottom of the output of this
*   command (beginning with _ )
macro list


* make sure that your fadnoutdatadir exists
capture mkdir `fadnoutdatadir'


cd `fadnpaneldir'/Do_Files/$project



di "*________________________________________________________"

di "* Top level if -- Do we build the panel?"

di "*________________________________________________________"


if $databuild == 1 {

	* Create a blank dataset to start merging process from
	gen start=1
	save blank, replace
	
	
	

	di "*************************"
	di "* Top level loop"
	di "*************************"
	

	local i = 0
	foreach country of global ms {
	
		local i = `i'+1
	
		*standardising eupanel9907 data
		di "Reading csv file for `country' and cleaning varnames..."
		insheet using `fadn9907dir'/csv/`country'.csv,clear

		qui do sub_do/cleanvarnames.do
		qui do sub_do/labelvars.do

		sort country region subregion farmcode year
		drop if farmcode >= .
		save `fadnoutdatadir'/data`i', replace
 
	
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




		di "*************************"
		di "* Sub loop 1 - Clean & save FADN2 
		di "*************************"


		foreach filename of local file{

		   * check if start of filename matches ctry_select,
		   *  and if so load, clean, append and save
		   local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 


		   if "`ctry_select'" == substr("`filename'", 1, 3) {

		      insheet using `fadn2dir'/`filename', comma clear

		      di "Renaming merge vars to match eupanel data"
		      qui do sub_do/cleanvarnames.do
		      qui do sub_do/labelvars.do

		      sort country region subregion farmcode year

		      note: Intermediate dataset. Contains additional FADN variables for merge with eupanel data

		      di "Saving `ctry_yr' as `fadn2dir'/`ctry_yr'.dta"
		      save `fadn2dir'/../dta/`ctry_yr'.dta, replace


		   } 	 // closes "if "`ctry_select' == ..."


		}	 // closes foreach filename of local ...
		

		
		di "*************************"
		di "* Sub loop 2 - Append FADN2 years"
		di "*************************"
		
		* drop all obs but keep varnames for appending process
		*  without duplicating obs
		drop if _n > = 1

		
		* this command should show 0 obs but the same number
		*  of vars as before
		describe, short



		foreach filename of local file{

		   * check if start of filename matches ctry_select,
		   *  and if so, load, clean, append and save
		   local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 


		   if "`ctry_select'" == substr("`filename'", 1, 3) {

		      append using `fadn2dir'/../dta/`ctry_yr'.dta 
		      note: Intermediate dataset. Contains additional FADN variables to be merged with eupanel data


		   }	 // closes "if "`ctry_select'" ..."

			
		}	 // closes foreach filename ...


		save `fadn2dir'/../dta/`country'.dta, replace


		* Merge eupanel and FADN2 data
		use `fadnoutdatadir'/data`i'.dta, clear
		sort country region subregion farmcode year
		di "Merging/appending from `country'.dta..."


		merge 1:1 country region subregion farmcode year using `fadn2dir'/../dta/`country'.dta, nonotes nolabel noreport keepusing($newvars) update


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

		*label variable farmcode "ID (unique within country)" 
		*label variable pid "ID (unique for whole panel)"



		*----------------------------------------------------*		

		* the variable for farmer's age is actually the year of
		*  birth. worse, some times this is recorded as a 4 
		*  digit year, and sometimes a two digit year (within 
		*  the same country-year dataset!!!). the following 
		*  code fixes that and drops 0 observations (presumed 
		*  missing or refused, as the number of farmers implied
		*  over 100 is implausible.) The caculation of the 
		*  age variable is left to the do-file renameFADN.do 
		*  as it will take the NFS naming convention there.

		drop if unpaidregholdermgr1yb == 0


		gen yrborn = unpaidregholdermgr1yb
		gen yearcriteria = unpaidregholdermgr1yb - 1900


		replace yrborn = unpaidregholdermgr1yb + 1900 if yearcriteria<0


		*----------------------------------------------------*		


		di "*************************"
		di "* Sub loop 3 - Break UK"
		di "*************************"

		* And if UKregions set accordingly, then break 
		* up UK dataset to temp country datasets
		foreach UKvar of global UKregions{
		

		   if "`UKvar'" == "England" & "`country'" == "UnitedKingdom" {
		      outsheet using tmp_`UKvar'.csv if region ==411 | region == 412 | region ==413, comma replace
		   }	 //close if


		   if "`UKvar'" == "Wales" & "`country'" == "UnitedKingdom" {
		      outsheet using tmp_`UKvar'.csv if region ==421, comma replace
		   }	 //close if


		   if "`UKvar'" == "Scotland" & "`country'" == "UnitedKingdom" {
		      outsheet using tmp_`UKvar'.csv if region ==431, comma replace
		   }	 //close if


		   if "`UKvar'" == "NI" & "`country'" == "UnitedKingdom" {
		      outsheet using tmp_`UKvar'.csv if region ==441, comma replace
		   }	 //close if	



		}	 // close foreach UKvar...


		di "*************************"
		di "* End Sub loop 3"
		di "*************************"








		di "*************************"
		di " * Sub loop 4 - Make UK"
		di "*************************"



		* now load temp country data & finish set up
		foreach UKvar of global UKregions{
		   




                   di "*________________________________________"

		   di "* if valid UK regions then do this code"
                   di "*________________________________________"



		   if ["`UKvar'" == "England" |"`UKvar'" == "Wales" |"`UKvar'" == "Scotland" |"`UKvar'" == "NI"]  & "`country'" == "UnitedKingdom" {

		      clear
		      insheet using tmp_`UKvar'.csv


		      * Make compatible with NFS coding conventions
		      qui do sub_do/renameFADN.do


		      * create as many derived vars as possible, 
		      * setting to 0 if necessary
		      qui do sub_do/doFarmDerivedFADN.do


		      * labels country, year, and regions
		      qui do sub_do/valuelabels.do


		      tsset farmcode year
		      note: Cleaned and merged FADN data panel for `UKvar'	

		      keep if $sectors	
		      save `fadnoutdatadir'/data`i'.dta, replace


		      * list vars in dataset, save for quick reference
		      describe, replace
		      outsheet using `fadnoutdatadir'/data`i'_varlist.csv, comma replace


		      *  increment per UK region if valid
		      local i = `i'+1


		   } 	 // closes if `UKvar' == "England" ...


                   di "*________________________________________"

		   di "* End of if valid UK regions "
                   di "*________________________________________"







                   di "*________________________________________"

		   di "* if UKregion invalid or missing then do this"
                   di "*________________________________________"
	

		   else{		


		      * Make compatible with NFS coding conventions
		      qui do sub_do/renameFADN.do


		      * create as many derived vars as possible, 
		      * setting to 0 if necessary
		      qui do sub_do/doFarmDerivedFADN.do

	
		      * labels country, year, and regions
		      qui do sub_do/valuelabels.do


		      tsset farmcode year
		      note: Cleaned and merged FADN data panel for $ms	

		      keep if $sectors	
		      save `fadnoutdatadir'/data`i'.dta, replace
			
		
	              * list vars in dataset, save for quick reference
	
		      describe, replace
		      outsheet using `fadnoutdatadir'/data`i'_varlist.csv, comma replace

		      } 	 // closes else command



                   di "*________________________________________"

		      di "* End of if UK regions invalid"
                   di "*________________________________________"





		   } 	 // closes foreach UKvar ...




		di "*************************"
		di "* End Sub loop 4"
		di "*************************"








	}		 // closes top level loop


	di "*************************"
	di "* End Top level loop"
	di "*************************"









}			// closes "if databuild == ..."


di "*________________________________________________________"

di "* End top level if statement -- data created"

di "*________________________________________________________"










* loads each dataset and displays obs broken out by region

local dataifiles: dir "`fadnoutdatadir'" files "data*.dta"
foreach file of local dataifiles{
	clear
	use `fadnoutdatadir'/`file'
	di country
	tab year region
}


* another do file should call the created data, so clear memory
clear
