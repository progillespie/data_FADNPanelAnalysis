/* Attempts to follow methodology set out in FADN's 
	EU Dairy Farms Report (pg. 56 in ANNEX I)

	which was available at the following URL at the time of writing

	http://ec.europa.eu/agriculture/rica/pdf/dairy_report_2010.pdf
	last accessed @ 16:55 20th Jan. 2014

   I use abbreviations in the flowchart from that section
    to make clear what I intended to calculate.
*/


* Non-fodder feed value
capture drop nonfodderfeed
gen nonfodderfeed = feedforgrazinglivestockhomegrown - (fodderrootsbrassicasFU + othforageplantsFU)


* Create appropriate measures of output (see report)

capture drop MO
gen MO  = cowsmilkandmilkproducts + subsidiesdairying 
/* Incomplete. FADN documentation says that Milk herd renewal costs 
	not estimable for IE. Also cannot do fodder adjustment (only 
	have homegrown feed variable, which includes more than just 
	fodder.                  				*/
capture drop TO
gen TO  = (totaloutput + totalsubsidiesexcludingoninvestm) - ///
          (fodderrootsbrassicasFU + othforageplantsFU)
/*
Re: the subtraction of fodderrootsbrassicasFU + othforageplantsFU from TO... 

From page 58 of report:

The home-grown fodder value is deducted from the total output (denominator 
in the allocation ratio MO/TO) because it is included in the farm total 
output and it has to be deducted in order to obtain a comparable ratio 
between the Member States that value fodder and those that do not.
*/



* Create appropriate measures of dairy livestock units
capture drop DLU
gen DLU =                                   ///
      (                                     ///
        (                                   ///
          (femalecattle1LT2yrsAV * 0.6)  +  ///
          (breedingheifersAV     * 0.5)     ///
        )                                *  ///
        (                                   ///
          (dairycowsAV+ culldairycowsAV) /  ///
          (dairycowsAV + culldairycowsAV + othercowsAV )  ///
        )                                   ///
      )                                  +  ///
      dairycowsAV                        +  ///
      culldairycowsAV     



* Create allocation ratios

   *... standard ratios
gen DLU_GLU = DLU/grazinglivestock
gen DLU_TLU = DLU/totallivestockunits 
gen MO_TO   = MO/TO

   *... specific forage cost ratios
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
	* Added small number to denominator to prevent 
	*  missing values when fraction was 0/0	 

gen cropprocostalloc =            ///
	(                         ///
	 fodderrootsbrassicasAA + /// numerator
	 othforageplantsAA        ///
	)                       / /// ___________
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



* Allocate DC components
capture drop ddfeedgl      
capture drop ddothlivsc    
capture drop ddseeds       
capture drop ddfert        
capture drop ddcroppro     
capture drop ddothcrop     
capture drop ddforestsc    
capture drop ddforestsc    


gen ddfeedgl      = feedforgrazinglivestock         * DLU_GLU 
gen ddothlivsc    = otherlivestockspecificcosts     * DLU_TLU 
* Cannot add in milk levy, as I don't have that variable.

* Forage specific costs
gen ddseeds       = seedsandplants * ///
                    seedcostalloc  * ///
                   (dairycows/grazinglivestock)
gen ddfert        = fertilisers    * ///
                    fertcostalloc  * ///
                   (dairycows/grazinglivestock) 
gen ddcroppro     = cropprotection   * ///
                    cropprocostalloc * ///
                   (dairycows/grazinglivestock)
gen specificforagecosts = ddseeds + ddfert + ddcroppro



capture drop ddnonfodderfeed
gen ddnonfodderfeed = nonfodderfeed * DLU_TLU

capture drop purchfeed
gen purchfeed = fdgrzlvstk - feedforgrazinglivestockhomegrown 
*(fdgrzlvstk OR feedforgrazinglivestock) - feedforgrazinglivestockhomegrown 

capture drop ddpurchfeed
gen ddpurchfeed = purchfeed * DLU_GLU




* Allocated direct (specific) costs
capture drop fdairydc 
gen fdairydc = ///
	ddfeedgl      + ///
	ddseeds       + ///
	ddfert        + ///
	ddcroppro     + ///
	ddothlivsc    



* Allocate OH components
capture drop dohcontwork   
capture drop dohmchbldcurr 
capture drop dohenergy     
capture drop dohothdirin   
capture drop dohdep        
capture drop dohwages      
capture drop dohrent       
capture drop dohintst      

gen dohmchbldcurr = machininerybuildingcurrentcosts * MO_TO
gen dohenergy     = energy                          * MO_TO
gen dohcontwork   = contractwork                    * MO_TO
gen dohothdirin   = otherdirectinputs               * MO_TO
gen dohdep        = depreciation                    * MO_TO
gen dohwages      = wagespaid                       * MO_TO
gen dohrent       = rentpaid                        * MO_TO
gen dohintst      = interestpaid                    * MO_TO
gen dohfamlab     = familylabourcost                * MO_TO
gen dohunpdcap    = unpaidcapcost                   * MO_TO



* Allocated overhead costs (+ external factors)
capture drop fdairyoh
gen fdairyoh 	      = ///
	dohmchbldcurr + ///
	dohenergy     + ///
	dohcontwork   + ///
	dohothdirin   + ///
	dohdep        + ///
	dohwages      + ///
	dohrent       + ///
	dohintst


* Allocated economic costs (opportunity costs)
capture drop dohfamlab     
capture drop dohunpdcap    
gen decfamlab     = familylabourcost                * MO_TO
gen decunpdcap    = unpaidcapcost                   * MO_TO


capture drop fdairyec
gen fdairyec          = ///
	decfamlab     + ///
	decunpdcap    


* Enterprise level GM can now be calculated.
capture drop fdairygm
gen fdairygm = fdairygo - fdairydc


















/* Previously used the following simple allocation 
    where dpalloclu = dairycows/totallivestockunits. 
   
   dpalloclu, fdairygo, fdairydc, and fdairyoh were all defined 
    in renameFADN.do

   sub_do/cex_vargen.do has been used so far to allocate the 
    components of each of these but I've cut these out of there
    (see below for reference). 

   This will need to be changed in renameFADN.do, as will the 
    allocation the totals of DC, OH, GM, and NM (NM not yet in 
    renameFADN.do). 


* DC
gen ddfeedgl      = feedforgrazinglivestock         * dpalloclu
gen ddfeedpp      = feedforpigspoultry              * dpalloclu
gen ddothlivsc    = otherlivestockspecificcosts     * dpalloclu
gen ddseeds       = seedsandplants                  * dpalloclu
gen ddfert        = fertilisers                     * dpalloclu
gen ddcroppro     = cropprotection                  * dpalloclu
gen ddothcrop     = othercropspecific               * dpalloclu
gen ddforestsc    = forestryspecificcosts           * dpalloclu

                  * OH
gen dohcontwork   = contractwork                    * dpalloclu
gen dohmchbldcurr = machininerybuildingcurrentcosts * dpalloclu
gen dohenergy     = energy                          * dpalloclu
gen dohothdirin   = otherdirectinputs               * dpalloclu
gen dohdep        = depreciation                    * dpalloclu
gen dohwages      = wagespaid                       * dpalloclu
gen dohrent       = rentpaid                        * dpalloclu
gen dohintst      = interestpaid                    * dpalloclu

*/
