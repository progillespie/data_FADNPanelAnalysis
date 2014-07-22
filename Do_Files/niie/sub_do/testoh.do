/* This checks if the components of totalspecificcosts sum correctly.
    If count is 0 (or sufficiently low) then the sum is within an acceptable
    deviation tolerance (set in the if condition in the count command)  */

capture drop contwork_ha                   
capture drop mchbldcurr_ha                 
capture drop energy_ha                     
capture drop othdirin_ha                   
capture drop dep_ha                        
capture drop wages_ha                      
capture drop rent_ha                       
capture drop intst_ha                      
capture drop contwork_lt    
capture drop mchbldcurr_lt  
capture drop energy_lt      
capture drop othdirin_lt    
capture drop dep_lt         
capture drop wages_lt       
capture drop rent_lt        
capture drop intst_lt       


* exchangerate/cex
gen contwork_ha    = contractwork * exchangerate/cex                    / daforare
gen mchbldcurr_ha  = machininerybuildingcurrentcosts * exchangerate/cex / daforare
gen energy_ha      = energy                * exchangerate/cex           / daforare
gen othdirin_ha    = otherdirectinputs     * exchangerate/cex           / daforare
gen dep_ha         = depreciation          * exchangerate/cex           / daforare
gen wages_ha       = wagespaid             * exchangerate/cex           / daforare
gen rent_ha        = rentpaid              * exchangerate/cex           / daforare
gen intst_ha       = interestpaid          * exchangerate/cex           / daforare


gen contwork_lt    = contractwork * exchangerate/cex                    / dotomkgl
gen mchbldcurr_lt  = machininerybuildingcurrentcosts * exchangerate/cex / dotomkgl
gen energy_lt      = energy                * exchangerate/cex           / dotomkgl
gen othdirin_lt    = otherdirectinputs     * exchangerate/cex           / dotomkgl
gen dep_lt         = depreciation          * exchangerate/cex           / dotomkgl
gen wages_lt       = wagespaid             * exchangerate/cex           / dotomkgl
gen rent_lt        = rentpaid              * exchangerate/cex           / dotomkgl
gen intst_lt       = interestpaid          * exchangerate/cex           / dotomkgl



capture drop testoh
capture drop df_testoh

gen 	testoh =       	///
	contwork_ha                      	 + ///
	mchbldcurr_ha                    	 + ///
	energy_ha                        	 + ///
	othdirin_ha                      	 + ///
	dep_ha                           	 + ///
	wages_ha                         	 + ///
	rent_ha                          	 + ///
	intst_ha               

gen df_testoh = farmohct_ha - testoh
count if df_testoh > 0.05 & df_testoh 

tabstat		                                  ///
	contwork_ha                      	  ///
	mchbldcurr_ha                    	  ///
	energy_ha                        	  ///
	othdirin_ha                      	  ///
	dep_ha                           	  ///
	wages_ha                         	  ///
	rent_ha                          	  ///
	intst_ha                                  ///    
	if year==2008 [weight=wt] ,by(country)


tabstat		                                  ///
	contwork_lt                      	  ///
	mchbldcurr_lt                    	  ///
	energy_lt                        	  ///
	othdirin_lt                      	  ///
	dep_lt                           	  ///
	wages_lt                         	  ///
	rent_lt                          	  ///
	intst_lt                                  ///    
	if year==2008 [weight=wt] ,by(country)

tabstat		                         ///
	machininerybuildingcurrentcosts  ///
	energy                           ///
	contractwork                     ///
	otherdirectinputs                ///
	depreciation                     ///
	wagespaid                        ///
	rentpaid                         ///
	interestpaid                     ///
	if year==2008 [weight=wt] ,by(country)




replace testoh =        ///
	dohmchbldcurr + ///
	dohenergy     + ///
	dohcontwork   + ///
	dohothdirin   + ///
	dohdep        + ///
	dohwages      + ///
	dohrent       + ///
	dohintst
	
gen fdairyoh_ha = fdairyoh/daforare
replace df_testoh = fdairyoh_ha - testoh
count if df_testoh > 0.05 & df_testoh 



replace testoh = 	     ///
	dohmchbldcurr_ha + ///
	dohenergy_ha     + ///
	dohcontwork_ha   + ///
	dohothdirin_ha   + ///
	dohdep_ha        + ///
	dohwages_ha      + ///
	dohrent_ha       + ///
	dohintst_ha
	
replace df_testoh = fdairyoh_ha - testoh
count if df_testoh > 0.05 & df_testoh 


tabstat             	    ///
	 cex_dohcontwork_ha     ///
	 cex_dohmchbldcurr_ha   ///
	 cex_dohenergy_ha 	    ///
	 cex_dohothdirin_ha     ///
	 cex_dohdep_ha 	    ///
	 cex_dohwages_ha 	    ///
	 cex_dohrent_ha 	    ///
	 cex_dohintst_ha 	    ///
	 if year==2008 [weight=wt] ,by(country)

STOP!!
tabstat             	    ///
	 dohcontwork_lt     ///
	 dohmchbldcurr_lt   ///
	 dohenergy_lt 	    ///
	 dohothdirin_lt     ///
	 dohdep_lt 	    ///
	 dohwages_lt 	    ///
	 dohrent_lt 	    ///
	 dohintst_lt 	    ///
	 if year==2008 [weight=wt] ,by(country)

/*
br		///
	 df_testoh          ///
	 dohcontwork_ha     ///
	 dohmchbldcurr_ha   ///
	 dohenergy_ha 	    ///
	 dohothdirin_ha     ///
	 dohdep_ha 	    ///
	 dohwages_ha 	    ///
	 dohrent_ha 	    ///
	 dohintst_ha 	    ///
	 if df_testoh > 0.05 & df_testoh 

*/
