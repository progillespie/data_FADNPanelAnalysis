/* This checks if the components of totalouput sum correctly.
    If count is 0 (or sufficiently low) then the sum is within an acceptable
    deviation tolerance (set in the if condition in the count command) 
    SHORT VERSION
*/


capture drop testto
capture drop df_testto


gen 	testto = 		        	///
	cerealsvalue                    +	///------------
	sugarbeetvalue                  +	///
	fruitvalue                      +	///
	foragecropsvalue                +	///
	proteincropsvalue               +	///
	oilseedrapevalue                +	///
	citrusfruitvalue                +	/// totaloutputcrops
	othercropoutputvalue            +	///
	energycropsvalue                +	///
	industrialcropsvalue            +	///
	wineandgrapesvalue              +	///
	potatoesvalue                   +	///
	vegetablesandflowersvalue       + 	///
	olivesandoliveoilvalue		+ 	///------------
	pigmeat                    	+ 	///
	eggs	                        + 	///
	cowsmilkandmilkproducts    	+ 	///
	sheepandgoats              	+ 	/// totaloutputlivestock
	ewesandgoatsmilk	        + 	///
	beefandveal                	+ 	///
	poultrymeat                	+ 	///
	otherlivestockandproducts	+ 	///------------
	otheroutput	


gen df_testto = totaloutput - testto
count if df_testto > 0.05 & df_testto < . 

qui summarize df_testto
di "The maximum difference between testto and totaloutput is `r(max)'."
