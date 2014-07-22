gen ffi_bak = familyfarmincome

gen fadnfarmgo = totaloutput

gen fadnfarmdc = totalspecificcosts

gen fadnfarmoh = 			   ///
	wagespaid                        + /// 
	interestpaid                     + /// 
	rentpaid                         + /// 
	depreciation                     + /// 
	energy                           + /// 
	machininerybuildingcurrentcosts  + /// 
	contractwork                     + /// 
	otherdirectinputs

gen fadnfarmgm =         		   ///
	fadnfarmgo                       - ///
	fadnfarmdc

gen fadndirpayts =                             ///
	subsidiesoninvest                    + ///
	totalsubsidiesexcludingoninvestm     + ///
	paymentstodairyoutgoers         


/* redefine fadnfarmincome with these changes
leave vatoninvest in (i.e. remove that term from eqn)
include totalsubsidiesexcludingoninvestm 
*/

*feedforgrazinglivestock	        - 	///

gen fadnfarmffi =              	        	///
	totaloutput                     -	///
	fdgrzlvstk                      - 	///
	feedforpigspoultry	        - 	///
	otherlivestockspecificcosts     - 	///
	seedsandplants 	                - 	///
	fertilisers                     - 	///
	cropprotection	                - 	///
	othercropspecific               - 	///
	forestryspecificcosts           - 	///
	contractwork                    - 	///
	machininerybuildingcurrentcosts - 	///
	energy                          - 	///
	otherdirectinputs               -	///
	depreciation                    - 	///
	wagespaid                       - 	///
	rentpaid                        -	///
	interestpaid                    +	///
	subsidiesoninvest               +	///
	totalsubsidiesexcludingoninvestm +	///
	paymentstodairyoutgoers         

gen tffi = fadnfarmgo - fadnfarmdc - fadnfarmoh + fadndirpayts

gen df_tffi = fadnfarmffi - tffi

count if df_tffi > 0.05 & df_tffi < . 
drop tffi df_tffi

gen landbuildingscropsquota =              ///
	landpermananentcropsquotas       + ///
	buildings

gen trading =                              ///
	totalcurrentassets               - ///
	machinery                        - ///
	breedinglivestock                - ///
	landbuildingscropsquota

gen netnewinvestment =                     ///
	grossinvestment                  - ///
	subsidiesoninvest

/*  ---------- TURNED OFF ----------------
gen fadnfarmoh = 			   ///
	energy                           + /// 
	wagespaid                        + /// 
	interestpaid                     + /// 
	depreciation                     + /// 
	machininerybuildingcurrentcosts  + /// 
	otherdirectinputs
    ---------- BACK ON ------------------- */






/* Another version I tried. Above works better. 
   Also works better than totalfarmingoverheads 
   by itself. */
/*  ---------- TURNED OFF ----------------
gen fadnfarmoh =                           ///
	totalfarmingoverheads            + ///
	totalexternalfactors             - ///
	contractwork
    ---------- BACK ON ------------------- */


gen currentcash	= 	                   ///
	totalspecificcosts               + ///
	fadnfarmoh                       - ///
	depreciation

gen cashincome =                           ///
	cashflow2                        + ///
	netinvestment

gen netsales =                             ///
	cowsmilkandmilkproducts          + ///
	beefandveal                      + ///
	pigmeat                          + ///
	sheepandgoats                    + ///
	poultrymeat                      + ///
	eggs                             + ///
	ewesandgoatsmilk                 + ///
	otherlivestockandproducts        + ///
	otheroutput

/* Talks with Brian Moran revealed that the years 2005 
    and 2006 were out because of differences in the
    in the treatment of when output is counted 
    (different calendars for NFS and FADN)
*/ 
replace totaloutput =                      ///
	familyfarmincome                 + ///
	fadnfarmoh                       + ///
	totalspecificcosts if year==2005|year==2006

global fin_farm_vlist "totaloutput totalsubsidiesexcludingoninvestm totalspecificcosts fadnfarmgm fadnfarmoh familyfarmincome netsales currentcash cashincome netnewinvestment cashflow2 totalcurrentassets machinery breedinglivestock trading landbuildingscropsquota grossinvestment longandmediumtermloanse"

capture macro drop fin_farm_ha_vlist
global fin_farm_ha_vlist ""
foreach var of global fin_farm_vlist{
	local shortvar = substr("`var'", 1,29)
	capture drop `shortvar'_ha
	global fin_farm_ha_vlist "$fin_farm_ha_vlist `shortvar'_ha"
	/* Since these are farm measures (unallocated) the 
	    appropriate ha is totaluaa, not daforare
	*/
	gen `shortvar'_ha = `var'/totaluaa 
}

/*
gen d_othmiscdc = ddmiscdc - ivmalldy - iaisfdy - itedairy - imiscdry - flabccdy

local d_inp_vlist = "ddconval ddpastur ddwinfor d_othmiscdc ivmalldy iaisfdy itedairy imiscdry flabccdy fdairydc iballdry ibhaydvl ibstrdvl ibsildvl"

local dairydc_vlist = "ddconval ddpastur ddwinfor d_othmiscdc ivmalldy iaisfdy itedairy imiscdry flabccdy"

gen tfdairydc1 = ddconval + ddpastur + ddwinfor + d_othmiscdc + ivmalldy + iaisfdy + itedairy + imiscdry + flabccdy
*/
*preserve
* Use $fin_farm_ha_vlist or $fin_farm_vlist in the collapse statement for scaled or whole farm tables.
collapse (mean) $fin_farm_ha_vlist ///
	[weight=farmsrepresented]  ///
	, by(year)

*restore

