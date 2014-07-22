*--------------------------------------------------------------------
* Creates overlaid kernel densities for NI, BMW, and SE
*	- year 2008 only
*	- Net margins per litre from -0.10 to 0.30 only
*--------------------------------------------------------------------

* Get varname to plot from command line.
args var yyyy

* Default values 
if "`var'"=="" {

	local var "nem_labu_adj"

}

if "`yyyy'"=="" {

	local yyyy "2008"

}

local fortitle: variable label `var'
local fortitle "`fortitle' (`yyyy')"

* Bounds on graph
local limvar "`var'" // "nm_lt1"
local UL "40.0001"
local LL "-40.0001"

*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* Graphing command
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
kdensity `var' if                           /// ===== Command ========
           cntr==2                       &  ///
	   year == `yyyy'                &  /// First plot (NI)
           `limvar'  < `UL'              &  ///
           `limvar'  > `LL'                 ///
    , addplot(kdensity `var' if             /// =======Options========
                         bmw == 1        &  ///
                         year == `yyyy'  &  /// 
                         `limvar' < `UL' &  /// Second plot (BMW)
                         `limvar' > `LL'    ///
              ||                            /// 
              kdensity `var' if             /// ----------------------
                         se == 1         &  ///
                         year == `yyyy'  &  /// Third plot (SE)
                         `limvar' < `UL' &  /// 
                         `limvar' > `LL'  ) /// ----------------------          
      scheme(s2mono)                        /// Start from s2mono 
      legend(bplacement(nwest) ring(0)      /// Legend in plot area    
             label(1 "NI")                  /// ----------------------
             label(2 "BMW")                 /// Legend labels & white
             label(3 "SE")                  ///  legend outline
             region(lcolor(white))   )      /// ----------------------
       plotregion(style(none))              /// no plotregion border
       graphregion(                         /// ----------------------
                   lcolor(white)            /// graphregion border 
                   fcolor(white)            ///  color set to white
                  )                         /// ----------------------
       xscale(range(`LL' `UL'))             /// range at least LL-UL
       xlabel(-40 -20 0 20 40)              /// force x labelling
       xtitle("")                           /// suppress x axis title
       ylabel(,nogrid)                      /// suppress y gridlines
       note ("")                            /// suppress note
       title("`fortitle'")                            
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* End of graphing command
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -





* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
/* Prototype for a fourth plot...

              ||                             ///  
              kdensity `var' if              ///----------------------
                         cntry == 1       &  ///
                         `yyyy' == 2008   &  /// 
                         `limvar'  < `UL' &  /// Fourth plot (IE)
                         `limvar'  > `LL'    ///

AND

             label(4 "IE") )    

Don't forget to remove the last ")" in second to last label! */
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

