* Ireland
tabstat fdairygo fdairydc fdairyoh if cntry==1 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==1 & year==2008 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==1 & year==2008 & dpnolu > 65 [weight=wt],stats(mean)

* Whole farm basis, as individual components haven't been allocated yet
tabstat totaloutput 					///
	feedforgrazinglivestock          	///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	contractwork                     	///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid if cntry==1 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)

	tabstat totaloutput 				///
	feedforgrazinglivestock          	///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	contractwork                     	///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid if cntry==1 & year==2008 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean)
	
	tabstat totaloutput 				///
	feedforgrazinglivestock          	///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	contractwork                     	///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid if cntry==1 & year==2008 & dpnolu > 65 [weight=wt],stats(mean)
	

	
* Northern Ireland	
tabstat fdairygo fdairydc fdairyoh if cntry==2 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==2 & year==2008 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==2 & year==2008 & dpnolu > 65 [weight=wt],stats(mean)

* Whole farm basis, as individual components haven't been allocated yet
tabstat totaloutput 					///
	feedforgrazinglivestock          	///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	contractwork                     	///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid if cntry==2 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)

	tabstat totaloutput 				///
	feedforgrazinglivestock          	///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	contractwork                     	///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid if cntry==2 & year==2008 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean)
	
	tabstat totaloutput 				///
	feedforgrazinglivestock          	///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	contractwork                     	///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid if cntry==2 & year==2008 & dpnolu > 85 [weight=wt],stats(mean)
	
codebook dpnolu if cntry==2 & year==2008 & dpnolu <= 55 
codebook dpnolu if cntry==2 & year==2008 & dpnolu > 45 & dpnolu <= 85
codebook dpnolu if cntry==2 & year==2008 & dpnolu > 85 
