* Calculate allocation weights for specific forage costs

*Excel formulae
*% area of foder crops….in total UAA..seed * =('LU''s'!D$29+'LU''s'!D$31 +'LU''s'!D$34)/('LU''s'!D$71-('LU''s'!D$33+'LU''s'!D$35+'LU''s'!D$36+'LU''s'!D$37))

*% area of foder crops….in total UAA..fertilisers * =('LU''s'!D$29+'LU''s'!D$31+'LU''s'!D$34+'LU''s'!D$36)/('LU''s'!D$71-('LU''s'!D$33+'LU''s'!D$35+'LU''s'!D$37))

*% area of foder crops….in total UAA…crop protection * =('LU''s'!D$29+'LU''s'!D$31)/('LU''s'!D$71-('LU''s'!D$33+'LU''s'!D$34+'LU''s'!D$35+'LU''s'!D$36+'LU''s'!D$37))

capture drop seedcostalloc
gen seedcostalloc = 		  ///
	(fodderrootsbrassicasAA + /// 
	 othforageplantsAA      + ///
	 temporarygrassAA )     / ///
	(totaluaa               - ///
	 (fallowlandaa          + ///
	  leasedtoothersAA      + ///
	  meadopermpastAA       + ///
          roughgrazingAA ) )
/*
gen seedcostalloc =           ///
	(                         ///
	 fodderrootsbrassicasAA + ///
	 othforageplantsAA      + /// numerator 
	 temporarygrassAA         ///
	 )                      / /// ___________
	(                         ///
	 totaluaa               - ///
	 fallowlandaa           - ///
	 leasedtoothersAA       - /// denominator
	 meadopermpastAA        - ///
	 roughgrazingAA         + ///
	 0.000000000000001        ///
	 )
	 * Added small number to denominator to prevent 
	 *  missing values when fraction was 0/0
*/
capture drop fertcostalloc
*gen fertcostalloc
gen fertcostalloc =           ///
	(                         ///
	 fodderrootsbrassicasAA + ///
	 othforageplantsAA      + /// numerator
	 temporarygrassAA       + ///
	 meadopermpastAA          ///
	 )                      / /// ___________
	(                         ///
	 totaluaa               - ///
	 fallowlandaa           - ///
	 leasedtoothersAA       - /// denominator
	 roughgrazingAA         + ///
	 0.000000000000001        ///
	 )
	 * Added small number to denominator to prevent *  missing values when fraction was 0/0	 

capture drop cropprocostalloc
*gen cropprocostalloc
gen cropprocostalloc =        ///
	(                         ///
	 fodderrootsbrassicasAA + /// numerator
	 othforageplantsAA        ///
	 )                      / /// ___________
	(                         ///
	 totaluaa               - ///
	 fallowlandaa           - ///
	 temporarygrassAA       - ///
	 leasedtoothersAA       - /// denominator
	 meadopermpastAA        - ///
	 roughgrazingAA         + ///
	 0.000000000000001        ///
	 )
	 * Added small number to denominator to prevent 
	 *  missing values when fraction was 0/0
	 
	 
* Multiply cost items by weights and by DLU/GLU ratio
capture drop ddseedcosts		 
gen ddseedcosts		 = seedsandplants * seedcostalloc * (dairycows/grazinglivestock)
capture drop ddfertiliser	 
gen ddfertiliser	 = fertilisers    * fertcostalloc * (dairycows/grazinglivestock) 
capture drop ddcropprotection 
gen ddcropprotection = cropprotection * cropprocostalloc * (dairycows/grazinglivestock)


