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

version 9.0
clear
clear matrix
set mem 700m
set matsize 2500
set more off
capture log close
capture cmdlog close

* global datadir to be passed to sub_do files
global datadir G:\Data
*global datadir /media/MyPassport/Data

* these local definitions to be copied to sub_do files
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



cd `dodir'
capture mkdir logs
log using logs/fadn_igm.smcl, replace
di  "Job  Started  at  $S_TIME  on $S_DATE"
cmdlog using logs/fadn_igm.txt, replace



******************************************
* ensure that required directories exist
******************************************
capture mkdir `fadnoutdatadir'
capture mkdir `origdatadir'
capture mkdir `fadn9907dir'
capture mkdir `fadn2dir'
capture mkdir output
capture mkdir output/docs
capture mkdir output/graphs
capture mkdir output/graphs
capture mkdir output/graphs/feed
capture mkdir logs/results



********************************************************
* DEFINING THE PANEL via global macros   
********************************************************
* Countries available are --> "Austria Belgium Bulgaria 
*   Cyprus CzechRepublic Denmark Estonia Finland France 
*   Germany Greece Hungary Ireland Italy Latvia Lithuania 
*   Luxembourg Malta Netherlands Poland Portugal Romania 
*   Slovakia Slovenia Spain Sweden UnitedKingdom" 
global ms "France Germany Ireland UnitedKingdom" 

* Choose 2 or 3 character labels, or full labels for the
*   newly created countrycode variable (ms2, ms3, or msname)
global countrylabels "msname"

* Select farm types. You could also specify 
*   principal farmtypes, A30 codes (see #model_rica spreadsheets
*   in SupportDocs) or "*" for all obs. A30 will be
*   renamed system in sub_do/cleanvarnames.do. 
global sectors "system==4110" 

* Vars from Standard Results  (eupanel9907) that you'd like 
*   to include give a varlist, or "*" if you want all vars
global oldvars "*"

* Vars from the more specific 2nd FADN request (FADN_2)
*   give a varlist, or "*" if you want all vars
global newvars "*" 

* Name the new panel of data you're creating
global dataname "fadn_igm"
********************************************************



********************************************************
* BUILDING THE PANEL   
********************************************************
* The gen and save commands generate a blank dataset
*   to start from. This is necessary for some of the
*   loops (avoids double counting the first
*   dataset).

* databuild.do creates dataset based on macro values
*   above from data in eupanel9907 and FADN_2/TEAGSC
*   and creates a list of the variables in the resulting
*   dataset (drops data from memory, meaning it has to 
*   be loaded again below). You can switch these lines off
*   for intermediate data runs. 
*gen start=1
*save blank, replace
*do sub_do/databuild.do

* ALWAYS LEAVE THESE LINES TURNED ON, EVEN IF RUNNING 
*   databuild.do again.
use `fadnoutdatadir'/$dataname.dta, clear
qui do sub_do/valuelabels.do
* rename a few FADN variable with the varname corresponding
*   to the closest match in the NFS so other do files
*   which were originally written for the NFS will run
qui do sub_do/renameFADN.do
********************************************************



********************************************************
* GENERATING DESCRIPTIVES 
********************************************************
* These do files generate output datasets and graphs. 
*
* Do files creating csv's for tables. 
*   Saves in output/spreadsheets. 
*qui do sub_do/
*
* Do files which create graphs
*qui do sub_do/
********************************************************

