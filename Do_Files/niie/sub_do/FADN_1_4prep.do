*****************************************************
*****************************************************

* Farm Level Microsimulation Model - Data Preparation
*   adapted for FADN data 
* 
* Cathal O'Donoghue, RERC Teagasc
*    adapted by Patrick Gillespie, Walsh Fellow
*
*****************************************************
*****************************************************
args standalone

/* Checks to see if the file is being run as a standalone.
   If $databuild is already set, we assume some other file
   is calling this one, and we don't reset any globals */

if "`standalone'" == "standalone"{

	version 9.0
	clear
	clear matrix
	set mem 700m
	set matsize 2500
	set more off

	* Required directory macro
	global datadir		D:\\Data
 	global project 		testmerge  // folder this file is in
	global dodir1		$datadir/data_FADNPanelAnalysis/Do_Files/$project

	* Run parameters 
	global databuild 	= 1
	global ms 		"Ireland UnitedKingdom" //" "" 
	global countrylabels 	"msname"
	global sectors 		"fffadnsy==4110" 
	global oldvars 		"*"
	global newvars 		"*" 

	local  micro_data_yr	= 2004
	scalar sc_start_yr	= 1999
	scalar sc_micro_data_yr	= `micro_data_yr'
	scalar sim_yr1 		= `micro_data_yr'
	scalar sc_sim_error 	= 0
}

cd  $dodir1

* locals only apply to the file in which they were set, 
*  so either way they need to be set here
local nfspaneldir 	$datadir/data_NFSPanelAnalysis
local fadnpaneldir 	$datadir/data_FADNPanelAnalysis
local fadnoutdatadir 	$datadir/data_FADNPanelAnalysis/OutData/$project
local origdatadir 	$datadir/data_FADNPanelAnalysis/OrigData 
local fadn9907dir  	`origdatadir'/FADN_1
local fadn2dir  	`origdatadir'/FADN_2/TEAGSC
local fadn3dir 		`origdatadir'/FADN_3
local fadn4dir  	`origdatadir'/FADN_4/TEAGSC

* Locals borrowed from NFSPrep.do
local orig_ibsas_nfs 		= "$orig_ibsas_nfs1"
local outdatadir 		= "$outdatadir1" 
local nfsdatadir 		= "$nfsdatadir1" 
local Regional_outdatadir 	= "$Regional_outdatadir1"
local dodir 			= "$dodir1"
local start_yr 			=  sc_start_yr
local micro_data_year_list 	= "$micro_data_year_list1" 

* three scalars that must be preserved for master file

local  save_sc_start_yr 	= sc_start_yr 
local  save_sc_micro_data_yr 	= sc_micro_data_yr 
local  save_sim_yr1		= sim_yr1
local  save_sc_sim_error	= sc_sim_error

