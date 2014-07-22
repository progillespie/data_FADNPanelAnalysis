args arg1 arg2 arg3 ID time weight

***********************************************************
* README
***********************************************************
/* You use this file by writing something like the following

	do pqEffects.do yourprice yourquantity youroutput IDvar timevar weightvar

   on the Stata command line or in another do-file to be
   called by another program. The words after pqEffects.do
   in the line above are not literal... you put the relevant
   varnames from your data in their place.

   The command line arguments arg1 through arg3 are defined
   when you call the do file. (see - help args)

   - You must have a panel dataset open
   - You must have price, quantity, and value (cost or 
      revenue) variables
   - You must have an ID variable
   - You must have a weight variable (if no weights in data
      create a variable that's always = 1 and use that)
   - You must enter these variables in the correct order
   - Defaults: The ID argument defaults to "farmcode", time to 
	"year", and weight defaults to "wt". If all 3 of 
	these defaults suit your data, then you can omit
	the last 3 arguments on the command line. However,
	if you need to change any 1 of these from the defaults
	then you must type in ALL 6 arguments (e.g. if "farmcode"
	and "year" are fine for your data, but you need to
	change "wt", then you still can't leave farmcode and 
	year out of your command because when you get to the 
	weight var the code will assume it's the farmcode 
	variable.) If you want to cut down on typing, you can 
	either rename your variables to match the defaults, or 
	you can edit the code below to make the default values 
	match your variable names. See the section for DEFAULTS.

   CAUTION: If you enter the args in the wrong order you'll get
    the wrong answer (and it may not be apparent in the
    output). 
*/ 
***********************************************************





/*-------------------------------------------------
 If varnames are long, then create a shorter label
  for use when naming new variables (e.g. PE_`arg2label') 
*-------------------------------------------------*/
local test = strlen("`arg1'")
if `test' > 10{
	local arg1label = substr("`arg1'", 1, 4) + "II" +substr("`arg1'",-4, .)
}
else{
	local arg1label = "`arg1'"
}



local test = strlen("`arg2'")
if `test' > 10{
	local arg2label = substr("`arg2'", 1, 4) + "II" +substr("`arg2'",-4, .)
}
else{
	local arg2label = "`arg2'"
}



local test = strlen("`arg3'")
if `test' > 10{
	local arg3label = substr("`arg3'", 1, 4) + "II" +substr("`arg3'",-4, .)
}
else{
	local arg3label = "`arg3'"
}
*-------------------------------------------------

	
	
*-------------------------------------------------
* SET DEFAULT VALUES IF MISSING LAST 3 ARGUMENTS
*-------------------------------------------------

if "`ID'" == "" {
	* Default for ID argument
	local ID "farmcode"
}


if "`time'" == "" {
	* Default for time argument
	local time "year"
}


if "`weight'" == "" {
	* Default for weight argument
	local weight "wt"
}
*-------------------------------------------------



preserve	
collapse `arg1' `arg2' `arg3' [weight=`weight'], by(`time')

recast double `arg1' `arg2' `arg3'  

gen double lag_`arg1label' = `arg1'[_n-1]
gen double lag_`arg2label' = `arg2'[_n-1]
gen double lag_`arg3label' = `arg3'[_n-1]

gen double df_`arg1label' = `arg1' - lag_`arg1label'
gen double df_`arg2label' = `arg2' - lag_`arg2label'
gen double df_`arg3label' = `arg3' - lag_`arg3label'

* Lowercase p for percentage
gen double pdf_`arg1label' 	= (df_`arg1label'/`arg1') * 100
gen double pdf_`arg2label' 	= (df_`arg2label'/`arg2') * 100
gen double pdf_`arg3label' 	= (df_`arg3label'/`arg3') * 100


/* "Pure" Price Eect given by % dference from output with constant
	quantity (changes result from price) */
gen double PE_`arg3label'  = df_`arg1label' * lag_`arg2label' 
gen double pPE_`arg3label' = PE_`arg3label' * 100/`arg3'  //Restating as a %


/* "Pure" Quantity Eect given by % dference from output with constant
	price (changes result from volume) */
gen double QE_`arg3label' = lag_`arg1label' * df_`arg2label' 
gen double pQE_`arg3label' = QE_`arg3label' * 100/`arg3' //Restating as a %


/* "Joint" Price and Quantity Eects given by (change in Q) X (change in P)
	but may also specify as a residual after summing PE and QE. */
gen double JE_`arg3label' = df_`arg3label' - (PE_`arg3label' + QE_`arg3label')
*gen double JE_`arg3label' = df_`arg1label' * df_`arg2label' 
gen double pJE_`arg3label' = JE_`arg3label' * 100/`arg3' //Restating as a %


gen double validate = 	pPE_`arg3label'  +	///
			pQE_`arg3label'  +	///
			pJE_`arg3label'
				

replace validate = pdf_`arg3label' - validate


format 	df_`arg1label'		///
		pdf_`arg3label'	///
		pPE_`arg3label'	///
		pQE_`arg3label'	///
		pJE_`arg3label'	///
		validate	///
		%9.2f


format 	df_`arg2label'		///
		df_`arg3label'	///
		PE_`arg3label' 	///
		QE_`arg3label' 	///
		JE_`arg3label' 	///
		%9.0f
		

tabstat df_`arg1label'	///
		df_`arg2label'	///
		df_`arg3label'	///
		validate	    ///
		df_`arg3label' 	///
		pdf_`arg3label' ///
		pPE_`arg3label'	///
		pQE_`arg3label'	///
		pJE_`arg3label'	///
		if lag_`arg1label' < .	///
		, by(`time') format

capture matrix drop A
mkmat 		df_`arg1label'	///
		df_`arg2label'	///
		df_`arg3label'	///
		validate	    ///
		df_`arg3label' 	///
		pdf_`arg3label' ///
		pPE_`arg3label'	///
		pQE_`arg3label'	///
		pJE_`arg3label'	///
		if lag_`arg1label' < .	///
		, matrix(A) rownames(`time')

		
restore
