*--------------------------------------------------------------------
* Creates overlaid kernel densities for NI, BMW, and SE
*	- year 2008 only
*	- Net margins per litre from -0.10 to 0.30 only
*--------------------------------------------------------------------

* Get varname to plot from command line.
args area code yyyy

* Default values 

if "`yyyy'"=="" {

	local yyyy "==2008"

}

local fortitle "Components of Net Margin (�) (`area', year `yyyy')"

* Bounds on graph
local limvar "fdairygo_ha" // "nm_lt1"
local UL "4000"
local LL "-2000"

*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* Graphing command
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
kdensity fdairygo_ha if                     /// ===== Command ========
           `area' == `code'               & ///
	   year `yyyy'                    & /// First plot (GO)
           `limvar'  < `UL'               & ///
           `limvar'  > `LL'                 ///
    , addplot(kdensity fdairydc_ha if       /// =======Options========
                         `area' == `code' & ///
                         year `yyyy'      & /// 
                         `limvar' < `UL'  & /// Second plot (DC)
                         `limvar' > `LL'    ///
              ||                            /// 
              kdensity fdairyoh_ha if       /// ----------------------
                         `area' == `code' & ///
                         year `yyyy'      & ///
                         `limvar' < `UL'  & /// Third plot (OH)
                         `limvar' > `LL'    ///
              ||                            /// 
              kdensity fdairynm_ha if       /// ---------------------- 
                         `area' == `code' & ///
                         year `yyyy'      & /// Fourth plot (NM)
                         `limvar' < `UL'  & /// 
                         `limvar' > `LL'  ) /// ----------------------          
      legend(bplacement(neast) ring(0)      /// Legend in plot area    
             label(1 "GO")                  /// ----------------------
             label(2 "DC")                  /// Legend labels
             label(3 "OH")                  ///   & suppress
             label(4 "NM")                  ///   legend outline
             region(lcolor(white))   )       /// ----------------------
       plotregion(style(none))              /// no plotregion border
       graphregion(                         /// ----------------------
                   lcolor(white)            /// graphregion border 
                   fcolor(white)            ///  color set to white
                  )                         /// ----------------------
       xscale(range(`LL' `UL'))             /// range at least LL-UL
       xscale(range(`LL' `UL'))             /// range at least LL-UL
       ylabel(,nogrid)                      /// suppress y gridlines
       xlabel(-2000 0 2000 4000)            /// force x labelling
       xtitle("")                           /// suppress x axis title
       title("`fortitle'")                  /// suppress x axis title
       note ("")                            

*/// suppress note
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* End of graphing command
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -





* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - /* Prototype for a fourth plot...  ||                             ///  kdensity `var' if              ///----------------------
                         cntry == 1       &  ///
                         `yyyy' == 2008   &  /// 
                         `limvar'  < `UL' &  /// Fourth plot (IE)
                         `limvar'  > `LL'    ///

AND

             label(4 "IE") )    

Don't forget to remove the last ")" in second to last label! */
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

