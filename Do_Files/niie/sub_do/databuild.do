********************************************************
*       Patrick R. Gillespie                            
*       Walsh Fellow                    
*	FADN_IGM/sub_do/databuild.do
********************************************************
* Constructs a panel from eupanel9907 and FADN_2 files
********************************************************
* Define directories (should be identical to the master file)
*local datadir /media/MyPassport/Data
local datadir $datadir
local fadnpaneldir `datadir'/data_FADNPanelAnalysis
local nfspaneldir `datadir'/data_NFSPanelAnalysis

******************************************
* Original Data
******************************************
* filepaths of subdirectories of fadnpaneldir
*   origdatadir is deliberately NOT called
*   fadnorigdatadir (ensures that NFS data
*   isn't called anywhere in the files)
local origdatadir `fadnpaneldir'/OrigData 
local fadn9907dir  `origdatadir'/eupanel9907
local fadn2dir  `origdatadir'/FADN_2/TEAGSC

* filepaths of subdirectories of nfspaneldir
local SMILEFarmdatadir `nfspaneldir'\OutData\SpatialMatch
local orig_ibsas_nfs = "`nfspaneldir'\OutData\ConvertIBSAS"
global orig_ibsas_nfs1 = "`orig_ibsas_nfs'"
local nfsdatadir `nfspaneldir'\OutData
global nfsdatadir1 = "`nfsdatadir'"

* filepaths other subdirectories of datadir
local pov_orig_data `datadir'/Data_Pov87/OutData
local censusofagdatadir `datadir'/data_WFD/Orig_data
local filldatadir `datadir'/Data_lii/Out_Data/PanelCreate/lii
local silcdatadir `datadir'/data_AIMAP/Out_Data/EUSILCBenefits
local histdata `datadir'/Data_lii/Out_Data/SMILECreate/lii
local ttw `datadir'/data_AIMAP/Orig_Data/TTW
local exp_origdatadir `datadir'/data_AIMAP/Orig_Data/ExpAnalysis
local silc_orig_data `datadir'/data_AIMAP/Out_Data/EUSILCBenefits
local hbsnfsdatadir `datadir'/data_NFSPanelAnalysis/OutData/HBSNFSMatch



******************************************
* Do-file directories
******************************************
local dodir `fadnpaneldir'/Do_Files/FADN_IGM
global dodir1 = "`dodir'"

local exp_dodir `datadir'/data_AIMAP/Do_Files/ExpAnalysis
local smiledodir `datadir'/Data_SmileCreate/Do_files/DoSmileCreate



******************************************
* Output Data
******************************************
local fadnoutdatadir `fadnpaneldir'/OutData/FADN_IGM

local outdatadir `nfspaneldir'/OutData/IGM
global outdatadir1 = "`outdatadir'"

local Regional_outdatadir /Data/data_NFSPanelAnalysis/OutData/RegionalAnalysis
global Regional_outdatadir1 = "`Regional_outdatadir'"



********************************************************
* Load a blank data set to start from, then append
*   each dta in OrigData/eupanel9907/dta to the dataset
*   in memory and save. Vars and sectors defined in 
*   master.do are kept, everything else is dropped.
********************************************************
foreach country of global ms {
	di "Reading csv file for `country' and cleaning varnames..."
	insheet using `fadn9907dir'/csv/`country'.csv,clear
	do sub_do/cleanvarnames.do
	do sub_do/labelvars.do
	save `fadn9907dir'/dta/`country', replace
}
	
use blank, clear

foreach country of global ms {
	di "Appending observations from `country'..."
	append using `fadn9907dir'/dta/`country'
	keep $oldvars
	keep if [$sectors]
}

sort country region subregion farmcode year
drop if farmcode >= .
drop start
save `fadnoutdatadir'/$dataname.dta, replace



********************************************************
* Load and then save each FADN_2 csv file in Stata 
* dta format(necessary for merging and appending)
********************************************************
* Create a local which gets the names of 
* all files in the relevant directory
local file: dir "`fadn2dir'" files *
clear

* Loop over all those files, loading and saving
*   as a dta after renaming a few variables 
foreach ctry_yr of local file{
	local ctry = substr("`ctry_yr'", 1, length("`ctry_yr'") -4) 
	insheet using `fadn2dir'/`ctry_yr', comma 
	di "Renaming merge vars to match Full Sample.dta"
	do sub_do/cleanvarnames.do
	do sub_do/labelvars.do
	sort country region subregion farmcode year
	note: Intermediate dataset. Contains additional FADN variables to be merged with Full Sample.dta
	di "Saving `ctry_yr' as `fadn2dir'/`ctry'.dta"
	save `fadn2dir'/../dta/`ctry'.dta, replace
	clear
}



***************************************************
* Load data9907 as the starting dataset then
*   append each country~year dataset to the dataset 
*   in memory, keeping only the vars in `newvars'
*   which is defined in master.do
***************************************************
use `fadnoutdatadir'/$dataname.dta
sort country region subregion farmcode year

foreach ctry_yr of local file{
	local ctry = substr("`ctry_yr'", 1, length("`ctry_yr'") -4)  
	di "Merging/appending from `ctry'.dta..."
	merge 1:1 country region subregion farmcode year using `fadn2dir'/../dta/`ctry'.dta, nonotes nolabel noreport keepusing($newvars) update
	drop if [_merge == 2 | _merge == 5]
	drop _merge
}

* the following variable has 0 obs. 
drop v201
drop if farmcode >= .

* farmcode is not unique across countries
* so create a unique panel id
egen pid = group(country region subregion farmcode)
destring pid, replace
tsset pid year
label variable farmcode "ID (only unique within country)" 
label variable pid "ID (unique for whole panel)"

* the variable for farmer's age is actually the year of birth. worse, some
* times this is recorded as a 4 digit year, and sometimes a two digit year
* (within the same country-year dataset!!!). the following code fixes that
* and drops 0 observations (presumed missing or refused, as the number of * farmers implied to be over 100 is implausible.) The caculation of the 
* age variable is left to the do-file renameFADN.do as it will take the 
* NFS naming convention there.
drop if unpaidregholdermgr1yb == 0
gen yrborn = unpaidregholdermgr1yb
gen yearcriteria = unpaidregholdermgr1yb - 1900
replace yrborn = unpaidregholdermgr1yb + 1900 if yearcriteria<0


save `fadnoutdatadir'/$dataname.dta, replace
describe, replace
save `fadnoutdatadir'/fadn_igm_varlist.dta, replace
outsheet using `fadnoutdatadir'/fadn_igm_varlist.csv, comma replace