* make sure that your fadnoutdatadir exists
capture mkdir 		`fadnoutdatadir'



/*******************************************************
********************************************************
 Building the panels, country by country
*******************************************************/

macro list databuild
if $databuild == 1 {



	* Create a blank dataset to start merging process from
	clear
	gen start=1
	save blank, replace
	
	
	
	/*************************
	 Top level loop
	*************************/
	
	local i = 0
	foreach country of global ms {

		local i = `i'+1
	


	*---------------------------------------------------------
	* FADN 1
	*---------------------------------------------------------

		*standardising eupanel9907 data
		di "Reading csv file for `country' " ///
			"and cleaning varnames..."
		insheet using `fadn9907dir'/csv/`country'.csv,clear
		qui do sub_do/cleanvarnames.do
		qui do sub_do/labelvars.do
		sort country region subregion farmcode year
		drop if farmcode >= .
		save `fadnoutdatadir'/data`i', replace
 
	
	
		clear
	




	*---------------------------------------------------------
	* FADN 2
	*---------------------------------------------------------

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
				note: Intermediate dataset. Contains additional FADN variables for merge with eupanel data
				di "Saving `ctry_yr' as `fadn2dir'/`ctry_yr'.dta"
				save `fadn2dir'/../dta/`ctry_yr'.dta, replace
			}
			
		}
		
		
		*************************
		* Sub loop 2 - Append all FADN2 years together before merging with eupanel
		*************************
		
		* drop all obs but keep varnames to start appending process without duplicating obs
		drop if _n > = 1
		
		* this command should show 0 obs but the same number of vars as before
		describe, short



		foreach filename of local file{

			* check to see if start of filename matches
			* ctry_select, and if so, load, clean, append and save

			local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				append using `fadn2dir'/../dta/`ctry_yr'.dta 
				note: Intermediate dataset. Contains additional FADN variables to be merged with eupanel data
			}
			
		}


		save `fadn2dir'/../dta/`country'.dta, replace



		* Merge eupanel and FADN2 data
		
		use `fadnoutdatadir'/data`i'.dta, clear
		sort country region subregion farmcode year
		di "Merging/appending from `country'.dta..."

		merge 1:1 country region subregion farmcode year using `fadn2dir'/../dta/`country'.dta, nonotes nolabel noreport keepusing($newvars) update

		drop if [_merge == 2 | _merge == 5]
		drop _merge
			
		
		

		save `fadnoutdatadir'/data`i'.dta, replace
	
	
	*---------------------------------------------------------
	* FADN 4 - Data from Fiona (received last)
	*---------------------------------------------------------

		* The naming of FADN_# directories pertain to the order
		*   in which the data were made available to Patrick Gillespie
		*   as he progressed through his PhD. The ordering of the merges 
		*   and appends ARE NOT sequential! It goes 1,2,4,3.
		
		* FADN_4 is to be merged AFTER FADN_2 and BEFORE FADN_3
	
		* gets names of all files in `fadn4dir' 
		local file: dir "`fadn4dir'" files *
	
	

		* ctry_select is the first 3 characters of 
		* the filenames in `fadn4dir' corresponding
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
		* Sub loop 1 - Clean and save FADN4 data before merging
		*************************
		  

		foreach filename of local file{

			* check to see if start of filename matches 
			*   ctry_select, and if so, load, clean, append
			*   and save

			local ctry_yr = substr("`filename'", 1, ///
			 length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				insheet using `fadn4dir'/`filename', comma clear

				di "Renaming merge vars to match eupanel data"
				qui do sub_do/cleanvarnames.do
				qui do sub_do/labelvars.do

				sort country region subregion farmcode year
				note: Intermediate dataset. Contains additional FADN variables for merge with eupanel data
				di "Saving `ctry_yr' as `fadn4dir'/`ctry_yr'.dta"
				save `fadn4dir'/../dta/`ctry_yr'.dta, replace
			}
			
		}
		
		
		*************************
		* Sub loop 2 - Append all FADN4 years together before merging with eupanel
		*************************
		
		* drop all obs but keep varnames to start appending process without duplicating obs
		drop if _n > = 1
		
		* this command should show 0 obs but the same number of vars as before
		describe, short



		foreach filename of local file{

			* check to see if start of filename matches
			* ctry_select, and if so, load, clean, append and save

			local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				append using `fadn4dir'/../dta/`ctry_yr'.dta 
				note: Intermediate dataset. Contains additional FADN variables to be merged with eupanel data
			}
			
		}


		save `fadn4dir'/../dta/`country'.dta, replace



		* Merge eupanel and FADN4 data
		
		use `fadnoutdatadir'/data`i'.dta, clear
		sort country region subregion farmcode year
		di "Merging/appending from `country'.dta..."

		merge 1:1 country region subregion farmcode year using `fadn4dir'/../dta/`country'.dta, nonotes nolabel keepusing($newvars) update


		/* _merge == 2 is fine in this case (we have an extra year of data!)
		
		   Previous FADNprep.do also drop _merge==5, but this isn't necessary. 
		    The 5 code means that at least one overlapping var (var in both datasets
		    that isn't a key var) had non-missing values that don't EXACTLY match. This 
		    code can be triggered by rounding error, or by storing vars to different
		    precisions, e.g. float instead of double. In any case, merge will keep the 
		    original (master) data for those values, and ignore the conflicting values
		    from the new (using) dataset. They ARE NOT duplicates.

		    Once I understood this, there was no longer any compelling reason to drop 
		    these observations.      */


		drop _merge
			
		save `fadnoutdatadir'/data`i'.dta, replace
		
