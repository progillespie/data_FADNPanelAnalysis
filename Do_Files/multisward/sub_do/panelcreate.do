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

global paneldir G:/Data/data_FADNPanelAnalysis
global dodir $paneldir/Do_Files/FADN_IGM
* Creates global macros for directory structure
*   (e.g. $paneldir, $origdatadir, etc.)
cd $dodir
do sub_do/dirstruct.do

version 9.0
clear
clear matrix
set mem 700m
set matsize 1000
set more off
capture log close
capture cmdlog close
capture mkdir logs
log using logs/fadn_igm.smcl, replace
di  "Job  Started  at  $S_TIME  on $S_DATE"
cmdlog using logs/fadn_igm.txt, replace

* The following makes the necessary directories 
*   ALWAYS KEEP THIS TURNED ON
do sub_do/make_dir.do



********************************************************
* DEFINING THE PANEL via global macros   
********************************************************
* Countries available are --> "Austria Belgium Bulgaria 
*   Cyprus CzechRepublic Denmark Estonia Finland France 
*   Germany Greece Hungary Ireland Italy Latvia Lithuania 
*   Luxembourg Malta Netherlands Poland Portugal Romania 
*   Slovakia Slovenia Spain Sweden UnitedKingdom" 
global ms "France Germany Ireland Netherlands UnitedKingdom" 

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
gen start=1
save blank, replace
do sub_do/databuild.do

* ALWAYS LEAVE THESE LINES TURNED ON, EVEN IF RUNNING 
*   databuild.do again.
use $outdatadir/$dataname.dta, clear
do sub_do/countrylabels.do
do sub_do/model_setup.do
********************************************************



********************************************************
* GENERATING DESCRIPTIVES 
********************************************************
* These do files generate output datasets and graphs. 
*
* Do files creating csv's for tables. 
*   Saves in output/spreadsheets. 
*do sub_do/
*
* Do files which create graphs
*do sub_do/
********************************************************



********************************************************
* MODELLING               
********************************************************
*do sub_do/FADNModel.do
********************************************************



********************************************************
*** CLEANING UP             
********************************************************
* Drop the global macro ms which contains the country
*   names, clear data in memory, erase blank.dta, and
*   close logs
*
*macro drop ms sectors oldvars newvars dataname
*clear
*erase blank.dta
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
