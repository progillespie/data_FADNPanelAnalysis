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
* Setup database (dta) for creating Figure 1
********************************************************



********************************************************
* Load the blank starting dataset, append each country
*   dataset to the dataset in memory, replacing three
*   letter abbrev. with 2 letter abbrev.	
********************************************************
*
use blank, clear
*
foreach country of global ms {
	di "Appending observations from `country'..."
	append using ../CountrySTATAFiles/`country'
}
*
	replace country = "BE" if country== "BEL"
	replace country = "BG" if country=="BGR"
	replace country = "CY" if country=="CYP"
	replace country = "CZ" if country=="CZE"
	replace country = "DK" if country=="DAN"
	replace country = "DE" if country=="DEU"
	replace country = "ES" if country=="ESP"
	replace country = "EE" if country=="EST"
	replace country = "FR" if country=="FRA"
	replace country = "GR" if country=="ELL"	
	replace country = "HU" if country=="HUN"
	replace country = "IE" if country=="IRE "
	replace country = "IT" if country=="ITA"
	replace country = "LT" if country=="LTU"
	replace country = "LU" if country=="LUX"
	replace country = "LV" if country=="LVA"
	replace country = "MT" if country=="MLT "
	replace country = "NL" if country=="NED"
	replace country = "AT" if country=="OST"
	replace country = "PL" if country=="POL"
	replace country = "PT" if country=="POR"
	replace country = "FI" if country=="SUO"
	replace country = "RO" if country=="ROU"
	replace country = "SE" if country=="SVE"
	replace country = "SK" if country=="SVK"
	replace country = "SI" if country=="SVN"
	replace country = "UK" if country=="UKI" 

********************************************************
* Drop the blank obs and generate variables,
*   sometimes with labels, and save dataset
********************************************************
*
drop if farmcode >= .
*
gen energycropsdum = 0
label define energycropsdum 0 "Has no energy crops" 1 "Has energy crops"
label values energycropsdum energycropsdum
replace energycropsdum = 1 if energycropsuaa>0
gen tllgedum = 0
replace tllgedum = 1 if generalfarmtype==1
replace tllgedum = 8 if generalfarmtype==8
gen solvency = totalliabilities/totalassets
gen ffi_ha = familyfarmincome/totaluaa
gen gfi_ha = grossfarmincome/totaluaa
gen lab_ha = labourinputhours/totaluaa
gen seta_ha = setasideuaa/totaluaa
gen subs_gfi = totalsubsidiesexcludingoninvestm/grossfarmincome
gen subs_ha = totalsubsidiesexcludingoninvestm/totaluaa
gen engyuaa_uaa = energycropsuaa/totaluaa
*
save energygph, replace
********************************************************
