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
* defining regions by EU zones (via email from 
*  Alain Peeters to Fiona Thorne)
********************************************************
* create grassregion and code as follows:
*  1 "Atlantic Plains"
*  2 "Humid Mountains"
*  3 "Mediterranean Zones"
*  4 "Continental Europe"
********************************************************


gen grassregion = 7

label define grassregion  1 "Bretagne" 2 "Normandie-Haute" 3 "Normandie-Basse" 4 "Wales" 5 "Ireland" 6 "Bayern" 7 "Other" 
label value grassregion grassregion

********************************************************
* Atlantic Plains (1)
********************************************************
*   France
*     (Brittany) (IE): Forage crops region: temporary grasslands + maize;
replace grassregion = 1 if region==163
*     (Normandy) (IE): Permanent grassland and maize region
*     "Bocage" <- generic term for mixed woodland, pasture, and hedgerow’
*	... two regions "Haute(Upper)"
replace grassregion = 2 if region==133
*	... and "Basse(Lower)"
replace grassregion = 3 if region==135


*   UK 
*     (Wales) (AU-IBERS)
replace grassregion = 4 if region==421
*     (Northern Ireland) <-- presume Alain meant the entire island
*replace grassregion =  if region==441


*   Ireland 
*     (TEAGASC): Grassland region: permanent grassland dominant in the Agricultural Area (AA).
replace grassregion = 5 if region==380
********************************************************
********************************************************



********************************************************
* Humid Mountains (2) <-- don't have this. Fiona informed Alain of this in September.
********************************************************
*   Switzerland (Agroscope, FiBL): Wet mountain region
*replace grassregion = 1 if region==
********************************************************
********************************************************


********************************************************
* Mediterranean Zones (3) 
********************************************************
*   Italy (UNIUD): Mediterranean regions in fertile plains and valleys as well as in dry mountain 
*	... just took the top three regions for dairy
*replace grassregion =  if region==221
*replace grassregion =  if region==230
*replace grassregion =  if region==260
********************************************************
********************************************************


********************************************************
* Continental Europe (4)
********************************************************
*   Poland (Western part) (PULS): Arable land and livestock region; 
*replace grassregion =  if region==790
*	... descriptives suggest that Podlanskie(795) is the most important
*	region for dairying.


*   Germany (part of Bavaria) (FiBL): Arable land and livestock region;
replace grassregion = 6 if region==90
********************************************************
********************************************************

tab grassregion, gen(GREGION)


