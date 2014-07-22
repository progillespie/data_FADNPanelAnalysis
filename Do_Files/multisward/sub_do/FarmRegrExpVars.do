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

foreach var in `unitvars' {
	capture drop `var'_ha 
	capture drop `var'_lu 
	gen `var'_lu = `var'/dpnolu
	gen `var'_ha = `var'/totaluaa
	}
**Dairy
local var = "fdairygo_lu"
*local lnvars = "fdairygo_lu landval_ha fdferfil_ha daforare dpnolu_ha flabtotl flabpaid flabunpd ogagehld  fsizuaa"
local lnvars = "fdairygo dotomkgl landval fdferfil daforare dpnolu flabtotl flabpaid flabunpd ogagehld  fsizuaa "
*machinee buildingse
global `var'_vlist1   =   "lnfdairygo_lu lnlandval_ha lnfdferfil_ha lndaforare lndpnolu_ha lnflabpaid lnflabunpd ogagehld lnfsizuaa lnfdratio azone2 azone3 hasreps teagasc"

*********************************************************
* Code snipped from FarmPanelEstimation.do (for testing)

foreach var in `lnvars'{
	capture drop ln`var'
	gen ln`var' = ln(`var')
	}
*********************************************************

xtset pid year
iis pid
