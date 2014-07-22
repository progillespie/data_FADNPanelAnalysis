args bmw
/*
 - Makes tables of decompositions at enterprise level
 - Uses exchange rate adjustment
 - GO at enterprise level is just cows milk and dairy product
*/






capture log close
capture cmdlog close

log using "cex_`bmw'godecomp.txt", replace text

********************************************************************************************
* Ireland
********************************************************************************************

	* Small herd (IE)
	tabstat        /// 
	cex_fdairygo_ha	     ///
	cex_cereals          ///
	cex_sugarbeet        ///
	cex_fruit            ///
	cex_foragecrops      ///
	cex_proteincrops     ///
	cex_oilseedrape      ///
	cex_citrus           ///
	cex_othercropoutput  ///
	cex_energycrops      ///
	cex_indlcrops        ///
	cex_wineandgrapes    ///
	cex_potatoes         ///
	cex_vegandflowers    ///
	cex_olivesoliveoil   ///
	cex_pigmeat          ///
	cex_eggs             ///
	cex_cowsmilkdairypr  ///
	cex_sheepandgoats    ///
	cex_ewesandgoatsmilk ///
	cex_beefandveal      ///
	cex_poultrymeat      ///
	cex_othlvstkandprod  ///
	cex_otheroutput      ///
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	

	* Moderate herd (IE)
	tabstat        /// 
	cex_fdairygo_ha	     ///
	cex_cereals          ///
	cex_sugarbeet        ///
	cex_fruit            ///
	cex_foragecrops      ///
	cex_proteincrops     ///
	cex_oilseedrape      ///
	cex_citrus           ///
	cex_othercropoutput  ///
	cex_energycrops      ///
	cex_indlcrops        ///
	cex_wineandgrapes    ///
	cex_potatoes         ///
	cex_vegandflowers    ///
	cex_olivesoliveoil   ///
	cex_pigmeat          ///
	cex_eggs             ///
	cex_cowsmilkdairypr  ///
	cex_sheepandgoats    ///
	cex_ewesandgoatsmilk ///
	cex_beefandveal      ///
	cex_poultrymeat      ///
	cex_othlvstkandprod  ///
	cex_otheroutput      ///
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	

	* Large herd (IE)
	tabstat        /// 
	cex_fdairygo_ha	     ///
	cex_cereals          ///
	cex_sugarbeet        ///
	cex_fruit            ///
	cex_foragecrops      ///
	cex_proteincrops     ///
	cex_oilseedrape      ///
	cex_citrus           ///
	cex_othercropoutput  ///
	cex_energycrops      ///
	cex_indlcrops        ///
	cex_wineandgrapes    ///
	cex_potatoes         ///
	cex_vegandflowers    ///
	cex_olivesoliveoil   ///
	cex_pigmeat          ///
	cex_eggs             ///
	cex_cowsmilkdairypr  ///
	cex_sheepandgoats    ///
	cex_ewesandgoatsmilk ///
	cex_beefandveal      ///
	cex_poultrymeat      ///
	cex_othlvstkandprod  ///
	cex_otheroutput      ///
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	



********************************************************************************************
* Northern Ireland
********************************************************************************************


	* Small herd (NI)
	tabstat        /// 
	cex_fdairygo_ha	     ///
	cex_cereals          ///
	cex_sugarbeet        ///
	cex_fruit            ///
	cex_foragecrops      ///
	cex_proteincrops     ///
	cex_oilseedrape      ///
	cex_citrus           ///
	cex_othercropoutput  ///
	cex_energycrops      ///
	cex_indlcrops        ///
	cex_wineandgrapes    ///
	cex_potatoes         ///
	cex_vegandflowers    ///
	cex_olivesoliveoil   ///
	cex_pigmeat          ///
	cex_eggs             ///
	cex_cowsmilkdairypr  ///
	cex_sheepandgoats    ///
	cex_ewesandgoatsmilk ///
	cex_beefandveal      ///
	cex_poultrymeat      ///
	cex_othlvstkandprod  ///
	cex_otheroutput      ///
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	


	* Moderate herd (NI)
	tabstat        /// 
	cex_fdairygo_ha	     ///
	cex_cereals          ///
	cex_sugarbeet        ///
	cex_fruit            ///
	cex_foragecrops      ///
	cex_proteincrops     ///
	cex_oilseedrape      ///
	cex_citrus           ///
	cex_othercropoutput  ///
	cex_energycrops      ///
	cex_indlcrops        ///
	cex_wineandgrapes    ///
	cex_potatoes         ///
	cex_vegandflowers    ///
	cex_olivesoliveoil   ///
	cex_pigmeat          ///
	cex_eggs             ///
	cex_cowsmilkdairypr  ///
	cex_sheepandgoats    ///
	cex_ewesandgoatsmilk ///
	cex_beefandveal      ///
	cex_poultrymeat      ///
	cex_othlvstkandprod  ///
	cex_otheroutput      ///
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	


	* Large herd (NI)
	tabstat        /// 
	cex_fdairygo_ha	     ///
	cex_cereals          ///
	cex_sugarbeet        ///
	cex_fruit            ///
	cex_foragecrops      ///
	cex_proteincrops     ///
	cex_oilseedrape      ///
	cex_citrus           ///
	cex_othercropoutput  ///
	cex_energycrops      ///
	cex_indlcrops        ///
	cex_wineandgrapes    ///
	cex_potatoes         ///
	cex_vegandflowers    ///
	cex_olivesoliveoil   ///
	cex_pigmeat          ///
	cex_eggs             ///
	cex_cowsmilkdairypr  ///
	cex_sheepandgoats    ///
	cex_ewesandgoatsmilk ///
	cex_beefandveal      ///
	cex_poultrymeat      ///
	cex_othlvstkandprod  ///
	cex_otheroutput      ///
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	

log close
