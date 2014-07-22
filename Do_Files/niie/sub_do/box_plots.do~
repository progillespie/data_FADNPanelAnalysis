/****************************************************
*****************************************************

 Generating Box plots

 Patrick R. Gillespie, Walsh Fellow

   Thesis Supervisors: 

 	Cathal O'Donoghue , REDP Teagasc
	Thia Hennessy	  , REDP Teagasc
	Stephen Hynes	  , NUIG 
	Fiona Thorne 	  , REDP Teagasc

*****************************************************
****************************************************/

local logit_vlist 	= "$logit_vlist_1" 
local panel_vlist 	= "$panel_vlist_1" 
local outdatadir 	= "$outdatadir1" 

/*-----------------------------------------------
 P.Gillespie: 
-----------------------------------------------*/

/********************************
 Create properly labelled country
  var (NI instead of UKI)
********************************/

label define countrycode 1 "IRE" 2 "NI"
encode country, gen(countrycode)
label values countrycode countrycode



/********************************
 Create master list of vars to graph
********************************/

qui foreach var of local logit_vlist {


	local `var'_vlist1 = "$`var'_vlist1"   
	local `var'_vlist2 = "$`var'_vlist2"   


	* Start master regressor vlists
	foreach var2 of local `var'_vlist2 {

		
		di "`var2'"
		local total_vlist2 "`total_vlist2' `var2'"
		local total_vlist2 : list uniq total_vlist2

	}


	foreach var1 in ``var'_vlist1' {


		di "`var1'"
		local total_vlist1 "`total_vlist1' `var1'"
		local total_vlist1 : list uniq total_vlist1


	}


}


qui foreach var of local panel_vlist {


	local `var'_vlist1 = "$`var'_vlist1"   
	local `var'_vlist2 = "$`var'_vlist2"   


	* Complete master regressor vlists
	foreach var2 of local `var'_vlist2 {
		

		di "`var2'"
		local total_vlist2 "`total_vlist2' `var2'"
		local total_vlist2 : list uniq total_vlist2


	}


	foreach var1 in ``var'_vlist1' {


		di "`var1'"
		local total_vlist1 "`total_vlist1' `var1'"
		local total_vlist1 : list uniq total_vlist1


	}


}

* Concatenate dependent var vlists and master regressor vlists
local all_vars "`logit_vlist' `panel_vlist' `total_vlist1' `total_vlist2'"


* Review the lists to ensure expected results
macro list _total_vlist1 _total_vlist2 _all_vars
di _dup(4) _newline "Generating graphs, this will take a long time..."

* Now graph each, don't display, just save to file directly
qui foreach allvar of local all_vars {


	graph box `allvar', by(countrycode) over(ct_grp) noout nodraw /*
	*/ saving(`outdatadir'/box_`allvar', replace) 


}

