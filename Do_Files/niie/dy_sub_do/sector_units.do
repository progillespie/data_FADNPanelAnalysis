****************************************************
*log close
*log using `outdatadir'/tab_logs/sector_units.log, text replace
*****************************************************
* create local macros of vars to keep when dataset is collapsed
local fdairy = "fdairygo fdairygm fdairydc"
local farm = "farmgo farmgm farmdc farmffi"
local go_vlist = "daforare doslcmgl  domlkbon  domlkpen  dosllmgl  domkfdgl  domkalvl  docftfvl docftfno docfslvl docfslno  doschbvl  dotochbv dotochbn  dopchbvl dopchbno  dotichbv dotichbn  dovlcnod" 

local go_plist = "p_doslcm p_dosllm p_domkfd p_docftfvl p_docfslvl p_dotochbv p_dopchbvl p_dotichbv" 

local ct_vlist = "dpnolu ddconvalq ddpasturq ddwinforq d_othmiscdcq ivmalldyq iaisfdyq itedairyq imiscdryq flabccdyq"

local ct_plist = "PCattleFeed PTotalFert POtherInputs PVetExp PMotorFuels PLabour"



* Following Head of Department's directions, changed code to generate
* per unit measures after summing columns by each year (sector-wide unit measures)

* tabstat will make a table in the log file; collapse then outsheet
* gives you a csv file which will match that output
sort year
tabstat daforare dpnolu doslmkgl `fdairy'[weight=wt], by(year) stats(sum)
collapse (sum) doslmkgl `fdairy' `farm' `go_vlist' `go_plist' `ct_vlist' `ct_plist' dosl*vl [weight=wt], by(year)


*******
* Some unit measures were created by doFarmDerivedVars.do, but these were not selected by the collapse command above, so we can recreate them here without a problem (i.e. no drop command necessary).
*******

* Per hectare measures
foreach var of varlist `fdairy' `go_vlist' `ct_vlist'{
	gen `var'_ha = `var'/daforare
}

* Per hectare indices (base = 2000)
foreach var of varlist `fdairy'{
	gen `var'_ha_i = `var'_ha/`var'_ha[2]
}

* Per LU measures
foreach var of varlist `fdairy' `go_vlist' `ct_vlist'{
	gen `var'_lu = `var'/dpnolu
}

* Per LU indices (base = 2000)
foreach var of varlist `fdairy'{ 
	gen `var'_lu_i = `var'_lu/`var'_lu[2]
}

* Per litre measures
foreach var of varlist `fdairy' `go_vlist' `ct_vlist'{
	gen `var'_lt = `var'/doslmkgl
}

* Per litre indices (base = 2000)
foreach var of varlist `fdairy'{ 
	gen `var'_lt_i = `var'_lt/`var'_lt[2]
}

gen stkrate=dpnolu/daforare
gen stkrate_i=stkrate/stkrate[2]
gen yield = doslmkgl/dpnolu 
gen yield_i = yield/yield[2]

