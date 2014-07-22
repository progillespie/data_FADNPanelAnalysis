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
* First edited 27th June, 2013

* Tasks
*    - remove teagasc from varlist (the FADN variable 
*       doesn't really map well...)                       
*                                                [done]   
*
*    - replace corr of data1.dta  with one for  to 
*       reply to redundancy critique
*                                                [done]   
*
*    - provide stats on the correlation of Environmental
*       subsidies with farm size 
*                                                [done]   
*
*    - moved dataname definition to the top of the file
*                                                [done]   
*
*    - use $dataname in log commands
*                                                [done]   
*
*    - move dependent var out of the varlist, 
*       name indep_vlist
*                                                [done]   
*
*    - create dependent var macro, name dep_vlist 
*                                                [done]   
*
*    - create country and region var macro, 
*       name location_vlist
*                                                [done]   
*
*    - adjust model commands to reflect new macros 
*       using `indep_vlist' in eff. effects 
*                                                [done]   
*
*    - restructure so most important setting are at top
*                                                [done]   
*
*    - restructure code to run from FADNprep.do
*                                                [done]   
*    - eliminate need for model_setup
*------------------------------------------------------


********************************************************
********************************************************
* Key Parameters
********************************************************
********************************************************


*------------------------------------------------------------
* Give the varnames of the dependent and the explanatory vars
*------------------------------------------------------------
local dep_vlist "lndotomkgl " 

local indep_vlist "lnfsizuaa lndaforare lnflabpaid lnflabunpd lndpnolu azone2 azone3 hasreps ogagehld" // <- need a grass variable

local location_vlist "France Ireland UK Bretagne NormandieHaute NormandieBasse Wales Bayern" // <- may have to rethink region dummies




*------------------------------------------------------------
* SFA model commands (will be run in the code below)
*------------------------------------------------------------
local model1command "sfpanel `dep_vlist' `indep_vlist' , model(bc95) emean(`indep_vlist') usigma(`indep_vlist')"
*`location_vlist'

* for naming stored estimates
local model1name "bc95"

* options for the predict command. At minimum give the type of 
*  TE calulation formula - jlms is standard (see help sfpanel)
local predict_opts "jlms"


*------------------------------------------------------------
* Panel Specification
*------------------------------------------------------------
* Run from raw FADN data? (1 = yes)
global databuild = 0


* panel selection
global ms "France Germany Ireland UnitedKingdom" 
global countrylabels "msname"
global sectors "fffadnsy==4110" 
global oldvars "*"
global newvars "*"


* name the panel (use the name of this file)
global dataname "msward_2013_06_27"


global datadir G:\Data  // path to data directory
global project multisward // name of the folder this file is in

********************************************************
********************************************************





*--------------------------------------------
* Data prep and other setup
*--------------------------------------------
* Prepares the FADN data. Tests if data build = 1 first
* If directories are missing, will also make them.
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
	drop if _n >= 1
	local filelist: dir "`fadnoutdatadir'" files "data?.dta"
	foreach file of local filelist{
	
		append using `fadnoutdatadir'/`file'	
		di "`file'"
	}
	
	* farmcode is not unique across countries
	* so create a unique panel id
	egen pid = group(country region subregion farmcode)

	destring pid, replace

	tsset pid year

	label variable farmcode "ID (only unique within country)" 
	label variable pid "ID (unique for whole panel)"


	* final setup for running model
	do sub_do/model_setup.do

	note: Finished data for multisward paper. - PRG
	save `fadnoutdatadir'/$dataname, replace
}

else{
	use `fadnoutdatadir'/$dataname, clear
}

*--------------------------------------------
*--------------------------------------------






********************************************************
********************************************************
* MODELLING               
********************************************************
********************************************************


* turn on logs 
log using logs/$dataname.txt, replace
di  "Job  Started  at  $S_TIME  on $S_DATE"
cmdlog using logs/$dataname_cmd.txt, replace


* report the model parameters you selected in the log
macro list



* model you selected above is run here
di "`model1command'"
`model1command' // <- needs a grass variable
estimates store `model1name'
predict te_`model1name', `predict_opts'



save `fadnoutdatadir'/SFA_post, replace

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

/*
* These do files generate output datasets and graphs. 

*qui do sub_do/graphs.do 
*qui do sub_do/spreadsheets.do // summary stats 
*/
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
macro drop _all


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