/*! Where to define these (here or a sub_do)?
local mallow_logit_vlist    = "return_work"
local farm_vars_vlist       = "fdairygo fcatlego fsheepgo fcerealgo potcugov oth_dc fdpurblk fdpurcon fdferfil fdpursed fdcrppro fdvetmed fdaifees oth_oc focarelp dirpayts_sfp sfp inputs fpigsgo fpoultgo dirpayts_sfp2 fsubreps"
global farm_vars_vlist1 = "`farm_vars_vlist'"

local milk_regr_vlist		= "dc_lt lt_lu lu_ha"

local farmlogit_vlist		= "hasreps hassws isofffarmy"
global farmlogit_vlist1 	= "`farmlogit_vlist'"

local farm_cont_panel_vlist = "fdairygo_lu fdairylu_ha fcatlego_lu fcatlelu_ha fsheepgo_lu fsheeplu_ha cropgo_ha farmdc_ha fdpurblk_ha oth_dc_ha fdpurcon_ha fdferfil_ha fdpursed_ha fdcrppro_ha fdvetmed_ha fdaifees_ha oth_oc_ha focarelp_ha "
global farm_cont_panel_vlist1 = "`farm_cont_panel_vlist'"

scalar sc_sim_error = 0
local update_vlist = "fdairygo_lu fcatlego_lu fsheepgo_lu cropgo_ha oth_dc_ha fdpurblk_ha fdpurcon_ha fdferfil_ha fdpursed_ha fdcrppro_ha fdvetmed_ha fdaifees_ha oth_oc_ha focarelp_ha"
global update_vlist1 = "`update_vlist'"
local cost_vlist = "oth_dc fdpurblk fdpurcon fdferfil fdpursed fdcrppro fdvetmed fdaifees oth_oc focarelp"
global cost_vlist1 = "`cost_vlist'"

global panel_vlist_1 = "`farm_cont_panel_vlist'"
*/
********************************************************
* MODELLING               
********************************************************
* Run SFA models on FADN panel
********************************************************
qui do sub_do/model_setup.do
qui do sub_do/climatezones.do
*save `fadnoutdatadir'/jc_data, replace
*use `fadnoutdatadir'/jc_data, clear
qui do sub_do/FarmRegrExpVars.do
* define constraint to force half normal dist of u_i (default is truncated normal)
* to use it specify const(1) as an option of xtfrontier
constraint define 1 [mu]_cons = 0
gen te_ti	= .
label variable te_ti "Efficiency (time-invariant model)"
gen te_tvd	= .
label variable te_tvd "Efficiency (time-varying decay model)"
gen te_tfe	= .
label variable te_ti "Efficiency (True Fixed Effects model)"
gen te_tre	= .
label variable te_ti "Efficiency (True Random Effects model)"

saveold `fadnoutdatadir'/SFA_pre, replace

/*
* Estimate Models within each country
* -----------------------------------
* pull in global variable list definied in FarmRegrExpVars.do
local fdairygo_lu_vlist1 $fdairygo_lu_vlist1
* or redefine it here...
*local fdairygo_lu_vlist1 "lnfdairygo_lu lnlandval_ha lnfdferfil_ha lndaforare lndpnolu_ha lnflabtotl ogagehld lnfsizuaa lnfdratio azone2 azone3 hasreps teagasc"
levelsof country, local(countryvalues)
foreach value of local countryvalues {
	di "... `value'"
	xtserial `fdairygo_lu_vlist1' if country == "`value'"
	
	* Time invariant model
	xtfrontier `fdairygo_lu_vlist1' if country == "`value'", ti
	estimates store `value'_model_ti
	predict `value'_te_ti if country=="`value'", te
	
	* Time-varying decay model
	*xtfrontier `fdairygo_lu_vlist1' if country == "`value'", tvd 
	*estimates store `value'_model_tvd
	*predict `value'_te_tvd if country=="`value'", te
	
	* Greene's True Fixed Effects
	*sfpanel `fdairygo_lu_vlist1' if country == "`value'",model(tfe) distribution(hnormal) 
	*estimates store `value'_model_tfe
	*predict `value'_te_tfe if country=="`value'", u
	
	* Greene's True Random Effects
	*sfpanel `fdairygo_lu_vlist1' if country == "`value'",model(tre) distribution(hnormal) sim(10) 
	*estimates store model_tre
	*predict `value'_te_tre if country=="`value'", u
	
	replace	te_ti	= `value'_te_ti if country=="`value'"
	*replace	te_tvd	= `value'_te_tvd if country=="`value'" 
	*replace	te_tfe	= `value'_te_tfe if country=="`value'" 
	*replace	te_tre	= `value'_te_tre if country=="`value'" 
}	


