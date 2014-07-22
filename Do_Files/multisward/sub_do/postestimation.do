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


********************************************************
* Panel must be tsset before running! Can be called at * the bottom of sub_do/biofuels.do 
********************************************************
*
*Ramsey RESET Test*
*******************
*
generate trend = _n
regress osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
estat ovtest


*Multicollinearity*
*******************
*
quietly regress osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
estat vif


*Heteroskedasticity: Breusch-Pagan Test*
****************************************
*
quietly regress osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
estat hettest


*Heteroskedasticity: White's Test*
**********************************
*
quietly regress osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
imtest, white


*Fixed Effects
**************
*
xtreg osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
estimates, fe
store fixed
*
xtreg osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
estimates 
store random
*
hausman fixed random, constant


*Serial Correlation: Prais-Winsten Procedure*
*********************************************
prais 
*


*FE/RE Models with AR(1) Disturbances*
**************************************
*
xtregar osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
estimates, fe
store fixed
*
xtregar osrape_prop policy sizeclass setasideuaa ln_labour ln_ffi solvency intensity specialise
estimates
store random
*
hausman fixed random, constant

********************************************************
