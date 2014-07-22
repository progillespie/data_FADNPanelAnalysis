/* This checks if the components of totalspecificcosts sum correctly.
    If count is 0 (or sufficiently low) then the sum is within an acceptable
    deviation tolerance (set in the if condition in the count command)  */


capture drop testsc
capture drop df_testsc

capture drop feedgl_ha  	 
capture drop seeds_ha  	 
capture drop fert_ha  	 
capture drop croppro_ha   
capture drop othlivsc_ha  
capture drop othcrop_ha   

capture drop feedgl_lt  	 
capture drop seeds_lt  	 
capture drop fert_lt  	 
capture drop croppro_lt   
capture drop othlivsc_lt  
capture drop othcrop_lt   

gen feedgl_ha  	 = feedforgrazinglivestock     * exchangerate/cex / totaluaa
gen seeds_ha  	 = seedsandplants 	       * exchangerate/cex / totaluaa       
gen fert_ha  	 = fertilisers                 * exchangerate/cex / totaluaa   
gen croppro_ha   = cropprotection	       * exchangerate/cex / totaluaa       	
gen othlivsc_ha  = otherlivestockspecificcosts * exchangerate/cex / totaluaa   	
gen othcrop_ha   = othercropspecific           * exchangerate/cex / totaluaa

gen feedgl_lt  	 = feedforgrazinglivestock     * exchangerate/cex / dotomkgl
gen seeds_lt  	 = seedsandplants 	       * exchangerate/cex / dotomkgl       
gen fert_lt  	 = fertilisers                 * exchangerate/cex / dotomkgl   
gen croppro_lt   = cropprotection	       * exchangerate/cex / dotomkgl       	
gen othlivsc_lt  = otherlivestockspecificcosts * exchangerate/cex / dotomkgl   	
gen othcrop_lt   = othercropspecific           * exchangerate/cex / dotomkgl

tabstat				///
	feedgl_ha  	///
	seeds_ha  	///
	fert_ha  	///
	croppro_ha   	///
	othlivsc_ha  	///
	othcrop_ha   	///
if year == 2008, by(country)

tabstat				///
	feedgl_lt  	///
	seeds_lt  	///
	fert_lt  	///
	croppro_lt   	///
	othlivsc_lt  	///
	othcrop_lt   	///
if year == 2008, by(country)


gen 	testsc = 		        	///
	feedforgrazinglivestock	 + 	///
	feedforpigspoultry	         + 	///
	otherlivestockspecificcosts      + 	///
	seedsandplants 	                 + 	///
	fertilisers                      + 	///
	cropprotection	                 + 	///
	othercropspecific                + 	///
	forestryspecificcosts 

gen df_testsc = totalspecificcosts  - testsc
count if df_testsc > 0.05 & df_testsc 


replace testsc = 		        	///
	ddfeedgl      + ///
	ddseeds       + ///
	ddfert        + ///
	ddcroppro     + ///
	ddothlivsc    
	
replace df_testsc = fdairydc - testsc
count if df_testsc > 0.05 & df_testsc 



replace testsc = 		        	///
	ddfeedgl_ha      + ///
	ddseeds_ha       + ///
	ddfert_ha        + ///
	ddcroppro_ha     + ///
	ddothlivsc_ha    
	
gen fdairydc_ha = fdairydc/daforare
replace df_testsc = fdairydc_ha - testsc
count if df_testsc > 0.05 & df_testsc 


tabstat             	///
	fdairydc_ha  	///
	ddfeedgl_ha  	///
	ddseeds_ha  	///
	ddfert_ha  	///
	ddcroppro_ha  	///
	ddothlivsc_ha  	///
	if year==2008,by(country)
