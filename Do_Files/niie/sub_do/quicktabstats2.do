* Ireland
tabstat fdairygo fdairydc fdairyoh if cntry==1 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==1 & year==2008 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==1 & year==2008 & dpnolu > 65 [weight=wt],stats(mean)

* Whole farm basis, as individual components haven't been allocated yet

	* Small herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==1 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)
	
	tabstat								/// 
	farmdc								///
	feedforgrazinglivestock     		///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	if cntry==1 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)
	
	tabstat								/// 
	farmoh								///
	contractwork                        ///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid 						///
	if cntry==1 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)
	
	
	* Moderate herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==1 & year==2008 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean)
	

	tabstat								/// 
	farmdc								///
	feedforgrazinglivestock     		///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	if cntry==1 & year==2008 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean)
	
	tabstat								/// 
	farmoh								///
	contractwork                        ///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid 						///
	if cntry==1 & year==2008 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean)
		
	
	* Large herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==1 & year==2008 & dpnolu > 65 [weight=wt],stats(mean)

	tabstat								/// 
	farmdc								///
	feedforgrazinglivestock     		///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	if cntry==1 & year==2008 & dpnolu > 65 [weight=wt],stats(mean)
	
	tabstat								/// 
	farmoh								///
	contractwork                        ///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid 						///
	if cntry==1 & year==2008 & dpnolu > 65 [weight=wt],stats(mean)
	
	
	
* Northern Ireland	
tabstat fdairygo fdairydc fdairyoh if cntry==2 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==2 & year==2008 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean)
tabstat fdairygo fdairydc fdairyoh if cntry==2 & year==2008 & dpnolu > 85 [weight=wt],stats(mean)

* Whole farm basis, as individual components haven't been allocated yet

	
	if cntry==2 & year==2008 & dpnolu <= 45 [weight=wt],stats(mean)

	* Moderate herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==2 & year==2008 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean)
	
	tabstat								/// 
	farmdc								///
	feedforgrazinglivestock     		///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmoh								///
	contractwork                        ///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid 						///
	if cntry==2 & year==2008 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	
	
	
	* Large herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==2 & year==2008 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmdc
	feedforgrazinglivestock     		///
	feedforpigspoultry	             	///
	otherlivestockspecificcosts      	///
	seedsandplants 	                 	///
	fertilisers                      	///
	cropprotection	                 	///
	othercropspecific                	///
	forestryspecificcosts            	///
	if cntry==2 & year==2008 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmoh
	contractwork                        ///
	machininerybuildingcurrentcosts  	///
	energy                           	///
	otherdirectinputs               	///
	depreciation                     	///
	wagespaid                        	///
	rentpaid                        	///
	interestpaid 						///
	if cntry==2 & year==2008 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	

