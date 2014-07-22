/* README -------------------------------------------------------------------

This file is meant to be run by northsouth.do 
(starting from version northsouth3.do).  
The file creates matrices 

	LAND_IE
	LAND_NI
	LANDdiff

and mata matrices

	IE
	NI
	OWN
	TOTAL
	PCT

See definitions in the code below. The point is to examine rates
of landownership and rental rate, to impute an opportunity cost
for owned land, and to compare these across Ireland and Northern
Ireland. The matrices remain available at the end of northsouth.do.

---------------------------------------------------------------------------*/
/* 
This bit is a copy of the SLIDE 15 portion of northsouth4.do
  It's here because I plan to remove it from northsouth4.do, but would
  like to keep the functionality, having written it already. That's not 
  done yet (and may never be done) the following section should remain
  turned off (via the macro `turnon', created for this purpose) until it 
  can be tested. 
 */

local turnon = "no"

if "`turnon'" = "yes"{
*============================================================================
	preserve

	gen othct = 		///
	   seedsandplants     + ///
	   cropprotection     +	///
	   othercropspecific  +	///
	   forestryspecificcosts

	collapse year totalspecificcosts fdgrzlvstk fertilisers ///
		 otherlivestocksp othct daforare dotomkgl 	///
		 dpnolu flabunpd 				///
		  if year==2008, by(country)



	* suffix for naming vars in following loop
	local suffix_list ""
	local suffix_list  "`suffix_list ' pct"
	local suffix_list  "`suffix_list ' ha"
	local suffix_list  "`suffix_list ' lt"
	local suffix_list  "`suffix_list ' lu"
	local suffix_list  "`suffix_list ' labu"


	foreach suffix of local suffix_list {

	   * choose correct denominator based on suffix
	   if "`suffix'" == "pct"{
	   local denom "totalspecificcosts"
	   }
	   if "`suffix'" == "ha"{
	   local denom "daforare"
	   }
	   if "`suffix'" == "lt"{
	   local denom "dotomkgl" //dosmkgl
	   }
	   if "`suffix'" == "lu"{
	   local denom "dpnolu"
	   }
	   if "`suffix'" == "labu"{
	   local denom "flabunpd"
	   }
	   
	   gen fdgrz_`suffix' = fdgrzlvstk/`denom'
	   label var fdgrz_`suffix' "Feed"

	   gen fert_`suffix' = fertilisers/`denom'
	   label var fert_`suffix' "Fertilser"

	   gen othlvstk_`suffix' = otherlivestockspecific/`denom'
	   label var othlvstk_`suffix' "Other Livestock Costs"

	   gen othct_`suffix' = othct/`denom'
	   label var othct_`suffix' "Other Costs"
	   
	   capture drop rowname
	   gen rowname = "`suffix'"

	   mkmat fdgrz_`suffix'                         ///
		     fert_`suffix'                      ///
		     othlvstk_`suffix'                  ///
		     othct_`suffix'                     ///
		     , matrix(`suffix')                 ///
		       rownames(rowname) 
	   matrix `suffix'`filenumber' = [`suffix'']
	   matrix drop `suffix'
	}	
*/
	

	matrix DC`filenumber' = [pct`filenumber', ha`filenumber', lt`filenumber', lu`filenumber', labu`filenumber']

	/*  TURNED OFF

	local rownumber2 = 2 + `filenumber'
	local suffix "pct"
	export excel country fdgrz_`suffix'         ///
		     fert_`suffix'                      ///
		     othlvstk_`suffix'                  ///
		     othct_`suffix'                     ///
	 	using  `outdatadir'/simplified.xlsx,   	///
		sheet("slide 15")			            ///
		cell(A`rownumber2')			            ///
		sheetmodify

	    BACK ON  */

	restore	

	local filenumber = `filenumber' + 1 
	
*============================================================================
}



* Clear out any existing matrices to avoid naming conflicts
matrix drop _all
mata: mata clear



capture drop ctry_year
egen ctry_year = concat(country year)

* temporarily save data EXACTLY as it is. Use restore to restore to this state.
preserve


collapse totaluaa uaainowneroccupation renteduaa	///
		 commonageuaa rentrateha ownlandpct 	///
		 ownlandha ownlandval exchangerate	///
		 , by(ctry_year)
		 
gen country = substr(ctry_year,1,3)
gen year 	= substr(ctry_year,4,.)
destring year, replace

mkmat totaluaa uaainowneroccupation renteduaa 	  ///
	  commonageuaa rentrateha ownlandpct	  /// 
	  ownlandha ownlandval if country=="IRE"  ///
	  , matrix(LAND_IE) rownames(year)
	  
mkmat totaluaa uaainowneroccupation renteduaa 	  ///
	  commonageuaa rentrateha ownlandpct 	  ///
	  ownlandha ownlandval if country=="UKI"  ///
	  , matrix(LAND_NI) rownames(year)


matrix define	LANDdiff= LAND_IE - LAND_NI
matrix list 	LANDdiff


*====================================================*
mata

/* NOTE: This is how you comment inside of mata. 
	 You can also use "//" for single line and
	 end of line comments. "*" will not work.	
*/

// make stata matrices available in mata       
IE = st_matrix("LAND_IE")
NI = st_matrix("LAND_NI")



/* - column 2 of IE and NI is uaainowneroccupation
   - column 1 is totaluaa                          
   - the :/ operator does element-wise division as
     opposed to matrix division			
*/
OWN 	= (IE[,2] , NI[,2])
TOTAL 	= (IE[,1] , NI[,1])
PCT 	= OWN :/ TOTAL
PCT = (PCT, PCT[,1]-PCT[,2])



/* NOTE: The mata (PCT,TOTAL,OWN, etc.) will persist
		 even after you leave the mata environment
		 using the end command below. To clear them 
		 out use the following...
mata clear										

at the very bottom of the file (because we display
the matrices again there.)
*/

end 
*====================================================*

* restore data as preserved (i.e. EXACTLY as immediately before collapse)
restore

* Difference matrix of direct costs 
matrix DCdiff = DC1 - DC2