/*		
	*---------------------------------------------------------
	* FADN 3 - appending recent years
	*---------------------------------------------------------

		* gets names of all files in `fadn2dir' 
		local file: dir "`fadn3dir'/TEAGASC2" files *
	
	

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
		* Sub loop 3 - Clean and save FADN3 data before merging
		*************************
		  

		foreach filename of local file{

			* check to see if start of filename matches
			* ctry_select, and if so, load, clean, append
			*   and save


			if "`ctry_select'" == substr("`filename'", 1, 3) {
				insheet using `fadn3dir'/TEAGASC2/`filename', comma clear

				di "Renaming merge vars to match eupanel data"
				qui do sub_do/cleanvarnames.do
				qui do sub_do/labelvars.do
				
				sort country region subregion farmcode year
				note: Intermediate dataset. Contains additional data from 3rd FADN request.

				local ctry_yr = substr("`filename'", 1, ///
			 	   length("`filename'") -4) 

				di "Saving `ctry_yr' as `fadn3dir'/TEAGASC/`ctry_yr'.dta"
				save `fadnoutdatadir'/`ctry_yr'.dta, replace
			}
		}
		

		*************************
		* Sub loop 4 - Append all FADN3 years to data`i'.dta
		*************************
		
		use `fadnoutdatadir'/data`i'.dta, clear

		foreach filename of local file{

			* check to see if start of filename matches
			* ctry_select, and if so, load, clean, append and save

			local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 

			if "`ctry_select'" == substr("`filename'", 1, 3) {
				append using `fadnoutdatadir'/`ctry_yr'.dta
				note: Intermediate dataset. Contains additional data from 3rd FADN request.
				erase `fadnoutdatadir'/`ctry_yr'.dta
			}
			
		}

		
		save `fadnoutdatadir'/data`i'.dta, replace

	

*/




	*---------------------------------------------------------
	* FADN 3 - merging in new vars
	*---------------------------------------------------------



		* gets names of all files in `fadn2dir' 
		local file: dir "`fadn3dir'/TEAGASC" files *
	
	

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
		* Sub loop 5 - Clean and save FADN3 data before merging
		*************************
		  

		foreach filename of local file{

			* check to see if start of filename matches
			*  ctry_select, and if so, load, clean, append
			*  and save


			if "`ctry_select'" == substr("`filename'", 1, 3) {
				insheet using `fadn3dir'/TEAGASC/`filename', comma clear

				di "Renaming merge vars to match eupanel data"
				qui do sub_do/cleanvarnames.do
				qui do sub_do/labelvars.do

				sort country region subregion farmcode year
				note: Intermediate dataset. Contains additional FADN variables for merge with eupanel data

				local ctry_yr = substr("`filename'", 1, ///
				  length("`filename'") -4) 

				di "Saving `ctry_yr' as `fadnoutdatadir'/`ctry_yr'.dta"
				save `fadnoutdatadir'/`ctry_yr'.dta, replace
			}
			
		}
		
		
		*************************
		* Sub loop 6 - Append all FADN3 (new vars) years together before merging with data`i'.dta
		*************************
		
		* drop all obs but keep varnames to start appending process without duplicating obs
		drop if _n > = 1
		
		* this command should show 0 obs but the same number of vars as before
		describe, short



		foreach filename of local file{

			* check to see if start of filename matches
			* ctry_select, and if so, load, clean, append and save


			if "`ctry_select'" == substr("`filename'", 1, 3) {

				local ctry_yr = substr("`filename'", 1, length("`filename'") -4) 
				append using `fadnoutdatadir'/`ctry_yr'.dta 
				note: Intermediate dataset. Contains additional variables from 3rd FADN request
				erase `fadnoutdatadir'/`ctry_yr'.dta 
			}
			
		}


		describe, short //check obs before merging
		

		
		/* The FADN_3 new var data is mising farmcode. Therefore, we use the data we 
		    have to recalculate some Standard Results which are also in the other 
		    datasets. This will uniquely id all but 61 obs, all of which we must drop
		    as we can't map to specific farms. We'll then be able to merge using these
		    variables as the key variables.	*/	

		gen dairycows          = dairycowsAV
		gen double energy      = motorfuelandlubricants + electricity + heatingfuels
		gen beefandveal        =                                    ///
					cattleFC              + cattleSA - cattlePU   + ///
					CalvesforFattDR       + OtherCattleLT1yrDR    + ///
					malecattle1LT2yrsDR   + femalecattle1LT2yrsDR + ///
					malecattleGTE2yrsDR   + breedingheifersDR     + ///
					heifersforfatteningDR + dairycowsDR           + ///
					culldairycowsDR       + othercowsDR
		
		gen purchfeed          = confeedforgrazlivpurch + coarsefoddergrazlivpurch
		gen othercattlelus     = ((CalvesforFattAV + OtherCattleLT1yrAV) *0.04) + ((malecattle1LT2yrsAV +  femalecattle1LT2yrsAV) * 0.07) + (( breedingheifersAV +  heifersforfatteningAV) * 0.08 )+ ((malecattleGTE2yrsAV+ culldairycowsAV) * 0.1) + ( othercowsAV * 0.08)
		replace othercattlelus = othercattlelus*10

		replace dairycows		= round(dairycows)
		replace beefandveal		= round(beefandveal)
		replace othercattlelus  = round(othercattlelus)
		replace purchfeed		= round(purchfeed, 0.01)
		replace energy			= round(energy, 0.01)
		
		duplicates tag  year country region subregion dairycows beefandveal othercattlelus purchfeed energy , gen(dup)
		drop if dup > 0 
		drop dup	

		sort country region subregion year dairycows othercattlelus energy 
		save `fadnoutdatadir'/`country'.dta, replace



		* Merge new vars from FADN3 data with data`i'
		use `fadnoutdatadir'/data`i'.dta, clear

		gen double purchfeed = feedforgrazinglivestock - feedforgrazinglivestockhomegrown 
		
		replace dairycows		= round(dairycows)
		replace beefandveal		= round(beefandveal)
		replace othercattlelus  = round(othercattlelus)
		replace purchfeed		= round(purchfeed, 0.01)
		replace energy			= round(energy, 0.01)
		
		
		* Must id duplicates for the same list of key vars and drop them here too.
		duplicates tag  year country region subregion dairycows beefandveal othercattlelus purchfeed energy, gen(dup) 
		drop if dup > 0 
		drop dup
		
		sort year country region subregion dairycows beefandveal othercattlelus purchfeed energy 
		di "Merging/appending new FADN3 vars from `country'.dta..."

		merge 1:1 year country region subregion dairycows beefandveal othercattlelus purchfeed energy using `fadnoutdatadir'/`country'.dta, nonotes gen(_3merge) 
			
			
		describe, short //check obs after merging
		
		save `fadnoutdatadir'/data`i'.dta, replace
		erase `fadnoutdatadir'/`country'.dta





	
		* ... more cleaning
		*drop if farmcode >= . & year < 2008
		*replace farmcode = _n if year >= 2008


		* the following variable has 0 obs. 
		drop v201
		
		* check number of obs and vars
		describe, short
		
		/*------------------------------------------------------
		Farmcode is not unique across countries so create a 
		unique panel id (only relevant for multi-country panels,
 		commented out but kept for reference). 
		egen pid = group(country region subregion farmcode)
		destring pid, replace
		tsset pid year
		label variable farmcode "ID (only unique within country)" 
		label variable pid "ID (unique for whole panel)"
		------------------------------------------------------*/

		
		/*-----------------------------------------------------
		The variable for farmer's age is actually the year of 
		birth. Worse, some times this is recorded as a 4 digit 
		year, and sometimes a two digit year (within the same 
		country-year dataset!!!). The following code fixes that
		and drops 0 observations (presumed missing or refused, 
		as the number of farmers implied to be over 100 is 
		implausible). The caculation of the age variable is left
 		to the do-file renameFADN.do as it will take the NFS 
		naming convention there.  
		------------------------------------------------------*/
		drop if unpaidregholdermgr1yb == 0
		gen yrborn = unpaidregholdermgr1yb
		gen yearcriteria = unpaidregholdermgr1yb - 1900
		replace yrborn=unpaidregholdermgr1yb + 1900 if yearcriteria<0


		* select Northern Ireland if working with UK data
		if "`country'" == "UnitedKingdom" {
			keep if region == 441
		}

		* check number of obs and vars
		describe, short

		* Make compatible with NFS coding conventions
		qui do sub_do/renameFADN.do
		
		
		* check number of obs and vars describe, short 
		qui do sub_do/doFarmDerivedFADN.do
		
		
		* check number of obs and vars
		describe, short


		tsset farmcode year
		note: Cleaned and merged FADN data panel for $ms		
		keep if $sectors	




		*****************************************************
		*--------------------------------------------------
		*--------------------------------------------------
		* Code borrowed from NFSPrep.do
		*--------------------------------------------------
		*--------------------------------------------------
		*****************************************************
		

		* P.Gillespie: Skipped start of file, as it's not 
		* 		relevant for FADN data.


		*****************************************************
		* Prepare
		*****************************************************
		sort farmcode year
		by farmcode: replace hasforestry = hasforestry[_n-1] if hasforestry == 0 & hasforestry[_n-1] != 0 & hasforestry[_n-1] != .
		
		*****************************************************
		* Price
		*****************************************************
		
		local fgo_vlist = "$fgo_vlist"
		
		gen Pfdairygo_lu = PMilk
		gen Pfcatlego_lu = PTotalCattle
		gen Pfsheepgo_lu = PSheep
		gen Pcropgo_ha = PTotalCrop
		gen Pfarmdc_ha = PTotalInputs
		gen Poth_dc_ha =  POtherInputs
		gen Pfdpurblk_ha = PCattleFeed
		gen Pfdpurcon_ha = PStraightFeed
		gen Pfdferfil_ha = PTotalFert
		gen Pfdpursed_ha = PSeeds
		gen Pfdcrppro_ha = PPlantProtection
		gen Pfdvetmed_ha = PVetExp
		gen Pfdaifees_ha = PVetExp
		gen Pfdtrans_ha = PMotorFuels
		gen Poth_oc_ha =  POtherInputs
		gen Pfocarelp_ha =  PElectricity
		
		sort farmcode year
		local P_vlist = "$P_vlist"
		foreach var_P in `P_vlist' {
			capture drop `var_P'_1
			capture drop ln`var_P'
			by farmcode: gen `var_P'_1 = `var_P'[_n-1]
			gen l`var_P' = ln(`var_P')
		}
		
		local dccost_vlist = "$dccost_vlist" 
		local occost_vlist = "$occost_vlist "
		
		
		local price_adj_vlist = "$price_adj_vlist"
		
		foreach var in `price_adj_vlist' {
			gen tP`var'2004 = P`var' if fyear == 2004
			qui replace tP`var'2004 = 0 if tP`var'2004 == .
			egen P`var'2004 = max(tP`var'2004)
			qui replace P`var' = P`var'/P`var'2004
			qui replace P`var'_1 = P`var'_1/P`var'2004
			sort year
			by year: egen tP`var'_1 = mean(P`var'_1)
			replace tP`var'_1 = 0 if tP`var'_1 == .
			by year: egen mtP`var'_1 = max(tP`var'_1)
			qui replace P`var'_1 = mtP`var'_1 if P`var'_1 == .
		
			capture drop l`var'
			gen l`var' = ln(P`var'*100)
		}	
		
		save	`outdatadir'\tmpFADN1, replace
		
		
		local price_adj_vlist1 = "`fgo_vlist' "
		local price_adj_vlist2 = "`dccost_vlist' `occost_vlist' "
		
		foreach var in `farm_cont_panel_vlist' {
			gen `var'_orig = `var'
		}
		
		foreach var in `farmlogit_vlist' {
			gen `var'_orig = `var'
		}
		
		
		*Convert dependent to Volume
		foreach var in `price_adj_vlist1' {
			qui replace `var' = `var'/P`var'
		}
		foreach var in `price_adj_vlist2' {
			qui replace `var' = `var'/P`var'
		}
		
		* Create Cost Totals - after price adjustment
		qui gen dc_tot = 0
		foreach var in `dccost_vlist' {
			qui replace dc_tot = dc_tot + `var'
		}
		
		qui gen oc_tot = 0
		foreach var in `occost_vlist' {
			qui replace oc_tot = oc_tot + `var'
		}
		
		
		* Create Cost Totals - after price adjustment
		foreach var in `dccost_vlist' {
			qui gen `var'_sh = `var'/dc_tot if dc_tot > 0
		}
		
		foreach var in `occost_vlist' {
			qui gen `var'_sh = `var'/oc_tot if oc_tot > 0
		}
		
		capture gen farm = 1
		
		
		*Dairy
		gen fdairygo_lu_cond   =  daforare > 0 & daforare != . & year <= 2009
		gen fdairylu_ha_cond   =  daforare > 0 & daforare != . & year <= 2009
		gen dotomkgl_cond      =  daforare > 0 & daforare != . & year <= 2009
		
		*Cattle
		gen fcatlego_lu_cond   =  cpforacs > 0 & cpforacs != . & year <= 2010
		gen fcatlelu_ha_cond   =  cpforacs > 0 & cpforacs != . & year <= 2010
		
		*Sheep
		gen fsheepgo_lu_cond   =  spforacs > 0 & spforacs != . & fsheeplu_ha != . & year <= 2009
		gen fsheeplu_ha_cond   =  spforacs > 0 & spforacs != . & fsheeplu_ha != . & year <= 2009
		
		*Crops
		gen cropgo_ha_cond   =  tillage_area > 0 & tillage_area != . & year <= 2009
		
		*Costs 
		gen farmdc_ha_cond =  farm == 1 & farmdc_ha > 0 & farmdc_ha !=. & year <= 2010
		gen oth_dc_ha_cond =  farm == 1 & oth_dc_ha > 0 & oth_dc_ha != . & year <= 2010
		gen fdpurblk_ha_cond =  farm == 1 & fdpurblk_ha > 0 & fdpurblk_ha !=. & year <= 2009
		gen fdpurcon_ha_cond =  farm == 1 & fdpurcon_ha > 0 & fdpurcon_ha !=. & year <= 2009
		gen fdferfil_ha_cond =  farm == 1 & fdferfil_ha > 0 & fdferfil_ha !=. & year <= 2009
		gen fdpursed_ha_cond =  farm == 1 & fdpursed_ha > 0 & fdpursed_ha !=. & year <= 2009
		gen fdcrppro_ha_cond =  farm == 1 & fdcrppro_ha > 0 & fdcrppro_ha !=. & year <= 2010
		gen fdvetmed_ha_cond =  farm == 1 & fdvetmed_ha > 0 & fdvetmed_ha !=. & year <= 2009
		gen fdaifees_ha_cond =  farm == 1 & fdaifees_ha > 0 & fdaifees_ha !=. & year <= 2010
		gen oth_oc_ha_cond =  farm == 1 & oth_oc > 0 & oth_oc != . & year <= 2009
		gen focarelp_ha_cond =  farm == 1 & focarelp_ha > 0 & focarelp_ha !=. & year <= 2009
		
		*logit
		gen hasreps_cond = farm == 1 & year <= 2009
		gen fsubreps_cond = hasreps == 1 & year <= 2009
		gen isofffarmy_cond = farm == 1 & year <= 2009
		gen hassws_cond = farm == 1 & cpnolu > 0 & year <= 2009
		
		* REMOVED: code to replace ooinchld in 2005 for 2006 as
		*    2005 missing

		* REASON: ooinchild not in data
		
		***************************************************
		* SFP GRowth Rate
		***************************************************
		mvencode _all, mv(0) override
		
		sort year
		by year: egen ave_dirpayts = mean(dirpayts)
		foreach year in `micro_data_year_list' {
		
			egen ttmp = max(ave_dirpayts) if year == `year'
			qui replace ttmp = 0 if ttmp == .
			egen tmp = max(ttmp)
			scalar sc_av_dirpayts`year' = tmp[1]
			drop tmp
		}
		
				
		***************************************************
		*--------------------------------------------------
		*--------------------------------------------------
		* End of code borrowed from NFSPrep.
		*--------------------------------------------------
		*--------------------------------------------------
		***************************************************



		
		
		* generate azone
		tab(altitudezone), gen(azone)
	

		* value 4 = "not available" so drop those obs
		drop if altitudezone >= 4
	

		* drop azone1 as it's the base case
		drop azone1

	
		gen intwt = int(farmsrepresented)
		
		* get temperature, precipitation, and solar radiation data
		qui do sub_do/getweather.do


		* long varnames sometimes cause problems
		rename	mean_ann_min_temp 	min_temp
		rename	feedforgrazinglivestock	fdgrzlvstk 
		gen	fdgrzlvstk_lu	= fdgrzlvstk/dpnolu


		save `fadnoutdatadir'/data`i'.dta, replace
			
		
		* next 3 lines gives listing of vars in the dataset for
		*   quick reference
	
		describe, replace
		outsheet using `fadnoutdatadir'/data`i'_varlist.csv, comma replace
	}
}


********************************************************
********************************************************
clear

if "`standalone'" != "standalone"{

	* Save those scalars that you were losing
	scalar  sc_sim_error		= `save_sc_sim_error'
	scalar  sc_start_yr 		= `save_sc_start_yr'
	scalar 	sc_micro_data_yr 	= `save_sc_micro_data_yr'
	scalar 	sim_yr1 		= `save_sim_yr1'

	/* This file would have wiped out scalars created here as well
		so run them again 	*/
	do `dodir'/farmprices.do
	do `dodir'/FarmScalarPrices

	use `fadnoutdatadir'/data`i'.dta, replace
	codebook year
}
