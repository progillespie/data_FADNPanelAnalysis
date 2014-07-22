capture mkdir output/spreadsheets
*local varlist = subinstr("$fdairygo_lu_vlist1", "grassregion","",1)
/*
* creating csv's 
collapse (mean) `varlist' pid if grassregion < . [weight=intwt], by(grassregion) 
outsheet using output/spreadsheets/means.csv, comma replace

use ../../OutData/FADN_IGM/SFA_pre, clear
collapse (sd) `varlist' pid if grassregion < . [weight=intwt], by(grassregion) 
outsheet using output/spreadsheets/standarddeviations.csv, comma replace


use ../../OutData/FADN_IGM/SFA_pre, clear
collapse (semean) `varlist' (count) pid if grassregion < . [weight=intwt], by(grassregion) 
outsheet using output/spreadsheets/standarerrors.csv, comma replace
*/
* ... csv's created.
tabout grassregion using output/spreadsheets/xstats.csv [weight = intwt], sum c(mean fdairygo_lu sd fdairygo_lu mean landval_ha  sd landval_ha mean fdferfil_ha sd fdferfil_ha mean daforare sd daforare mean dpnolu sd dpnolu mean flabpaid sd flabpaid mean flabunpd sd flabunpd mean ogagehld sd ogagehld mean fsizuaa sd fsizuaa mean fdratio sd fdratio) style(csv) replace
