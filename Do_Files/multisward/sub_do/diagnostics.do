args dep_vlist indep_vlist

macro list _dep_vlist _indep_vlist 

preserve

keep `dep_vlist' `indep_vlist' country pid year

qui reg  `dep_vlist' `indep_vlist' 
predict xb , xb
predict r  , resid
predict rst, rstudent
predict lev, hat


/* Detecting Unusual and Influential Data
---------------------------------------------*/
rvfplot
  more
lvr2plot 
  more

foreach var of local indep_vlist {
  avplot  `var'
  more
  rvpplot `var', yline(10)
  more

}

graph drop _all


/* Hadi's (1992, 1994) Algorithm to ID possible outliers, optimized by
     Weber (2010) */
bacon `dep_vlist' `indep_vlist', gen(out1)
tw sc rst xb, ml(out1)
tw sc rst xb if out1 == 1, ml(country)
more

/* Tests for Normality of Residuals 
   (for SFA, we expect them to be non-normal. 
    They would be skewed if there is 
    inefficiency present, but they must be 
    LEFT-SKEWED!!!)
--------------------------------------------- */
kdensity r, norm
more


/* Tests for Multicollinearity
---------------------------------------------*/
vif
more


/* Tests for Non-Linearity
---------------------------------------------*/
foreach var of local indep_vlist {

  acprplot `var'
  more
  cprplot `var'
  more

}

graph drop _all

/* Tests for Model Specification
---------------------------------------------*/
linktest 
more
ovtest 
more


/* Wooldridge's panel test for Serial Correlation
---------------------------------------------*/
xtserial `dep_vlist' `indep_vlist'
more


* Data description
describe    pid year `dep_vlist' `indep_vlist'
summ        pid year `dep_vlist' `indep_vlist'

* Panel characterstics
xtdescribe 
xtsum       pid year `dep_vlist' `indep_vlist'



capture erase panel_est.doc


* Pooled OLS
qui reg `dep_vlist' `indep_vlist'
outreg using panel_est, nodisplay ctitle("", Pooled) ///
  starlevels(10 5 1)


* Population-averaged estimator
qui xtreg `dep_vlist' `indep_vlist', pa
outreg using panel_est, merge nodisplay ctitle("", Pop. Avg.)



* Between estimator
qui xtreg `dep_vlist' `indep_vlist', be
outreg using panel_est, merge nodisplay ctitle("", Between)



* Fixed effects estimator 
qui xtreg `dep_vlist' `indep_vlist', fe
estimates store fixed
predict alphafehat, u
outreg using panel_est, merge nodisplay ctitle("", FE)



* First-differences estimator
qui reg D.(`dep_vlist' `indep_vlist'), noconstant
outreg using panel_est, merge nodisplay ctitle("", 1st Diff)



* Random effects estimator
qui xtreg `dep_vlist' `indep_vlist', re theta
estimates store random
outreg using panel_est, merge ctitle("", RE) 
more


* Hausman test for RE vs FE
hausman fixed random
more


* Breusch-Pagan LM test for RE vs OLS
estimates restore random // make sure RE estimates are active
xttest0
more


* Individual specific effects from FE
summ alphafehat
hist alphafehat
more

restore
graph drop _all
STOP!!!
