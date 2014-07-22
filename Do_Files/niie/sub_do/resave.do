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

clear
*
foreach country in "Austria" "Belgium" "Bulgaria" "Cyprus" "CzechRepublic" "Denmark" "Estonia" "Finland" "France" "Germany" "Hungary" "Italy" "Latvia" "Lithuania" "Luxembourg" "Netherlands" "Poland" "Portugal" "Romania" "Slovakia" "Slovenia" "Spain" "Sweden" "UnitedKingdom" {
clear
di "`country'"
insheet using ../CountryData/`country'.csv
save ../CountrySTATAFiles/`country', replace
}
********************************************************

