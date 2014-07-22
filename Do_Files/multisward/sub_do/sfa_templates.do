/*
* These are kept as templates only
*           SFA Models
*---------------------------------------
* Time invariant model using a meta-frontier
xtfrontier `dep_vlist' `indep_vlist' `location_vlist', ti
estimates store meta_model_ti
predict meta_te_ti, te
timer off 1
timer list



timer clear 2
timer on 2
sfpanel `dep_vlist' `indep_vlist' if country=="IRE", model(bc88)
estimates store meta_model_sfpl
*predict meta_te_sfpl, te
timer off 2



* Time varying decay model using a common frontier for all countries
sfpanel `dep_vlist' `indep_vlist' `location_vlist', model(bc95) emean(`indep_vlist') usigma(`indep_vlist') // <- needs a grass variable
estimates store meta_model_bc95
predict meta_te_bc95, te



* Greene's True Fixed Effects
sfpanel `dep_vlist' `indep_vlist' `location_vlist', model(tfe) distribution(hnormal)
estimates store meta_model_tfe
predict meta_te_tfe 

*/