* Estimate model with countries pooled (i.e. measured relative to meta frontier)
* -----------------------------------
* Time invariant model using a meta-frontier
xtfrontier $fdairygo_lu_vlist1 COUNTRY2 - COUNTRY4, ti
estimates store meta_model_ti
predict meta_te_ti, te

* Time varying decay model using a meta-frontier
*xtfrontier `fdairygo_lu_vlist1' COUNTRY2 - COUNTRY4, tvd
*estimates store meta_model_tvd
*predict meta_te_tvd, te

* Greene's True Fixed Effects
*sfpanel `fdairygo_lu_vlist1' COUNTRY2 - COUNTRY4, model(tfe) distribution(hnormal)
*estimates store meta_model_tfe
*predict meta_te_tfe 

*tabstat meta_te_ti meta_te_tvd meta_te_tfe, by(country) stats(mean, sd)
*saveold `fadnoutdatadir'/SFA_post, replace
*/
/*
*********************************************
******** panel frontier functions ***********
*********************************************
keep if country=="IRE"
*********** pooled model - no specification on Uit ****************
frontier lnY lnH lnC lnL lnD lnA lnHH lnHC lnHL lnHD lnHA lnCC lnCL lnCD lnCA lnLL lnLD lnLA lnDD lnDA lnAA T2 T3 T4 T5 T6 T7 T8 T9 
predict uPOOL, u

******* Pit and Lee, 1981 ********
xtfrontier lnY lnH lnC lnL lnD lnA lnHH lnHC lnHL lnHD lnHA lnCC lnCL lnCD lnCA lnLL lnLD lnLA lnDD lnDA lnAA T2 T3 T4 T5 T6 T7 T8 T9 , ti
predict uPL, u

******* Battese and Coelli, 1992 *****
xtfrontier lnY lnH lnC lnL lnD lnA lnHH lnHC lnHL lnHD lnHA lnCC lnCL lnCD lnCA lnLL lnLD lnLA lnDD lnDA lnAA T2 T3 T4 T5 T6 T7 T8 T9 , tvd
predict uBC, u

******* True Fixed Effects, Greene (2005)*****
*sfpanel  lnY lnH lnC lnL lnD lnA lnHH lnHC lnHL lnHD lnHA lnCC lnCL lnCD lnCA lnLL lnLD lnLA lnDD lnDA lnAA T2 T3 T4 T5 T6 T7 T8 T9 , model(tfe)
*predict utfe, u
*predict utfe_jlms, jlms

******* True Random Effects, Greene (2005)*****
*sfpanel  lnY lnH lnC lnL lnD lnA lnHH lnHC lnHL lnHD lnHA lnCC lnCL lnCD lnCA lnLL lnLD lnLA lnDD lnDA lnAA T2 T3 T4 T5 T6 T7 T8 T9 , model(tre)
*predict utre, u
*predict utre_jlms, jlms
*utfe utfe_jlms utre utre_jlms
sum uPOOL uPL uBC 
*do sub_do/FarmPanelEstimation.do

*/

********************************************************


********************************************************
*** CLEANING UP             
********************************************************
* Drop the global macro ms which contains the country
*   names, clear data in memory, erase blank.dta, and
*   close logs
*
macro drop ms sectors oldvars newvars dataname datadir orig_ibsas_nfs1 dodir1 outdatadir1 Regional_outdatadir1 countrylabels fdairygo_lu_vlist1
*clear
erase blank.dta
capture log close
capture cmdlog close
********************************************************


********************************************************
********************************************************
* OUTPUT WILL BE IN THE OUTPUT FOLDER. LOGS WILL BE IN
* THE LOGS FOLDER. DID YOU UNCOMMENT ALL THE PARTS YOU
* WANTED TO RUN?
********************************************************
********************************************************
