*****************************************************
*****************************************************
* Panel Estimation
*
* Cathal O'Donoghue, RERC Teagasc
* &
* Patrick R. Gillespie
* Walsh Fellow
*****************************************************
*****************************************************


local outdatadir = "$outdatadir1" 
local panel_vlist = "$panel_vlist_1" 
local modeltype = "$modeltype1"

/*
***************************************************************
* Estimate Individual Panel Regressions (Expalnatory Variables)
****************************************************************


foreach var in `panel_vlist' {

	display ""
	display "*****************************************************************************************************" 
	display "Estimating Parameters and Residual for Regression Equation :  `var'"
	display "*****************************************************************************************************" 
	
	* Explanatory Variables
	local `var'_vlist1 = "$`var'_vlist1"   
	local `var'_vlist2 = "$`var'_vlist2"   
	local `var'_re = $`var'_re1

	capture drop ln`var'
	gen ln`var' = ln(`var')

	xtset farmcode year
	iis farmcode

	* Estimate Equation 
	* Random Effects
	if `modeltype' == 1 | ``var'_re' == 1 {
		 xtreg ln`var' ``var'_vlist1' ``var'_vlist2' if(`var'_cond == 1), re
	
	}
	if `modeltype' == 2 {
		 xtreg ln`var' ``var'_vlist1' ``var'_vlist2' if(`var'_cond == 1), fe
	}
	* Stochastic Frontier Model - Time Invariant version
	if `modeltype' == 3 & ``var'_re' != 1 {
		xtfrontier  ln`var' ``var'_vlist1' ``var'_vlist2' if(`var'_cond == 1), ti
	}	

	* For fixed effect component, we have to assign the same random number across all years
	sort farmcode fyear
	by farmcode: egen rnk_farmcode = rank(farmcode), unique
	qui gen unif_`var' = uniform() if rnk_farmcode == 1
	by farmcode: replace unif_`var' = unif_`var'[_n-1] if unif_`var'[_n-1] != .
	drop rnk_farmcode

	* Generate error terms - Panel Data Models
	if `modeltype' <= 2 | ``var'_re' == 1 {
		predict `var'_u if (`var'_cond == 1), u
		predict ue_`var' if (`var'_cond == 1), ue
		gen e_`var' = ue_`var' - `var'_u
		predict `var'_xb if (`var'_cond == 1), xb
		gen test_`var' = exp(`var'_xb + `var'_u + e_`var')
		tabstat `var' test_`var' if `var'_cond == 1, by(year) stats(mean)

		* Store Residual
		gen residual = ln`var' - `var'_u- `var'_xb if `var'_cond == 1
		gen `var'_v = ln`var' - `var'_u- `var'_xb if `var'_cond == 1

		* Store Standard Deviation of the fixed effect to produce residual for those where condition is not true or where residual is missing

		egen tsd_`var'_u = sd(`var'_u)
		replace tsd_`var'_u = 0 if tsd_`var'_u ==.
		egen sd_`var'_u = max(tsd_`var'_u)
		scalar sc_sd_`var'_u = sd_`var'_u[1]

		egen tsd_`var'_v = sd(`var'_v)
		replace tsd_`var'_v = 0 if tsd_`var'_v ==.
		egen sd_`var'_v = max(tsd_`var'_v)
		scalar sc_sd_`var'_v = sd_`var'_v[1]

		qui replace `var'_u = invnorm(unif_`var')*sd_`var'_u if `var'_u == .


		* Store Standard Deviation of Residual to produce residual for those where condition is not true or where residual is missing

		egen tsd_r_`var' = sd(residual)
		replace tsd_r_`var' = 0 if tsd_r_`var' ==.
		egen sd_r_`var' = max(tsd_r_`var')
		scalar sc_sd_r_`var' = sd_r_`var'[1]
		replace residual = invnorm(uniform())*sd_r_`var' if residual == .

	}


	* Generate error terms - Stochastic Frontier Model - Time Invariant version
	if `modeltype' == 3 & ``var'_re' != 1{
		predict `var'_u if (`var'_cond == 1), u
		predict `var'_xb if (`var'_cond == 1), xb
		gen `var'_v = ln`var' - `var'_u - `var'_xb if `var'_cond == 1

		* Simulate a random number for u
		scalar sc_sigma_u =  e(sigma_u)
		scalar sc_mu = [mu]_cons
		gen mltrn = normprob((0 - sc_mu)/sc_sigma_u)
		gen mrtrn = 1
		gen double tem1 = (mrtrn-mltrn)*unif_`var' + mltrn
		egen tsd_`var'_u = sd(`var'_u)
		replace tsd_`var'_u = 0 if tsd_`var'_u ==.
		egen sd_`var'_u = max(tsd_`var'_u)
		scalar sc_sd_`var'_u = sd_`var'_u[1]
		gen u_in = invnorm(tem1)*sc_sigma_u + sc_mu
		qui replace `var'_u = u_in if `var'_cond == 0
		capture drop mltrn-u_in

		* Simulate a random number for v

		egen tsd_`var'_v = sd(`var'_v) if `var'_cond == 1
		qui replace tsd_`var'_v = 0 if tsd_`var'_v == .
		egen sd_`var'_v =max(tsd_`var'_v)
		scalar sc_sd_`var'_v = sd_`var'_v[1]

		*mean of residual

		egen tmean_`var'_v = mean(`var'_v) if `var'_cond == 1
		qui replace tmean_`var'_v = -999999 if tmean_`var'_v == .
		egen mn_`var'_v =max(tmean_`var'_v)
		scalar sc_mn_`var'_v = mn_`var'_v[1]

		qui replace `var'_v = sc_mn_`var'_v + invnorm(uniform())*sc_sd_`var'_v if `var'_cond == 0

		gen test_`var' = exp(`var'_xb + `var'_u + `var'_v )
		gen residual = `var'_v 
		tabstat `var' test_`var' if `var'_cond == 1, by(year) stats(mean)
		
		tab `var'_cond, sum(`var'_xb)
		tab `var'_cond, sum(`var'_u)
		tab `var'_cond, sum(`var'_v)

	}

	** Store Parameters

	scalar sc_`var'_cons = _b["_cons"]
	scalar list sc_`var'_cons
	foreach var1 in ``var'_vlist2' {
		di "`var1'"

		scalar sc_`var'_`var1' = _b["`var1'"]
		scalar list sc_`var'_`var1'
	}
	foreach var1 in ``var'_vlist1' {
		di "`var1'"

		scalar sc_`var'_`var1' = _b["`var1'"]
		scalar list sc_`var'_`var1'
	}

	gen a = 0

	* Validation Data
	display " Validation Statistics"
	tabstat `var' ``var'_vlist1' ``var'_vlist2' residual `var'_u [weight = wt], by(`var'_cond) stats(mean)


     
	* Store residual
	capture drop r_`var'
	gen r_`var' = residual
	capture drop pred_`var' 
	gen pred_`var' = `var'_xb

	* Clean Data
	drop `var'_xb-a unif_`var'
	drop ln`var'

}

*/
