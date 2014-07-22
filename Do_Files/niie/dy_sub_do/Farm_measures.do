*****************************************************
*log close
*log using `outdatadir'/tab_logs/farm_measures.log, text replace
*****************************************************
local outdatadir "$outdatadir"
macro list _outdatadir

* doFarmDerivedVars.do created some unit measures, but we'd like to recreate them here, so drop any previous versions in the dataset.
drop *_ha *_lu *_lt

* And now recreate them... 
* Per hectare measures
foreach var of varlist $fdairy $go_vlist $ct_vlist{
	gen `var'_ha = `var'/daforare
}

* Per LU measures
foreach var of varlist $fdairy $go_vlist $ct_vlist{
	gen `var'_lu = `var'/dpnolu
}

* Per litre measures
foreach var of varlist $fdairy $go_vlist $ct_vlist{
	gen `var'_lt = `var'/doslmkgl
}

* Create a local macro containing the proper order of variables for the Excel worksheet. Cannot put year into this list because it will cause an error when we collapse. Specify year `excel' in the outsheet command to get the right order. 
sort year

collapse (mean) $excel [weight=wt], by(year)
