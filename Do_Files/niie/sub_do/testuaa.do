/*
These are the subcategories of UAA listed in RICC 882 (excluding items
 which double count... i.e. subsubcategories)
K120(4)..128(4) 		Cereals
K129(4)..135(4) 		Other field crops
K136(4) .. K138(4) 		Veg and flowers
NO K139 Mushrooms
K140(4) 			Veg and flowers
K141(4) 			Veg and flowers
K142(4) 			Other field crops
K143(4) 			Other field crops
K144(4) 			Forage crops
K145(4) 			Forage crops
K146(4) if [K146(2) = 1 and 	-------
   K146(3) not equal 5 to 8]    fallows
K146(4) if [K146(2) = 1 and 	-------
   K146(3) = 5 to 8] 		setaside
K147(4) 			Forage crops
NO K148 Other arable crops
NO K149 Land ready for sowing 
         and leased out
K150(4) 			Forage crops
K151(4) 			Forage crops
[K152(4)..154(4)]		Permanent crops 
K155 				Vineyards
[K156(4)..158(4)]		Permanent crops 

NOTE that K173(4) Woodland area is NOT in UAA!
*/


* According to RICC 882 totaluaa is 

capture drop testuaa
gen testuaa = ///
	uaainowneroccupation + ///
	renteduaa + ///
	uaainsharecropping 

* This should also equal

capture drop testuaa2
gen testuaa2 = ///
	cerealsuaa + ///
        otherfieldcropsuaa + ///
	vegetablesandflowersuaa + ///
	foragecropsuaa + ///
	agriculturalfallowsuaa + ///
	setasideuaa + ///
	permanentcropsuaa + ///
	vineyardsuaa

capture drop df_testuaa2
gen df_testuaa2 = totaluaa - testuaa2


tabstat totaluaa testuaa testuaa2 df_testuaa2, by(year)

/*
but mushrooms, other arable crops, and ready land for leasing are missing, 
so there is a very small deviance. 


*/


