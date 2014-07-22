*****************************************************
*****************************************************
*
* Derived Variables (for FADN data)
*
* (c) Cathal O'Donoghue (original)
*	edited by
*	Patrick R. Gillespie
* 	Walsh Fellow
*****************************************************
*****************************************************
* the following do file renames FADN variables such 
* that the remainder of this file will run (old NFS
* var names)
*****************************************************




*****************************************************
*****************************************************
* what follows from here are lines directly cut and 
* pasted from the original NFS version of 
* doFarmDerivedVars.do. This will only be a subset of 
* that file, as many NFS variables are simply not 
* available in the FADN.
*****************************************************
*****************************************************
drop if year == .
drop if wt == .

*****************************************************
* Demographics
*****************************************************
gen farm = 1

* generates age bands: <25, 25-35, 35-45, 45-55, 55-65, >66
gen ageoperator = 0
replace ageoperator = 1 if  ogagehld <= 25
replace ageoperator = 2 if  (ogagehld > 25 &  ogagehld <= 35)
replace ageoperator = 3 if  (ogagehld > 35 &  ogagehld <= 45)
replace ageoperator = 4 if  (ogagehld > 45 &  ogagehld <= 55)
replace ageoperator = 5 if  (ogagehld > 55 &  ogagehld <= 65)
replace ageoperator = 6 if ogagehld >= 66

**Age Squared (both the categorical ageoperator and 
* the integer ogagehld)
gen age2 = ageoperator^2
gen ogagehld2 = ogagehld*ogagehld

*! I won't have this
capture drop standardmandays
gen standardmandays = flabsmds

gen stock_rate = ftotallu/fsizuaa
gen stock_rate2 = stock_rate*stock_rate


*****************************************************
* Share by cow type
*****************************************************

gen totcows =  cpavnohc + cpavno06 + cpavno61 + cpavno12 + cpavno2p + cpavnobl + cpavnocw + dpavnohd
local cow_vlist = "cpavnohc cpavno06 cpavno61 cpavno12 cpavno2p cpavnobl cpavnocw dpavnohd"
foreach var in `cow_vlist' {
	gen `var'_sh = `var'/totcows
}

*****************************************************
* Share by sheep type
*****************************************************
local sheep_vlist = "spavnoew spavno12 spavno2p spavnorm spavnlbw spavnool"
foreach var in `sheep_vlist' {
	gen `var'_sh = `var'/spavnots
}
local milk_vlist = "doslcmgl domkfdgl dosllmgl"
gen totmilk = doslcmgl + domkfdgl + dosllmgl
foreach var in `milk_vlist' {
	gen `var'_sh = `var'/totmilk
}

* generated in renameFADN.do
*gen hasreps = fsubreps > 0 & fsubreps != .
*gen isreps = fsubreps > 0 & fsubreps !=.
		
*! might have these... set to 0 for now
gen wave = year - 1982
gen npers04 = oanolt5y
gen npers515 = oano515y
gen npers1519 = oano1619
gen npers2024 = oano2024
gen npers2544 = oano2544
gen npers4564 = oano4564
gen npers65 = oanoge65

*! don't have
*capture gen isofffarmy = oojobhld==1 | oojobhld==2
*capture gen isspofffarmy = oojobsps == 1 | oojobsps == 2

gen fyear = year
sort farmcode fyear

 
/*! 
don't have
by farmcode: replace ooinchld = ooinchld[_n+1]*12 if ooinchld[_n+1] != . & fyear == 2005
by farmcode: replace ooinchld = ooinchld[_n+2]*12 if ooinchld[_n+2] != . & fyear == 2004
replace ooinchld = 0 if ooinchld == .
capture gen isspofffarmy = oojobsps == 1 | oojobsps == 2
by farmcode: replace isspofffarmy = isspofffarmy[_n+1] if isspofffarmy[_n+1] != . & fyear == 2005 & isspofffarmy == .
by farmcode: replace isspofffarmy = isspofffarmy[_n+2] if isspofffarmy[_n+2] != . & fyear == 2004 & isspofffarmy == .
replace isspofffarmy = 0 if isspofffarmy == .

*impute for 2008

sort farmcode year
replace oojobsps = oojobsps[_n-1] if oojobsps == . & oojobsps[_n-1] != .
replace oojobsps = oojobsps[_n+1] if oojobsps == . & oojobsps[_n+1] != .
replace isspofffarmy = oojobsps == 1 | oojobsps == 2


capture gen bothwork = isspofffarmy == 1 & isofffarmy == 1
*/

* generated in renameFADN.do
*capture gen teagasc = foadvfee > 0

capture gen ogagehld10 = int(max(20,min(70,ogagehld))/10)*10
tab ogagehld10, gen(ogagehld10_)

*****************************************************
* System Variable
*****************************************************

* system definitions
* 0 - dairying
* 1 - dairying + other
* 2 - cattle rearing
* 3 - cattle other
* 4 - mainly sheep
* 5 - tillage

*! recreate using FADN system var, note the naming conflict (system is redefined as a
* categorical var here)
* next 5 lines extracts the last digit in the sizesystem variable. This gives the farm system
gen sizesystem = ffszsyst
gen s = sizesystem/10
gen intsys = int(s)
gen t = (s - intsys)*10
gen sys = round(t)
drop s intsys t
gen fffadnsy = system
replace system = 0 
replace system = 0 if sys == 1
replace system = 1 if sys == 2
replace system = 2 if sys == 4
replace system = 3 if sys == 5
replace system = 4 if sys == 6
replace system = 5 if sys == 7

*****************************************************
* Farm Demographics
*****************************************************

gen farmsize = 0
replace farmsize = 1 if fsizuaa < 10
replace farmsize = 2 if fsizuaa >= 10 & fsizuaa < 20
replace farmsize = 3 if fsizuaa > 20 & fsizuaa < 30
replace farmsize = 4 if fsizuaa > 30 & fsizuaa < 50
replace farmsize = 5 if fsizuaa > 50 & fsizuaa < 100
replace farmsize = 6 if fsizuaa >= 100

tab farmsize, gen(farmsize_)

gen fsizuaa2 = fsizuaa*fsizuaa

* can't gen (no man days)
gen total_labour_hours = flabsmds*8

gen  fulltime = 1 if total_labour_hours > 1350
replace  fulltime = 0 if total_labour_hours < 1350
* 1350 is 0.75 labour units whereas 1800 hours worked on the farm is considered to be 1 standard labour unit.
*In the NFS full time farms are defined as farms which require at least 0.75 standard labour units to operate.

*! recreate this using FADN regions
tab system, gen(system)
sort farmcode year
by farmcode: replace region = region[_n-1] if region == . & region[_n-1] != .

* todo sort out issues with COUNTY_CODE pre 1993
*replace region = 1 if (region == 0 | year <= 1994) & (COUNTY_CODE == 7 | COUNTY_CODE == 21 | COUNTY_CODE == 24 | COUNTY_CODE == 25 | COUNTY_CODE == 26 | COUNTY_CODE == 27 | COUNTY_CODE == 34)
*replace region = 2 if (region == 0 | year <= 1994) & (COUNTY_CODE == 2)
*replace region = 3 if (region == 0 | year <= 1994) & (COUNTY_CODE == 3 | COUNTY_CODE == 8 | COUNTY_CODE == 12)
*replace region = 4 if (region == 0 | year <= 1994) & (COUNTY_CODE == 5 | COUNTY_CODE == 6 | COUNTY_CODE == 9 | COUNTY_CODE == 10)
*replace region = 5 if (region == 0 | year <= 1994) & (COUNTY_CODE == 13 | COUNTY_CODE == 16 | COUNTY_CODE == 17)
*replace region = 6 if (region == 0 | year <= 1994) & (COUNTY_CODE == 1 | COUNTY_CODE == 4 | COUNTY_CODE == 11 | COUNTY_CODE == 18 | COUNTY_CODE == 19)
*replace region = 7 if (region == 0 | year <= 1994) & (COUNTY_CODE == 15 | COUNTY_CODE == 14)
*replace region = 8 if (region == 0 | year <= 1994) & (COUNTY_CODE == 20 | COUNTY_CODE == 22 | COUNTY_CODE == 23)

tab region, gen(region)
gen year2 = year*year

/* *!
capture generate soil1=0
replace soil1=1 if ffsolcod<300

capture generate soil2=0
replace soil2=1 if ffsolcod<500
replace soil2=0 if ffsolcod<300

capture generate soil3=0
replace soil3=1 if ffsolcod<700
replace soil3=0 if ffsolcod<500

gen soil = soil1+soil2*2+soil3*3
capture gen soil = int(ffsolcod/100)
*/ *!



*****************************************************
* Subsidies
*****************************************************

*gen dirpayts = fsubhors + fsubtbco + fsubforh + fsubesag + fsubyfig + fsubreps + fsub10tp + fsub22tp + fsubastp + fsubcatp + fsubchtp + fsubeptp + fsubextp + fsubgpcm + fsublitp + fsubmztp + fsubpbtp + fsubrptp + fsubsctp + fsubshtp + fsubsptp + fsubtups + fsubvstp

gen lfa = fsubchen
* Create Residual from Grants and subsidies
gen fgrntsub_resid = max(0,fgrntsub - (fsubesag + fsubreps))
/*! sfp generated in renameFADN.do (directly availabe in FADN)
* Single farm payment
gen sfp = 0
replace sfp = fsubchpp if year >= 2005
*! will have talk with Cathal about SFP (what't rule he's applying here?)
*/
replace fgrntsub_resid = fgrntsub_resid - sfp if year >= 2005
replace fgrntsub_resid = 0 if fgrntsub_resid == .

replace fgrntsub_resid = max(0,fgrntsub_resid - fsubchen)

* Total Subsidies
gen dirpayts = 0

*! can I use subsidiesothercattle?
gen cattle_subs = cssuckcw + cs10mtbf + cs22mtbf + csslaugh + csextens + csheadag + csmctopu
*Cattle Subsidy
replace dirpayts = dirpayts + cattle_subs

/*!aggregated in FADN
*Suckler Welfare
gen suckler_welfare = 0
replace suckler_welfare = cosubsid if year >= 2008
replace dirpayts = dirpayts + suckler_welfare
*/

*! sheepandgoats + othersubs?
*Sheep and Poultry Subsidy
gen sheep_subs = sosubsid + posubsid
replace dirpayts = dirpayts + sheep_subs

/*! then all this would be covered
* Other grants and subsidies 
gen fgrnt_subs = (fsubesag + fsubyfig + fsubreps)
replace dirpayts = dirpayts + fgrntsub_resid + fgrnt_subs
*Cattle Head current year entitlemen(?)
replace dirpayts = dirpayts + lfa 
*/

*SFP
replace dirpayts = dirpayts + sfp 

/*! then all this would be covered
*Other subsidies
gen other_subs = fsubhors + fsubtbco + fsubforh
replace dirpayts = dirpayts  + other_subs 
*/

*! totalsubsidies on crops
*Tillage and Dairy Subsidy
gen tillage_subs = dogpcomp + fsubastp + fsubcatp + fsubrptp + fsubpbtp + fsublitp + fsubmztp+ fsubvstp
replace dirpayts = dirpayts + tillage_subs

*! totalsubsidiesdairying
gen dairy_subs = 0
replace dairy_subs = dairy_subs + dqcomlrd if year >= 2005 
replace dairy_subs = dairy_subs + dosubsvl if year >= 2002 & year < 2005
replace dairy_subs = dairy_subs + dosubsvl if year < 2001

replace dirpayts = dirpayts + dairy_subs 

*! don't have this... thinks it's already covered above anyway
* Cow Protein Payment
*replace dirpayts = dirpayts + fsubsctp if year > 2008

* as we forward simulate from 2004, we need to convert subsidies in 2004 to sfp

replace sfp = cattle_subs + sheep_subs + tillage_subs + dairy_subs if year == 2004
replace sfp = sfp + cattle_subs + sheep_subs + tillage_subs + dairy_subs if year == 2005

/*! FADN is more generic, so I think that we won't be able to do the following adjustments
*2008 change to include suckler cow & protein payments
gen     rdirpaym = cosubsid + sosubsid + posubsid + fgrntsub + fsubhors + fsubtbco + fsubforh + dogpcomp + fsubastp + fsubcatp + fsubrptp + fsubpbtp + fsublitp +fsubmztp + fsubvstp + dqcomlrd + fsubsctp if year >= 2008

*2005 change to include slaughter prem but exclude dairy support payments as already included in sfp
replace rdirpaym = cosubsid + sosubsid + posubsid + fgrntsub + fsubhors + fsubtbco + fsubforh + dogpcomp + fsubastp + fsubcatp + fsubrptp + fsubpbtp + fsublitp +fsubmztp + fsubvstp + dqcomlrd if year >= 2005 & year < 2008

* dosubsvl - as per below - this includes dairy slaughter prem + dairy support payment
*  2002- 2004
replace rdirpaym = cosubsid + sosubsid + posubsid + fgrntsub + fsubhors + fsubtbco + fsubforh + dogpcomp + fsubastp + fsubcatp + fsubrptp + fsubpbtp + fsublitp +fsubmztp + fsubvstp + dosubsvl if year >= 2002 & year < 2005

*2001
replace rdirpaym = cosubsid + sosubsid + posubsid + fgrntsub + fsubhors + fsubtbco + fsubforh + dogpcomp + fsubastp + fsubcatp + fsubrptp + fsubpbtp + fsublitp +fsubmztp + fsubvstp if year == 2001

*<2001
replace rdirpaym = cosubsid + sosubsid + posubsid + fgrntsub + fsubhors + fsubtbco + fsubforh + dogpcomp + fsubastp + fsubcatp + fsubrptp + fsubpbtp + fsublitp +fsubmztp + fsubvstp + dosubsvl if year < 2001




*slaughter_premium_dairy_payment_received_ty_eu
gen slaughter_premium_dy = dogrosso - (dotomkvl+dovalclf+dosubsvl*(year < 2005)+doreplct)
*/

quietly gen marketgo = farmgo - dirpayts
quietly gen marketffi = farmffi - dirpayts




*****************************************************
* Price Adjustment
*****************************************************

/*! presumably this will differ by country... have to work out how to do that

capture gen PLabour = 0
*Employment Regulations Order (Agricultural Workers Joint Labour Committee) 
scalar sc_agewage_1994 = 137.24*52*1.27
scalar sc_agewage_1995 = (137.24*52*1.27 + 9705)/2
scalar sc_agewage_1996 = 9705
scalar sc_agewage_1997 = 10047
scalar sc_agewage_1998 = 10278
scalar sc_agewage_1999 = 10642
scalar sc_agewage_2000 = 11437
scalar sc_agewage_2001 = 12481
scalar sc_agewage_2002 = 13208
scalar sc_agewage_2003 = 13802
scalar sc_agewage_2004 = 14196
scalar sc_agewage_2005 = 15513
scalar sc_agewage_2006 = 16062
scalar sc_agewage_2007 = 17339
scalar sc_agewage_2008 = 345.93*52
scalar sc_agewage_2009 = (354.90+363.87)/2*52
scalar sc_agewage_2010 = (9.33+9.1)/2*52*40
*from FAPRI
scalar sc_agewage_2020 = sc_agewage_2008*1.14

*todo get update

local i = 1994
while `i' <= 2009 {
	replace PLabour = sc_agewage_`i'/sc_agewage_2000*100 if year == `i'
	local i = `i' + 1
}

*/
*************************************************************
*************************************************************
* Land
*************************************************************
*************************************************************


* Land Test - unadjusted

gen tfsizunad = fsizldow + fsizldrt - fsizldlt

* Adjusted

gen tillage_area = wwhcuarq + swhcuarq + wbycuarq + sbycuarq + mbycuarq + wotcuarq + sotcuarq + osrcuarq + pbscuarq + lsdcuarq + potcuarq + sbecuarq

* Hay and Silage are included in pasture


gen mgm_ha = (farmffi - dirpayts)/fsizuaa

sort farmcode year
by farmcode: gen mgm_ha_1 = mgm_ha[_n-1]

gen dirpayts_ha = dirpayts/fsizuaa

**prices

*purchase
gen pricefaprldvl = faprldvl/faprldac 
replace pricefaprldvl = 0 if pricefaprldvl == .
sort year
by year: egen tpricefaprldvl = mean(pricefaprldvl) if pricefaprldvl > 0 & pricefaprldvl < 100000
replace tpricefaprldvl = 0 if tpricefaprldvl == .
by year: egen mpricefaprldvl = max(tpricefaprldvl) 

gen haslandpurch = faprldvl > 0 & faprldvl != .

*sale
gen pricefaslldvl = faslldvl/faslldac
replace pricefaslldvl = 0 if pricefaslldvl == .
by year: egen tpricefaslldvl = mean(pricefaslldvl) if pricefaslldvl > 0 & pricefaslldvl < 100000
replace tpricefaslldvl = 0 if tpricefaslldvl == .
by year: egen mpricefaslldvl = max(tpricefaslldvl) 



*land value
gen landval_ha = favlfrey/fsizuaa
sort year 
by year: egen mn_landval_ha = mean(landval_ha)
qui replace landval_ha = landval_ha/mn_landval_ha

* Statistics
tabstat  mpricefaprldvl mpricefaslldvl landval_ha , by(year) stats(mean)

* Land Owned at start of year

gen fsizldow_1 = fsizldow - faprldac + faslldac


* land sales

gen hasfaslldac = faslldac > 0 & faslldac != .
tab year [weight=wt], sum(hasfaslldac)
tab year if pricefaslldvl < 100000, sum(pricefaslldvl)
*xi: logit  hasfaslldac i.year mgm_ha dirpayts_ha  fsizldow_1 dairy i.system ogagehld ogagehld2  isofffarmy isspofffarmy hasreps soil* landval_ha stock_rate

* land purchase
gen hasfaprldac = faprldac > 0 & faprldac != .

gen landbuysell = hasfaslldac*hasfaprldac == 1
*xi: logit  landbuysell i.year mpricefaprldvl faslldvl* landval_ha mgm_ha dirpayts_ha  fsizldow_1 dairy ogagehld ogagehld2  isofffarmy isspofffarmy hasreps soil* landval_ha stock_rate if hasfaslldac == 1



tab year [weight=wt], sum(hasfaprldac)
tab year if pricefaprldvl < 100000, sum(pricefaprldvl)
*xi: logit   hasfaprldac i.year mgm_ha dirpayts_ha  fsizldow_1 dairy i.system ogagehld ogagehld2  isofffarmy isspofffarmy hasreps soil* landval_ha stock_rate if landbuysell == 0

* Land value (t-1)

gen landvalue_ha_1 = favlfrby/fsizldow_1

* Land value (t)

gen landvalue_ha = favlfrey/fsizldow


* Land Rented
gen hasfsizldrt = fsizldrt > 0 & fsizldrt != .
*xi: logit  hasfsizldrt soil2 soil3 region2-region8 year year2   mpricefaprldvl mpricefaslldvl landval_ha mgm_ha dirpayts_ha  fsizldow_1 dairy i.system ogagehld ogagehld2  isofffarmy isspofffarmy hasreps soil* landval_ha stock_rate 

* price per ha
gen lease_price_ha = forntcon/fsizldrt
*! this regression is nonsense until we sort out the variables in it (doesn't even run at the moment)
*regress lease_price_ha soil2 soil3 region2-region8 year year2  if fsizldrt > 0

tab year soil [weight=wt], sum(lease_price_ha) nost nofreq noobs
tab year soil [weight=wt], sum(fsizldrt) nost nofreq noobs

* Land Let
gen hasfsizldlt = fsizldlt > 0 & fsizldlt != .
*xi: logit  hasfsizldlt soil2 soil3 region2-region8 year year2  mpricefaprldvl mpricefaslldvl landval_ha mgm_ha dirpayts_ha  fsizldow_1 dairy i.system ogagehld ogagehld2  isofffarmy isspofffarmy hasreps soil* landval_ha stock_rate 

*fsizunad = fsizldow + fsizldrt - fsizldlt

*************************************************************
* Land Use
*************************************************************

* Tillage Area

capture drop tillage_area 

gen tillage_area = wwhcuarq + swhcuarq + wbycuarq + sbycuarq + mbycuarq + wotcuarq + sotcuarq + osrcuarq + pbscuarq + lsdcuarq + potcuarq + sbecuarq

* forestry?

* Forage Area
gen forage_area = daforare + cpforacs + spforacs + hpforacs
gen forage_area2 = forage_area*forage_area

gen hasmilk = daforare > 0 & daforare != .
gen hascattle = cpforacs > 0 & cpforacs != .
gen hassheep = spforacs > 0 & spforacs != .
gen hashorses = hpforacs > 0 & hpforacs != .


tabstat fsizfrac forage_area daforare cpforacs spforacs hpforacs [weight=wt], by(year) stats(mean)

gen tfsizeadj = forage_area + tillage_area + fsizfort

tabstat fsizeadj tfsizeadj tillage_area forage_area [weight=wt], by(year) stats(mean)

* Other Area
gen other_area = fsizeadj - tfsizeadj


* Land Use Shares

gen tillage_sh = tillage_area/fsizeadj
gen forage_sh = forage_area/fsizeadj
gen other_sh = other_area/fsizeadj
*gen hasforestry = fsizfort > 0 & fsizfort != .
sort farmcode year
by farmcode: replace hasforestry = region[_n-1] if region == . & region[_n-1] != .
gen forestry_sh = fsizfort/fsizeadj

local livest_vlist = "daforare cpforacs spforacs hpforacs"
foreach var in `livest_vlist' {
	gen `var'_sh = `var'/forage_area
	gen has`var' = `var' > 0 & `var' != .
}

* cropsgm_ha
gen cropsgm_ha = fcropsgm/tillage_area
gen livestockgm_ha = flivstgm/forage_area



sort farmcode year
by farmcode: gen cropsgm_ha_1 = cropsgm_ha[_n-1]
by farmcode: gen livestockgm_ha_1 = livestockgm_ha[_n-1]

gen till_lv_ratio = cropsgm_ha_1/livestockgm_ha_1
gen istillage = tillage_area > 0 & tillage_area != .
sort farmcode
by farmcode: egen evertillage = max(istillage)

sort farmcode year
by farmcode year: egen rnk=rank(year), unique
keep if rnk == 1
drop rnk
tsset farmcode year

*regress tillage_sh soil2 soil3 region1-region7 year year2 if evertillage == 1
*regress forage_sh soil2 soil3 region2-region8 year year2 if forage_area > 0


* Derived Variables


*************************************************************
*************************************************************
* Milk
*************************************************************
*************************************************************


* Milk Sales
gen tdotomkvl = doslcmvl + domlkbon - domlkpen + dosllmvl + domkfdvl + domkalvl if year > 1995
replace tdotomkvl = doslmkvl + domkfdvl + domkalvl if year <= 1995 

*Price milk sold to creamery
gen p_doslcm = doslcmvl/doslcmgl

*Price liquid milk

* Missing liquid milk volume after 2000
* todo why is this the case
replace dosllmgl = doslmkgl - doslcmgl if dosllmvl > 0 & year >= 2001 & (dosllmgl == 0)
gen p_dosllm = dosllmvl/dosllmgl

*Price milk fed
gen p_domkfd = domkfdvl/domkfdgl

*average price
gen p_doslmkvl = doslmkvl/doslmkgl

*set missing to zero
mvencode p_do*, mv(0) override

gen tdotomkvl1 = doslcmvl + domlkbon - domlkpen + dosllmvl + domkfdvl + domkalvl if year > 1995
replace tdotomkvl1 = doslmkvl + domkfdvl + domkalvl if year <= 1995 


gen hasliquidmilk = dosllmgl > 0 & dosllmgl != .
gen hasdomkfdgl = domkfdgl > 0 & domkfdgl != .
gen hasdomlkbon = domlkbon > 0
gen hasdomlkpen = domlkpen > 0
gen hasdomkalvl = domkalvl > 0


gen tdotomkvl2 = p_doslcm*doslcmgl + domlkbon - domlkpen + p_dosllm*dosllmgl + p_domkfd*domkfdgl + domkalvl if year > 1995

replace tdotomkvl2 = p_doslmkvl*doslmkgl + p_domkfd*domkfdgl + domkalvl if year <= 1995 

* per lu
local dairy_go_vlist = "doslcmgl domlkbon domlkpen dosllmgl domkfdgl domkalvl doslmkgl"
foreach var in `dairy_go_vlist' {
	gen `var'_lu = `var'/dpnolu
}

gen milk_lu = doslcmgl_lu + dosllmgl_lu + domkfdgl_lu
gen dpnolu_ha = dpnolu/daforare
capture gen daforare_sh = daforare/fsizeadj

gen tdotomkvl3 = fsizeadj*daforare_sh*dpnolu_ha*(p_doslcm*doslcmgl_lu + domlkbon_lu - domlkpen_lu + p_dosllm*dosllmgl_lu + p_domkfd*domkfdgl_lu + domkalvl_lu) if year > 1995

replace tdotomkvl3 = fsizeadj*daforare_sh*dpnolu_ha*(p_doslmkvl*doslmkgl_lu + p_domkfd*domkfdgl_lu + domkalvl_lu) if year <= 1995 

*tabstat *dotomkvl* p_doslcm doslcmvl doslcmgl domlkbon domlkpen  p_dosllm dosllmvl dosllmgl domkfdv p_domkfd domkfdvl domkfdgl domkalvl if dotomkvl > 0 [weight = wt],by(year) stats(mean)


** Replacement Cost

*doschbvl - price - needs to be before others as we do not know the number of sales for missing values
gen p_doschbvl = doschbvl/doschbno

* Correct sales of dairy cattle variable
replace doschbvl = doschbvl + dosldhrd - docfslvl - doschbvl if (doschbvl == 0 | year == 2009) & dosldhrd - docfslvl > 0 & dosldhrd - docfslvl != .  
replace doschbno = doschbno + dosldhrd - docfslno if doschbvl == 0 & dosldhrd - docfslvl > 0 & dosldhrd - docfslvl != .

* prices
*dotochbv
gen p_dotochbv = dotochbv/dotochbn
*dopchbvl
gen p_dopchbvl = dopchbvl/dopchbno
*dotichbv
gen p_dotichbv = dotichbv/dotichbn

*set missing to zero
mvencode p_doschbvl p_dotochbv p_dopchbvl p_dotichbv, mv(0) override

*dovlcnod
*todo find this out

* Other sales and purchases not in data
gen do_othersales = dosldhrd - doschbvl - docfslvl
gen do_otherpurchase = doprdhrd - dopchbvl

gen tdoreplct1 = doschbvl + dotochbv - (dopchbvl + dotichbv) + dovlcnod
gen tdoreplct2 = doschbvl + p_dotochbv*dotochbn - (p_dopchbvl*dopchbno + p_dotichbv*dotichbn) + dovlcnod

*tabstat p_doschbvl doschbvl dotochbv do_otherpurchase dopchbvl dotichbv dovlcnod tdoreplct* doreplct p_dotochbv dotochbn p_dopchbvl dopchbno p_dotichbv dotichbn if dotomkvl > 0 [weight = wt],by(year) stats(mean)

** Value of dropped calves (sold+trans


* Price
gen p_docftfvl = docftfvl/docftfno
gen p_docfslvl = docfslvl/docfslno
*set missing to zero
mvencode p_do*, mv(0) override

gen tdovalclf1 = docftfvl + docfslvl
gen tdovalclf2 = p_docftfvl*docftfno + p_docfslvl*docfslno

*tabstat *dovalclf* p_docftfvl p_docfslvl docftfno docfslno docftfvl docfslvl if dotomkvl > 0 [weight = wt],by(year) stats(mean)


*check 
*tabstat p_doslcm doslcmvl doslcmgl p_dosllm dosllmvl dosllmgl p_doslcm domkfdvl domkfdgl if dotomkvl > 0 [weight = wt],by(year) stats(mean)

gen tfdairygo = dotomkvl + dovalclf + doreplct
gen tfdairygo2 = tdotomkvl2 + tdovalclf2 + tdoreplct2
gen tfdairygo3 = dpnolu*(p_doslcm*doslcmgl_lu + domlkbon_lu - domlkpen_lu + p_dosllm*dosllmgl_lu + p_domkfd*domkfdgl_lu + domkalvl_lu) + p_docftfvl*docftfno + p_docfslvl*docfslno + doschbvl + p_dotochbv*dotochbn - (p_dopchbvl*dopchbno + p_dotichbv*dotichbn) + dovlcnod if year > 1995
replace tfdairygo3 = dpnolu*(p_doslmkvl*doslmkgl_lu + p_domkfd*domkfdgl_lu + domkalvl_lu) + p_docftfvl*docftfno + p_docfslvl*docfslno + doschbvl + p_dotochbv*dotochbn - (p_dopchbvl*dopchbno + p_dotichbv*dotichbn) + dovlcnod if year <= 1995
*tabstat fdairygo tfdairygo* dotomkvl tdotomkvl2 dovalclf tdovalclf2 doreplct tdoreplct* if dotomkvl > 0 [weight = wt],by(year) stats(mean)

* Direct Costs

* Dairy
gen d_othmiscdc = ddmiscdc - ivmalldy - iaisfdy - itedairy - imiscdry - flabccdy

local d_inp_vlist = "ddconval ddpastur ddwinfor d_othmiscdc ivmalldy iaisfdy itedairy imiscdry flabccdy fdairydc iballdry ibhaydvl ibstrdvl ibsildvl"

local dairydc_vlist = "ddconval ddpastur ddwinfor d_othmiscdc ivmalldy iaisfdy itedairy imiscdry flabccdy"

gen tfdairydc1 = ddconval + ddpastur + ddwinfor + d_othmiscdc + ivmalldy + iaisfdy + itedairy + imiscdry + flabccdy

* doslmkgl_lu dosllmgl_lu domkfdgl_lu domlkbon_lu domlkpen_lu domkalvl_lu
* Quantity

local var = "ddconval"
gen p_`var' = PCattleFeed/100
gen `var'q = `var'/(p_`var')

local var = "ddpastur"
gen p_`var' = PTotalFert/100
gen `var'q = `var'/(p_`var')


local var = "ddwinfor"
gen p_`var' = PTotalFert/100
gen `var'q = `var'/(p_`var')

local var = "ivmalldy"
gen p_`var' = PVetExp/100
gen `var'q = `var'/(p_`var')

local var = "iaisfdy"
gen p_`var' = PVetExp/100
gen `var'q = `var'/(p_`var')

local var = "itedairy"
gen p_`var' = PMotorFuels/100
gen `var'q = `var'/(p_`var')

local var = "imiscdry"
gen p_`var' = POtherInputs/100
gen `var'q = `var'/(p_`var')

local var = "flabccdy"
gen p_`var' = PLabour/100
gen `var'q = `var'/(p_`var')

local var = "d_othmiscdc"
gen p_`var' = POtherInputs/100
gen `var'q = `var'/(p_`var')



foreach var in `dairydc_vlist' {
	gen `var'q_lu = `var'q/dpnolu
	gen `var'q_lt = `var'q/(daforare*dpnolu_ha*milk_lu)
	gen `var'q_lu_df = `var'q_lu/p_`var'
	*regress `var'q_lu_df p_`var' region2-region8 soil2 soil3 teagasc if daforare > 0
	
}

capture drop tfdairydc1
gen tfdairydc1 = ddconval + ddpastur + ddwinfor + d_othmiscdc + ivmalldy + iaisfdy + itedairy + imiscdry + flabccdy
gen tfdairydc2 = dpnolu*(ddconvalq_lu*(PCattleFeed/100)  + ddpasturq_lu*(PTotalFert/100)  + ddwinforq_lu*(PTotalFert/100)  + d_othmiscdcq_lu*(POtherInputs/100) + ivmalldyq_lu*(PVetExp/100) + iaisfdyq_lu*(PVetExp/100) + itedairyq_lu*(PMotorFuels/100) + imiscdryq_lu*(POtherInputs/100) + flabccdyq_lu*(PLabour/100))

*todo separate liquid milk and other milk
gen tfdairydc3 = daforare*dpnolu_ha*milk_lu*(ddconvalq_lt*p_ddconval  + ddpasturq_lt*p_ddpastur  + ddwinforq_lt*p_ddwinfor  + d_othmiscdcq_lt*p_d_othmiscdc + ivmalldyq_lt*p_ivmalldy + iaisfdyq_lt*p_iaisfdy + itedairyq_lt*p_itedairy + imiscdryq_lt*p_imiscdry + flabccdyq_lt*p_flabccdy)

*todo equations

*************************************************************
*************************************************************
* Cattle
*************************************************************
*************************************************************

* Gross Output

*cpagecat cpseaprd cptyrear cpbreed cpsex cpbred1c cpbred1p cpbred2c cpbred2p cpbred3c cpbred3p cpnolu cptotcno cpavnocw cpavnohc cpavno06 cpavno61 cpavno12 cpavno2p cpavn12m cpavn12f cpavn2pm cpavn2pf cpavnobl cpdthcow cpdthclf cpdthbir cpdthc6m cpopinvc cpclinvc cpopinvb cpclinvb cpopinvt cpclinvt cpforacs cpfedacs cpconckg cogrosso cosalesv copurval cotftdvl cotffdvl cotftdno cotffdno copurcno cosalcno covalcno cosltotn cosltotv cosalcvl cosubsid coprcfno coprcfvl coslcfno coslcfvl coprwnno coprwnvl coslwnno coslwnvl coprstno coprstvl coslstno coslstvl coprmsno coprmsvl coprfsno coprfsvl coslmsno coslmsvl coslfsno coslfsvl coslfcno coslfcvl coslmfno coslfmvl coslffno coslffvl coprbhno coprbhvl coslbhno coslbhvl coprocno coprocvl coslocno coslocvl coserrec coocidno coocidvl cdconcen cdpastur cdwinfor cdmilsub cdtotfed cdmiscdc cdtotldc cdgrsmar cssuckcw cs10mtbf cs22mtbf csslaugh csextens csheadag csmctopu cqscqopn cqscqgfg cqscqgfr cqscqcls cqscqtot cqpurqsc cqsalqsc cqlsoqsc cqlsiqsc cqscpqav

* Has Suckler Cattle

gen suckler = cpavnocw + cpavno06*(cpavno06 > 0 & cpavno06) > 0
tab year if cpforacs > 0 [weight=wt], sum(suckler)

* Test Number of cattle

gen tcptotcno1 = dpavnohd + cpavnocw + cpavnohc + cpavno06 + cpavno61 + cpavno12 + cpavno2p + cpavnobl
gen tcptotcno2 = dpavnohd + cpavnocw + cpavnohc + cpavno06 + cpavno61 + cpavn12m + cpavn12f + cpavn2pm + cpavn2pf  + cpavnobl

tabstat *cptotcno* if cpforacs > 0 [weight=wt], by(year) stats(mean)

* GO

gen tcogrosso1 = cosalesv - copurval + covalcno + cosubsid - cotffdvl + cotftdvl


gen tcogrosso2 = coslcfvl + coslwnvl + coslstvl + coslfcvl + coslbhvl + coslocvl - (coprcfvl + coprwnvl + coprstvl + coprbhvl + coprocvl) + covalcno + cosubsid - cotffdvl + cotftdvl

* Get Prices

* inconsitency in naming
rename coslmfno coslfmno
*covalcno

capture gen covalcno_ha = covalcno/cpforacs

local cattle_vlist = "coslcf coslwn coslst coslfc coslbh cosloc coprcf coprwn coprst coprbh coproc cotftd cotffd coslms coslfs coprms coprfs coslfm coslff "
sort year 
foreach var in `cattle_vlist' {
	gen p_`var' = `var'vl/`var'no if `var'no > 0
	gen `var'no_ha = `var'no/cpforacs

	*regress `var'no_ha p_`var' region2-region8 soil2 soil3 teagasc year year2 if cpforacs > 0
	replace p_`var' = 0 if p_`var' == .
	by year: egen tmp_`var' = mean(p_`var') if p_`var' > 0 & p_`var' != .
	capture replace tmp_`var' = 0 if tmp_`var' == .
	by year: egen mp_`var' = max(tmp_`var') 
	drop tmp_`var'
}


gen tcogrosso3 = p_coslcf*coslcfno_ha*cpforacs + p_coslwn*coslwnno_ha*cpforacs + p_coslst*coslstno_ha*cpforacs                                + p_coslfc*coslfcno_ha*cpforacs + 				   p_coslbh*coslbhno_ha*cpforacs + p_cosloc*coslocno_ha*cpforacs - (p_coprcf*coprcfno_ha*cpforacs + p_coprwn*coprwnno_ha*cpforacs + p_coprst*coprstno_ha*cpforacs + 				      p_coprbh*coprbhno_ha*cpforacs + p_coproc*coprocno_ha*cpforacs) + covalcno + cosubsid - p_cotffd*cotffdno_ha*cpforacs + p_cotftd*cotftdno_ha*cpforacs
gen tcogrosso4 = (p_coslcf*coslcfno_ha + p_coslwn*coslwnno_ha + p_coslms*coslmsno_ha + p_coslfs*coslfsno_ha + p_coslfm*coslfmno_ha + p_coslff*coslffno_ha + p_coslbh*coslbhno_ha + p_cosloc*coslocno_ha - (p_coprcf*coprcfno_ha + p_coprwn*coprwnno_ha + p_coprms*coprmsno_ha + p_coprfs*coprfsno_ha + p_coprbh*coprbhno_ha + p_coproc*coprocno_ha)*cpforacs - p_cotffd*cotffdno_ha*cpforacs + p_cotftd*cotftdno_ha + covalcno_ha)*cpforacs + cosubsid 



*test
tabstat *cogrosso* if cpforacs > 0 [weight=wt], by(year) stats(mean)

tabstat tcogrosso4 tcogrosso3 p_coslcf coslcfno_ha p_coslwn coslwnno_ha  p_coslst coslstno_ha  p_coslms coslmsno_ha  p_coslfs coslfsno_ha  p_coslfc coslfcno_ha p_coslfm coslfmno_ha  p_coslff coslffno_ha  p_coslbh coslbhno_ha  p_cosloc coslocno_ha  p_coprcf coprcfno_ha  p_coprwn coprwnno_ha  p_coprms coprmsno_ha  p_coprfs coprfsno_ha  p_coprbh coprbhno_ha  p_coproc coprocno_ha  covalcno cosubsid p_cotffd cotffdno_ha  p_cotftd cotftdno_ha cpforacs if cpforacs > 0 [weight=wt], by(year) stats(mean)

tabstat mp* if cpforacs > 0 [weight=wt], by(year) stats(mean)

gen dpavnohd_ha = dpavnohd/daforare

* Direct Cost

* Cattle
gen co_othmiscdc = cdmiscdc - ivmallc - iaisfcat - itecattl - imiscctl - flabccct

local co_inp_vlist = "cdconcen cdpastur cdwinfor cdmilsub ivmallc iaisfcat itecattl imiscctl flabccct co_othmiscdc cdtotldc fcatledc iballctl ibhaycvl ibstrcvl ibsilcvl"

gen tfcatledc1 = cdconcen + cdpastur + cdwinfor + cdmilsub + ivmallc + iaisfcat + itecattl + imiscctl + flabccct + co_othmiscdc


local cattledc_vlist = "cdconcen cdpastur cdwinfor cdmilsub ivmallc iaisfcat itecattl imiscctl flabccct co_othmiscdc"
* Quantity


local var = "cdconcen"
gen p_`var' = PCattleFeed/100
gen `var'q = `var'/(p_`var')


local var = "cdpastur"
gen p_`var' = PTotalFert/100
gen `var'q = `var'/(p_`var')


local var = "cdwinfor"
gen p_`var' = PTotalFert/100
gen `var'q = `var'/(p_`var')

local var = "cdmilsub"
gen p_`var' = PCalfFeed/100
gen `var'q = `var'/(p_`var')

local var = "ivmallc"
gen p_`var' = PVetExp/100
gen `var'q = `var'/(p_`var')

local var = "iaisfcat"
gen p_`var' = PVetExp/100
gen `var'q = `var'/(p_`var')

local var = "itecattl"
gen p_`var' = PMotorFuels/100
gen `var'q = `var'/(p_`var')

local var = "imiscctl"
gen p_`var' = POtherInputs/100
gen `var'q = `var'/(p_`var')

local var = "flabccct"
gen p_`var' = PLabour/100
gen `var'q = `var'/(p_`var')

local var = "co_othmiscdc"
gen p_`var' = POtherInputs/100
gen `var'q = `var'/(p_`var')


foreach var in `cattledc_vlist' {
	gen `var'q_lu = `var'q/cpnolu
	gen `var'q_lu_df = `var'q_lu/p_`var'
	*regress `var'q_lu_df p_`var' region2-region8 soil2 soil3 teagasc if cpforacs > 0
	
}

gen cpnolu_ha = cpnolu/cpforacs
gen tfcatledc2 = cpforacs*cpnolu_ha*(cdconcenq_lu*p_cdconcen + cdpasturq_lu*p_cdpastur + cdwinforq_lu*p_cdwinfor + cdmilsubq_lu*p_cdmilsub + ivmallcq_lu*p_ivmallc + iaisfcatq_lu*p_iaisfcat + itecattlq_lu*p_itecattl + imiscctlq_lu*p_imiscctl + flabccctq_lu*p_flabccct + co_othmiscdcq_lu*p_co_othmiscdc)

*tabstat tfcatledc* fcatledc if cpforacs > 0 [weight=wt], by(year) stats(mean)


*************************************************************
*************************************************************
* Sheep
*************************************************************
*************************************************************
*spclass spbreede spbreedr sphillow spnolu spavnoew spavno12 spavno2p spavnorm spavnlbw spavnool spavnots spnoewer spnobnew spnoewlr spewmhor spinlenp spprilen spslinen spprelfn spslelfn spprlafn spsllafn spnoewnr splambir splamdth spewedth spnofls1 spshorn spopinvs spclinvs spopinvb spclinvb spopinvt spclinvt spopinvw spclinvw spqcnfed spforacs spfedacs sogrosso sosaleso sopurso sosalean soslflvl soslflno soslslvl soslslno soprslvl soprslno soprbdvl soprbdno soslbdvl soslbdno soslhgno soslhgvl soslwlvl soslwllb sowoollb sowoolvl soprerno soprervl soprbhno soprbhvl soslbhno soslbhvl soslerno soslervl soslbeno soslbevl soconhno soconhvl sowlsylb sovalcno sosubsid sosubhdg sosubprm sdconval sdwinfor sdroots sdpastur sdtotfed sdother sdtotldc sdgrsmar sqopenqt sqpurch sqsales sqpurqav sqlsdout sqlsdin sqgiftgv sqgftrec sqclosqt sqtotaly

* Gross Output

*Sales

* Correct for Euro problem in 1999 and 2000
replace sosalean = sosalean*1.27 if year >= 1999 & year <= 2000

* todo why do we have to make the following change to hoggets?
replace soslhgvl = soslhgvl/1.27 if year < 1999

*price
local sheep_vlist = "soslfl soslsl soslhg soslbh sosler soslbe soconh soprsl soprbd"

sort year
foreach var in `sheep_vlist' {
	gen p_`var' = `var'vl/`var'no
	gen `var'no_ha = `var'no/spforacs

	*regress `var'no_ha p_`var' region2-region8 soil2 soil3 teagasc year year2 if spforacs > 0
	replace p_`var' = 0 if p_`var' == .
	by year: egen tmp_`var' = mean(p_`var') if p_`var' > 0 & p_`var' != .
	capture replace tmp_`var' = 0 if tmp_`var' == .
	by year: egen mp_`var' = max(tmp_`var') 
	drop tmp_`var'
	
}

* todo why do we have to make the following change to hoggets?
gen tsosaleso = sosalean + soconhvl
gen tsosaleso1 = soslflvl + soslslvl + soslhgvl + soslbhvl + soslervl + soslbevl + soconhvl 
gen tsosaleso2 = spforacs*(p_soslfl*soslflno_ha + p_soslsl*soslslno_ha + p_soslhg*soslhgno_ha + p_soslbh*soslbhno_ha + p_sosler*soslerno_ha + p_soslbe*soslbeno_ha + p_soconh*soconhno_ha)

tabstat *sosaleso*  sosalean soconhvl if spforacs > 0 [weight=wt], by(year) stats(mean)

* todo where are wool sales?

* Purchases
gen tsopurso = soprslvl + soprbdvl 
gen tsopurso1 = spforacs*(p_soprsl*soprslno_ha + p_soprbd*soprbdno_ha)

tabstat *sopurso*  if spforacs > 0 [weight=wt], by(year) stats(mean)


* Sheep
gen s_othmiscdc = sdother - ivmallsp - iaisfshp - itesheep - imiscshp - flabccsh

local s_inp_vlist = "sdconval sdwinfor sdroots sdpastur s_othmiscdc ivmallsp iaisfshp itesheep imiscshp flabccsh sdtotldc fsheepdc iballshp ibhaysvl ibstrsvl ibsilsvl"

gen tfsheepdc1 = sdconval + sdwinfor + sdroots + sdpastur + s_othmiscdc + ivmallsp + iaisfshp + itesheep + imiscshp + flabccsh


local sheepdc_vlist = "sdconval sdwinfor sdroots sdpastur s_othmiscdc ivmallsp iaisfshp itesheep imiscshp flabccsh"
* Quantity

local var = "sdconval"
gen p_`var' = PCattleFeed/100
gen `var'q = `var'/(p_`var')


local var = "sdpastur"
gen p_`var' = PTotalFert/100
gen `var'q = `var'/(p_`var')


local var = "sdwinfor"
gen p_`var' = PTotalFert/100
gen `var'q = `var'/(p_`var')

local var = "sdroots"
gen p_`var' = PCattleFeed/100
gen `var'q = `var'/(p_`var')

local var = "ivmallsp"
gen p_`var' = PVetExp/100
gen `var'q = `var'/(p_`var')

local var = "iaisfshp"
gen p_`var' = PVetExp/100
gen `var'q = `var'/(p_`var')

local var = "itesheep"
gen p_`var' = PMotorFuels/100
gen `var'q = `var'/(p_`var')

local var = "imiscshp"
gen p_`var' = POtherInputs/100
gen `var'q = `var'/(p_`var')

local var = "flabccsh"
gen p_`var' = PLabour/100
gen `var'q = `var'/(p_`var')

local var = "s_othmiscdc"
gen p_`var' = POtherInputs/100
gen `var'q = `var'/(p_`var')

foreach var in `sheepdc_vlist' {
	gen `var'q_lu = `var'q/spnolu
	gen `var'q_lu_df = `var'q_lu/p_`var'
	*regress `var'q_lu_df p_`var' region2-region8 soil2 soil3 teagasc if spforacs > 0
	
}

gen tfsheepdc2 = spnolu*(sdconvalq_lu*p_sdconval + sdpasturq_lu*p_sdpastur + sdwinforq_lu*p_sdwinfor + sdrootsq_lu*p_sdroots + ivmallspq_lu*p_ivmallsp + iaisfshpq_lu*p_iaisfshp + itesheepq_lu*p_itesheep + imiscshpq_lu*p_imiscshp + flabccshq_lu*p_flabccsh + s_othmiscdcq_lu*p_s_othmiscdc)

tabstat *fsheepdc* if spforacs > 0 [weight=wt], by(year) stats(mean)


*************************************************************
*************************************************************
* Crops
*************************************************************
*************************************************************
*local crop_vlist = "wwh swh wby sby mby wot sot osr pbs lsd pot sbe"
local crop_vlist = "wwh swh wby sby mby pot sbe"

iis farmcode

gen other_cropgo = fcropsgo - tillage_subs
foreach var in `crop_vlist' {
	gen `var'_ha =  `var'cuclq + `var'cuwtq + `var'cualq + `var'cusdq + `var'cufdq + `var'cuslq
	
	* Convert to Ha
	local perha_vlist = "cuylq cusdq cuslq cufdq cuclq cufnq cufpq cufkq cucpv cumhv cucwv cumcv cusev"

	foreach var1 in `perha_vlist' {
		gen `var'`var1'_ha = `var'`var1'/`var'cuarq
	}

	* Convert to Shares
	local sh_vlist = "cusd cusl cufd cucl cual cuwt"
	sort year
	foreach var1 in `sh_vlist' {
		* share
		gen `var'`var1'q_sh = `var'`var1'q/`var'cuylq
		* price
		capture gen p_`var'`var1' = `var'`var1'v/`var'`var1'q
		capture gen p_`var'`var1' = 0
		tab year if p_`var'`var1' > 0 [weight=wt], sum(p_`var'`var1')
*		gen `var'`var1'q_ha = `var'`var1'q/`var'`var'cuarq

		by year: egen tmp_`var'`var1' = mean(p_`var'`var1') if p_`var'`var1' > 0 & p_`var'`var1' != .
		capture replace tmp_`var'`var1' = 0 if tmp_`var'`var1' == .
		by year: egen mp_`var'`var1' = max(tmp_`var'`var1') 
		drop tmp_`var'`var1'
	}
	
	gen `var'cuylq2 = `var'cuylq*`var'cuylq

	gen p_`var'opop = `var'opopv/`var'opopq

	gen p_`var'opsl = `var'opslv/`var'opslq
	gen p_`var'opfd = `var'opfdv/`var'opfdq
	gen p_`var'opsd = `var'opsdv/`var'opsdq
	gen p_`var'opcl = `var'opclv/`var'opclq

	mvencode p_`var'* `var'*_ha, mv(0) override

	gen `var'_go = `var'cugov + `var'opgov
	replace other_cropgo = max(0, other_cropgo - `var'_go)


	* Test Gross Output

	gen t`var'_go1 = `var'cuslv + `var'cufdv + `var'cusdv + `var'cuclv


	gen t`var'_go2 = (`var'cuslq_ha*p_`var'cusl + `var'cufdq_ha*p_`var'cufd + `var'cusdq_ha*p_`var'cusd + `var'cuclq_ha*p_`var'cucl)*`var'cuarq




	gen `var'_specialisation = `var'_go/(fcropsgo - tillage_subs)

	* Yield Equation	
	*gen ln`var'cuylq_ha = ln(`var'cuylq_ha)
	*xtreg `var'cuylq_ha `var'_specialisation `var'cuylq `var'cuylq2  region2-region8 soil2 soil3 teagasc year year2 `var'cufnq_ha `var'cufpq_ha `var'cufkq_ha `var'cucpv_ha `var'cusev_ha `var'cumhv_ha-`var'cumcv_ha ogagehld2 isofffarmy if `var'cuylq_ha > 0,re
	*regress `var'cuylq_ha `var'_specialisation `var'cuylq `var'cuylq2  region2-region8 soil2 soil3 teagasc year year2 `var'cufnq_ha `var'cufpq_ha `var'cufkq_ha `var'cucpv_ha `var'cusev_ha `var'cumhv_ha-`var'cumcv_ha ogagehld2 isofffarmy if `var'cuylq_ha > 0

	* Feed Equation
	*gen ln`var'feed = ln(`var'cufdq + `var'opfdq)
	*xtreg ln`var'feed ftotallu `var'cuylq `var'cuylq2  region2-region8 soil2 soil3 teagasc year year2 soil2*  ogagehld2 isofffarmy if `var'cuylq_ha > 0,re	
	*regress ln`var'feed ftotallu `var'cuylq `var'cuylq2  region2-region8 soil2 soil3 teagasc year year2 soil2*  ogagehld2 isofffarmy if `var'cuylq_ha > 0

	* closing Balance Equation

	gen t`var'go1 = `var'cuclv + `var'cusdv + `var'cufdv + `var'cuslv
	gen t`var'go2 = `var'cuclq_sh*`var'cuylq_ha*`var'cuarq*p_`var'cucl + `var'cusdq_sh*`var'cuylq_ha*`var'cuarq*p_`var'cusd + `var'cufdq_sh*`var'cuylq_ha*`var'cuarq*p_`var'cufd + `var'cuslq_sh*`var'cuylq_ha*`var'cuarq*p_`var'cusl

	*tabstat `var'cugov t`var'*go* `var'cugov `var'cuclq_sh `var'cuylq_ha `var'cuarq p_`var'cucl `var'cusdq_sh `var'cuylq_ha `var'cuarq p_`var'cusd   `var'cufdq_sh `var'cuylq_ha `var'cuarq p_`var'cufd   `var'cuslq_sh `var'cuylq_ha `var'cuarq p_`var'cusl if `var'cuylq_ha > 0 [weight=wt] , by(year) stats(mean)

	* ignore impact of opening balance on go for year

	** Direct Costs
	* Convert to Ha
	local costperha_vlist = "cufrv cusev cucpv cutcv cutsv cumhv cucwv cumcv"

	* Fertilser Cost model
	local var1 = "cufrv"
	gen p_`var'`var1' = PfertiliserNPK/100

	* Crop Protection
	local var1 = "cucpv"
	gen p_`var'`var1' = PPlantProtection/100

	* Seed Cost model
	local var1 = "cusev"
	gen p_`var'`var1' = PSeeds/100

	* Transport
	local var1 = "cutcv"
	gen p_`var'`var1' = PMotorFuels/100

	local var1 = "cutsv"
	gen p_`var'`var1' = PMotorFuels/100

	* Machinary Hire
	local var1 = "cumhv"
	gen p_`var'`var1' = POtherInputs/100

	* Casual labour cost
	local var1 = "cucwv"
	gen p_`var'`var1' = PLabour/100

	* Miscellaneous cost
	local var1 = "cumcv"
	gen p_`var'`var1' = POtherInputs/100

	foreach var1 in `costperha_vlist' {
		capture drop `var'`var1'_ha
		gen `var'`var1'q_ha = `var'`var1'/(`var'cuarq*p_`var'`var1')
		*regress `var'`var1'q_ha region2-region8 soil2 soil3 teagasc year year2 soil2*  ogagehld2 isofffarmy if `var'cuylq_ha > 0
		capture gen `var'`var1'q_ha_df = `var'`var1'q_ha/`p_`var'`var1''
		*xtreg `var'`var1'q_ha_df `p_`var'`var1'' region2-region8 soil2 soil3 teagasc year year2 if `var'cuylq_ha > 0, re
		*regress xtreg `var'`var1'q_ha_df `p_`var'`var1'' region2-region8 soil2 soil3 teagasc year year2 if `var'cuylq_ha > 0

	}

	gen t`var'dc1 = `var'cufrv + `var'cusev + `var'cucpv + `var'cutcv - `var'cutsv + `var'cumhv + `var'cucwv + `var'cumcv
	gen t`var'dc2 = p_`var'cufrv*`var'cufrvq_ha*`var'cuarq + p_`var'cusev*`var'cusevq_ha*`var'cuarq + p_`var'cucpv*`var'cucpvq_ha*`var'cuarq + p_`var'cutcv*`var'cutcvq_ha*`var'cuarq - p_`var'cutsv*`var'cutsvq_ha*`var'cuarq + p_`var'cumhv*`var'cumhvq_ha*`var'cuarq + p_`var'cucwv*`var'cucwvq_ha*`var'cuarq + p_`var'cumcv*`var'cumcvq_ha*`var'cuarq
	*tabstat `var'cudcv  t`var'dc* if `var'cuylq_ha > 0 [weight=wt] , by(year) stats(mean)

}


local crop_vlist = "wwh swh wby sby mby pot sbe"


foreach var in `crop_vlist' {

	*tabstat `var'cuslq_ha p_`var'cusl `var'cufdq_ha p_`var'cufd `var'cusdq_ha p_`var'cusd `var'cuclq_ha p_`var'cucl `var'cuarq if `var'cuarq > 0, by(year) stats(mean)
	*tabstat t`var'dc2 p_`var'cufrv `var'cufrvq_ha `var'cuarq p_`var'cusev `var'cusevq_ha `var'cuarq p_`var'cucpv `var'cucpvq_ha `var'cuarq p_`var'cutcv `var'cutcvq_ha `var'cuarq p_`var'cutsv `var'cutsvq_ha `var'cuarq p_`var'cumhv `var'cumhvq_ha `var'cuarq p_`var'cucwv `var'cucwvq_ha `var'cuarq p_`var'cumcv `var'cumcvq_ha `var'cuarq if `var'cuarq > 0, by(year) stats(mean)
}

*local crop_vlist = "wwh swh wby sby mby wot sot osr pbs lsd pot sbe"
local crop_vlist = "wwh swh wby sby mby pot sbe"

foreach var in `crop_vlist' {
	*tabstat `var'cuclq `var'cuwtq `var'cualq `var'cusdq `var'cufdq `var'cuslq `var'_ha - `var'_go if `var'_go  > 0 & `var'_go != . [weight=wt], by(year) stats(mean)
}

******************************************************
******************************************************
* Farm Level
******************************************************
******************************************************


gen tothgo  =  farmgo - (fdairygo + fcatlego + fsheepgo + fpigsgo + fpoultgo + fhorsego + fothergo + fcropsgo + fgrntsub + frhiremh + frevoth - finttran)

gen tfcatlego =  fcatlego - cattle_subs - suckler_welfare - fsubchen*(year <= 1999)
gen tfsheepgo =  fsheepgo - sosubsid
gen tfpigsgo  =  fpigsgo 
gen tfpoultgo =  fpoultgo - posubsid
gen tfcropsgo =  fcropsgo - tillage_subs
gen tfhorsego =  fhorsego - fsubhors
replace tothgo = tothgo - fsubforh - fsubtbco - fsubyfig
gen pfdairygo  = PMilk/100
gen pfcatlego  = PTotalCattle/100
gen pfsheepgo  = PSheep/100
gen pfpigsgo  =  Ppig/100
gen pfpoultgo  = Ppoultry/100
gen pfcropsgo  = PTotalCrop/100

capture drop tfarmgo1 tfarmgo2
gen tfarmgo1  =  tfdairygo + tfcatlego + tfsheepgo + tfpigsgo + tfpoultgo + tfhorsego + fothergo + tfcropsgo + tothgo + frhiremh + frevoth - finttran
gen tfarmgo2  =  tfdairygo/pfdairygo + tfcatlego/pfcatlego + tfsheepgo/pfsheepgo + tfpigsgo/pfpigsgo + tfpoultgo/pfpoultgo + tfhorsego + fothergo + tfcropsgo/pfcropsgo + tothgo + frhiremh + frevoth - finttran

gen tfarmdc1  =  fdpurcon + fdpurblk + fdferfil + fdcrppro + fdpursed + fdmachir + fdtrans + fdlivmnt + fdcaslab + fdmiscel + fdfodadj
gen tfarmdc2  =  fdpurcon/PCattleFeed*100 + fdpurblk/PStraightFeed*100 + fdferfil/PTotalFert*100 + fdcrppro/PPlantProtection*100 + fdpursed/PSeeds*100 + fdmachir/POtherInputs*100 + fdtrans/PMotorFuels*100 + fdlivmnt/PVetExp*100 + fdcaslab/PLabour*100 + fdmiscel/POtherInputs*100 + fdfodadj

gen tfarmohct1 = forntcon + focarelp + fohirlab + fointpay + fomacdpr + fomacopt + foblddpr + fobldmnt + fodprlim + foupkpld + foannuit + fomiscel + forates*(year == 2009) + fortfmer*(year < 1999)
gen tfarmohct2 = forntcon + focarelp/PElectricity*100 + fohirlab/PLabour*100 + fointpay + fomacdpr + fomacopt + foblddpr + fobldmnt/POtherInputs*100 + fodprlim/POtherInputs*100 + foupkpld/POtherInputs*100 + foannuit + fomiscel/POtherInputs*100 + forates*(year == 2009) + fortfmer*(year < 1999)


	gen tfarmffi1  =  tfarmgo1 - tfarmdc1 - tfarmohct1 + dirpayts
	gen tfarmffi2  =  tfarmgo2 - tfarmdc2 - tfarmohct2 + dirpayts
	*drop if tfarmffi2 == .
	drop if fulltime == .
	gen rffiperha = farmffi/farmsize
	drop if rffiperha == .
*STOP!!!
gen subsidy_comm = dairy_subs + cattle_subs + suckler_welfare + sosubsid + posubsid + tillage_subs + fsubhors + fsubtbco + fsubyfig + fsubchen*(year <= 1999)
	gen subsidy1 = farmgo - tfarmgo1
	gen subsidy_diff = dirpayts -  subsidy1

	drop if farmcode == .

	******************************************************
	******************************************************
	* Other
	******************************************************
	******************************************************



	* Pigs
	gen p_othmiscdc = pdmiscdc - imiscpig - flabccpg

	local p_inp_vlist = "pdtotfed pdvetmed pdtrans p_othmiscdc iaisfpig imiscpig flabccpg fpigsdc iballpig ibhaypvl  ibstrpvl ibsilpvl"

	* Poultry
	gen po_othmiscdc = edtotldc - icallpyv - ivmallpy - itepolty - imiscpty - flabccpy

	local po_inp_vlist = "fpoultdc po_othmiscdc ivmallpy itepolty imiscpty flabccpy icallpyv edtotldc"

	* Horse
	gen h_othmiscdc = edtotldc - icallhvl - ivmallh - iaisfhrs - itehorse - imischrs - iballhrs - ibhayhvl - ibstrhvl - ibsilhvl

	local h_inp_vlist = "fhorsedc icallhvl ivmallh iaisfhrs itehorse imischrs iballhrs ibhayhvl ibstrhvl ibsilhvl h_othmiscdc hdtotldc"



	*****************************************************
	* GM, GO per ha
	*****************************************************
	* Dairy Expansion Potential

	gen dgm_ha = fdairygm/daforare
	gen dgo_ha = fdairygo/daforare


	*****************************************************
	* Eliminate Small Farms
	*****************************************************
	*drop if fsizeuaa < 5


	*****************************************************
	* Prepare Farm IGM analysis
	*****************************************************

	capture gen fcerealgo = tfcropsgo
	capture gen cropgo = fcerealgo
	* local farm_vars_vlist       = "other_go fdairygo fcatlego fsheepgo fpigsgo fpoultgo fcerealgo potcugov 
	* oth_dc fdpurblk fdpurcon fdferfil fdpursed fdcrppro fdvetmed fdaifees oth_oc focarelp dirpayts_sfp sfp"
	capture gen oth_dc = tfarmdc1 - (fdpurblk + fdpurcon + fdferfil + fdpursed + fdcrppro + fdvetmed + fdaifees)
capture gen oth_oc = tfarmohct1 - (focarelp)
	capture gen dirpayts_sfp = dirpayts - sfp 

	capture gen dirpayts_sfp2 = dirpayts - sfp - fsubreps - suckler_welfare

	gen hassuckler_welfare = suckler_welfare > 0  & suckler_welfare != .

	replace fdairygo = tfdairygo
	replace fcatlego = tfcatlego
	replace fsheepgo = tfsheepgo
	replace fpigsgo = tfpigsgo  
	replace fpoultgo = tfpoultgo 
capture gen other_go = tfarmgo1 - (fdairygo + fcatlego + fsheepgo + fpigsgo + fpoultgo + fcerealgo)

	*****************************************************
	* Efficiency Analysis
	*****************************************************

	*go_lu

	gen fdairygo_lu = fdairygo/dpnolu
	gen fcatlego_lu = fcatlego/cpnolu
	gen fsheepgo_lu = fsheepgo/spnolu

	*lu_ha

	gen fdairylu_ha = dpnolu/daforare
	gen fcatlelu_ha = cpnolu/cpforacs
	gen fsheeplu_ha = spnolu/spforacs
	gen fcerealgo_ha = tfcropsgo/tillage_area
	gen cropgo_ha = tfcropsgo/tillage_area

	*dc_ha
	gen farmdc_ha = farmdc/fsizuaa
	gen farmohct_ha = farmohct/fsizuaa

	local cost_vlist = "oth_dc fdpurblk fdpurcon fdferfil fdpursed fdcrppro fdvetmed fdaifees oth_oc focarelp"
	foreach var in `cost_vlist' {
		gen `var'_ha = `var'/fsizuaa
	}	

*****************************************************
* Dairy Efficiency Analysis
*****************************************************
*****************************************************

* GM per litre
gen gm_lt  = fdairygm/dotomkgl

* Deflate to 2000 prices
gen gm_lt_df = gm_lt/PMilk*100

* Set into bands
gen gm_lt_df5 = max(0.05,min(.25,int(gm_lt_df/.05)*.05)) if gm_lt != .

tab year gm_lt_df5

*GM = (GO/lt – S(DC(i)/lt))*lt/lu*lu/ha*ha

* GO/lt

gen GO_lt = fdairygo/dotomkgl

* lt_lu
gen lt_lu = dotomkgl/dpnolu

* lu_ha
gen lu_ha = dpnolu/daforare

* dc_lt
gen dc_lt = fdairydc/dotomkgl
gen dc_lu = fdairydc/dpnolu

	*Litres per unit of concentrate
gen lt_conc = dotomkgl/(ddconval/(PCattleFeed/100))
replace lt_conc = 1 if lt_conc >= .

	capture gen d_othmiscdc = ddmiscdc - ivmalldy - iaisfdy - itedairy - imiscdry - flabccdy

	gen ha = daforare





	*****************************************************
	* 5 cent per lt groups
	*****************************************************

	gen gm_lt5_year = year+gm_lt_df5


*tabstat GO_lt-dc_lu ha fdairygm if daforare > 0 [weight=wt], by(gm_lt5_year) stats(mean)

	*****************************************************
	* Enterprise specific Quintile of GM
	*****************************************************
	*drop if wt == .
	*Set up gm and ha variables
	gen fdairyha = daforare
	gen fcatleha = cpforacs
	gen fsheepha = spforacs
	gen fcropsha = tillage_area
	local ent_vlist = "fdairy fcatle fsheep "
*fcrops
	foreach var in `ent_vlist' {

		gen `var'gm_ha = `var'gm/`var'ha
			gen `var'gm_ha_q = 0
			*local i = 2001 *!
			local i = 1999 
			*while `i'<= 2009 { *!
			while `i'<= 2007 {
				xtile t`var'gm_ha_q`i' = `var'gm_ha [weight = wt] if year == `i'  & `var'ha > 0 , nq(5)
					qui replace `var'gm_ha_q = t`var'gm_ha_q`i' if year == `i'  & `var'ha > 0
		qui replace t`var'gm_ha_q`i' = 0 if t`var'gm_ha_q`i' == .
		sort farmcode
		by farmcode: egen `var'gm_ha_q`i' = max(t`var'gm_ha_q`i')
		local i=`i'+1
	}

	* Fit 2003 with most recent if 2003 not available
	*local i = 2001 *!
	local i =1999
	*while `i'<= 2009 { *!
	while `i'<= 2007 {
		qui replace `var'gm_ha_q2003 = `var'gm_ha_q`i' if `var'gm_ha_q2003 == 0  & `var'gm_ha_q`i' > 0
		local i = `i' + 1
	}

	sort farmcode year
	by farmcode: gen `var'gm_ha_q_1 = `var'gm_ha_q2003[_n-1]
	tab `var'gm_ha_q_1 if `var'gm_ha_q_1 > 0, gen(`var'gm_ha_q_1_) 
}


*****************************************************
* Quintile
*****************************************************
gen gm_ha = fdairygm/daforare
gen liquidm =  dosllmvl > 0 
gen gm_ha_q = 0
*local i = 2001 *!
local i = 1999
*while `i'<= 2009 {
while `i'<= 2007 {
	xtile gm_ha_q`i' = gm_ha [weight = wt] if year == `i' & daforare > 0, nq(5)
	replace gm_ha_q = gm_ha_q`i' if year == `i'  & daforare > 0
	local i=`i'+1
}

gen gm_lt5_quin = year*10+gm_ha_q
sort farmcode year
by farmcode: gen gm_ha_q_1 = gm_ha_q[_n-1]
tabstat GO_lt-dc_lu ha if daforare > 0 [weight=wt], by(gm_lt5_quin) stats(mean)

* Weighted by milk volume
gen milk_wt = wt*dotomkgl
sort year
by year: egen smilk = sum(milk_wt)

tab year, sum(smilk)

gen gm1_ha_q = 0
*local i = 2001 *!
local i = 1999
*while `i'<= 2009 { *!
while `i'<= 2007 {
	xtile gm1_ha_q`i' = gm_ha [weight = milk_wt] if year == `i', nq(5)
	replace gm1_ha_q = gm1_ha_q`i' if year == `i'
	local i=`i'+1
}


gen gm1_lt5_quin = year*10+gm1_ha_q
tabstat GO_lt-dc_lu ha lt_conc fdairygm if daforare > 0 [weight=wt], by(gm1_lt5_quin) stats(mean)

*Number of farms
tab gm1_lt5_quin [iweight=wt]



*****************************************************
*lags
*****************************************************
sort farmcode year
by farmcode: gen gm1_ha_q1 = gm1_ha_q[_n-1]
by farmcode: gen gm_ha_q1 = gm_ha_q[_n-1]

by farmcode: gen dc_lt_1 = dc_lt[_n-1]
by farmcode: gen PTotalInputs_1 = PTotalInputs[_n-1]
gen rdc_lt = (100*dc_lt/PTotalInputs)/(100*dc_lt_1/PTotalInputs_1)
tab year gm1_ha_q1 [weight=wt] if gm_ha_q > 0,sum(rdc_lt) noobs nofreq nost

by farmcode: gen lt_lu_1 = lt_lu[_n-1]
gen rlt_lu = lt_lu/lt_lu_1
tab year gm1_ha_q1  [weight=wt] if gm1_ha_q1 > 0,sum(rlt_lu) noobs nofreq nost

by farmcode: gen lu_ha_1 = lu_ha[_n-1]
gen rlu_ha = lu_ha/lu_ha_1
tab year gm1_ha_q1  [weight=wt] if gm1_ha_q1 > 0,sum(rlu_ha) noobs nofreq nost

by farmcode: gen daforare_1 = daforare[_n-1]
gen rdaforare = daforare/daforare_1
tab year gm1_ha_q1  [weight=wt] if gm1_ha_q1 > 0,sum(rdaforare) noobs nofreq nost

tab gm1_ha_q1, gen(gm1_ha_q1_)
tab gm_ha_q1, gen(gm_ha_q1_)


gen hasdry = daforare > 0 & daforare != .
sort farmcode year
by farmcode: gen hasdry_1 = hasdry[_n-1]

gen exit_dry = hasdry == 0 & hasdry_1 == 1

mvencode rdc_lt-rdaforare, mv(1) override

gen dry_platform = DAIRY_PLATFORM


*****************************************************
* Corrected for region
*****************************************************

sort soil
tab soil, gen(soil_) // if soil > 0 & soil != . *!


local dairy_var_list = "fdairygm GO_lt lt_lu lu_ha dc_lt dc_lu ha lt_conc"
/*
foreach var in `dairy_var_list' {
	capture drop tsoil* tregion*
	tab soil if soil > 0 & soil != ., gen(tsoil_)
	tab region if region > 0 & region != ., gen(tregion_)

	regress `var' tregion_2-tregion_8 tsoil_2-tsoil_6 year year2 if dotomkgl > 0
	predict p1`var' if `var' > 0 & `var' != .
	predict e`var'  if `var' > 0 & `var' != ., r

	* Make all variables be the best region and soil for milk production
	replace tregion_1 = 0
	replace tregion_2 = 0
	replace tregion_3 = 1
	replace tregion_4 = 0
	replace tregion_5 = 0
	replace tregion_6 = 0
	replace tregion_7 = 0
	replace tregion_8 = 0

	replace tsoil_1 = 0
	replace tsoil_2 = 1
	replace tsoil_3 = 0
	replace tsoil_4 = 0
	replace tsoil_5 = 0
	replace tsoil_6 = 0

	predict p`var' //if `var' > 0 & `var' != . *!
	gen t`var' = p`var' + e`var'
}

tabstat tGO_lt tlt_lu tlu_ha tdc_lt tdc_lu tha tlt_conc tfdairygm if daforare > 0 [weight=wt], by(gm1_lt5_quin) stats(mean)
*/
*****************************************************
* Feed and Fertility
*****************************************************
*Feed per LU
gen dafedare_lu = dafedare/dpnolu

*Forage per LU
gen daforare_lu = daforare/dpnolu

* Fertilty Rate
gen fertility = dpcfbtot/(dpavnohd + cpavnocw + cpavnohc)

tabstat daf*_lu fertility if daforare > 0 [weight=wt], by(gm1_lt5_quin) stats(mean)


*****************************************************
* Water Quality
*****************************************************

*tabstat org_N_perhet170 exceed_inorganic org_N_perhet250 org_N_perhet  if daforare > 0 [weight=wt], by(gm1_lt5_quin) stats(mean)


*****************************************************
* Exits
*****************************************************

sort farmcode year
by farmcode: gen gm1_ha_q_1 = gm1_ha_q[_n-1]

sort farmcode year
by farmcode: gen system_1 = system[_n-1]
gen stock_rate_tot = ftotallu/fsizuaa
by farmcode: gen stock_rate_tot_1 = stock_rate_tot[_n-1]
by farmcode: gen gm_ha_1 = gm_ha[_n-1]

capture gen doslmkgl_lu = doslmkgl/dpnolu
by farmcode: gen doslmkgl_lu_1 = doslmkgl_lu[_n-1]

gen reduce_dry = daforare_1 > daforare + 1 & daforare_1 != .
gen increase_dry = daforare > daforare_1 + 1 & daforare_1 != .
gen delta_dry = daforare - daforare_1 

tab year gm1_ha_q1 if gm1_ha_q1 > 0 & hasdry_1 == 1 [weight =wt],sum(hasdry)  nost noobs nofreq 

*****************************************************
* Dairy Potential
*****************************************************

gen isdairy = fdairygo > 0
gen dairy_stock_rate = dpnolu/daforare
sort farmcode year
by farmcode: gen dairy_stock_rate_1 = dairy_stock_rate[_n-1]

*gen stock_rate = (dpnolu + cpnolu)/(daforare + cpforacs)
*gen ogagehld2 = ogagehld *ogagehld 
*gen fsizuaa2 = fsizuaa*fsizuaa 
gen soil_3g = int((soil+1)/2) if soil > 0

gen non_drysys_1 = system_1 > 1 & system_1 != .
gen drysys0_1 = system_1 == 0
gen drysys1_1 = system_1 == 1


*****************************************************
* Sucession
*****************************************************

by farmcode: gen transfer = ogagehld < ogagehld[_n-1] - 2 & ogagehld[_n-1]  != . & ogagehld != 0

tab year [weight=wt] if ogagehld > 0, sum(ogagehld) nost noobs nofreq
tab year [weight=wt] if ogagehld > 0, sum(transfer) nost noobs nofreq

*****************************************************
* Milk Price
*****************************************************
gen milkprice = doslmkvl/doslmkgl
tab year [weight=wt], sum(milkprice)
tabstat doslmkgl [weight=wt], by(year) stats(sum)

*****************************************************
* Soil Analysis - in 3 groups as sample size is small
*****************************************************
*use testdoFarm, clear
*do sub_do/renameFADN.do

gen dgm_ha_3 = 0
gen dgm_ha_4 = 0
local i = 1
while `i' <= 5 {
	xtile dgm_ha`i'_3 = dgm_ha , nq(3) //if dgm_ha > 0 & dgm_ha !=. & soil == `i' & year == 2008 *!
	replace dgm_ha_3 = dgm_ha`i'_3  if dgm_ha > 0 & dgm_ha !=.  & soil == `i' & year == 2008
	xtile dgm_ha`i'_4 = dgm_ha , nq(4) // if dgm_ha > 0 & dgm_ha !=. & soil == `i' & year == 2008 *!
	replace dgm_ha_4 = dgm_ha`i'_4  if dgm_ha > 0 & dgm_ha !=.  & soil == `i' & year == 2008
	local i = `i' + 1
}

sort soil
by soil: egen tavdgm_ha = mean(dgm_ha) if dgm_ha_3 == 3 & dgm_ha > 0 & dgm_ha !=. & year == 2008
replace tavdgm_ha = 0 if tavdgm_ha == .
sort soil
by soil: egen avdgm_ha = max(tavdgm_ha)

*Potential Dairy GM per ha

*Average Farm GM per ha
gen mktgm_ha = (farmgm-dirpayts)/fsizuaa
tab soil [weight=wt] if year == 2008, sum(mktgm_ha)

* Average DAiry GM
tab soil if dgm_ha > 0 & year == 2008 [weight=wt], sum(dgm_ha)

* Non Dairy GM
tab soil if system > 1 & year == 2008 [weight=wt], sum(mktgm_ha)


*****************************************************
* Land Use
*****************************************************

gen nondairy = fsizuaa - daforare
*gen nondairyondairy = fsizuaa - daforare if daforare > 0  & year == 2008
gen nondairyondairy = fsizuaa - daforare if system <= 1  & year == 2008
replace nondairyondairy = 0 if nondairyondairy == .
gen nondairy1 = nondairy - nondairyondairy
*tabstat nondairy1 daforare nondairyondairy fdairygm [weight=wt] if year == 2008, by(soil) stats(sum)

* Potential Dairy GM
tab soil [weight=wt] if year == 2008, sum( avdgm_ha)

* 
tab soil dgm_ha_3 [weight=wt] if year == 2008, sum(dgm_ha) nost nofreq noobs


*****************************************************
* Farmer characteristics
*****************************************************

tab soil dgm_ha_3 [weight=wt] if year == 2008, sum(dgm_ha) nost nofreq noobs

gen drystocknondairy = nondairy1*(system >= 2 & system <= 4) 
gen tillagenondairy = nondairy1*(system >= 5) 



gen sheepnondairy = nondairy1*(system == 4)
gen cattlenondairy0 = nondairy1*(system >= 2 & system <= 3)*(fsizuaa < 25)
gen cattlenondairy1 = nondairy1*(system >= 2 & system <= 3)*(stock_rate < 1.4)*(fsizuaa >= 25)
gen cattlenondairy2 = nondairy1*(system >= 2 & system <= 3)*(stock_rate >= 1.4 & stock_rate < 1.6)*(fsizuaa >= 25)
gen cattlenondairy3 = nondairy1*(system >= 2 & system <= 3)*(stock_rate >= 1.4)*(fsizuaa >= 25)
gen cattlenondairy4 = nondairy1*(system >= 2 & system <= 3)*(stock_rate >= 1.4)*(fsizuaa >= 25)*(ogagehld <= 43)
gen cattlenondairy5 = nondairy1*(system >= 2 & system <= 3)*(stock_rate >= 1.4)*(fsizuaa >= 25)*(ogagehld <= 50)

gen is65 = ogagehld >= 65

*!*tabstat nondairy1 daforare nondairyondairy tillagenondairy drystocknondairy sheepnondairy cattlenondairy0-cattlenondairy5  [weight=wt] if year == 2008, by(soil) stats(sum)

* with off farm job
*!*tabstat nondairy1 daforare nondairyondairy tillagenondairy drystocknondairy sheepnondairy cattlenondairy0-cattlenondairy5  [weight=wt] if year == 2008 & isofffarmy == 1, by(soil) stats(sum)

* Aged 65+
*!*tabstat nondairy1 daforare nondairyondairy tillagenondairy drystocknondairy sheepnondairy cattlenondairy0-cattlenondairy5  [weight=wt] if year == 2008 & is65 == 1, by(soil) stats(sum)


*****************************************************
*Todo need to work out land requirement for replcements and followers
*****************************************************


*gen mgm_ha = (farmffi- dirpayts)/ fsizeadj
*gen farmgm_ha  =farmgm/ fsizeadj

gen fc_ha = (fototal)/ fsizeadj


*Dairy Fixed Costs
tab soil [weight=wt] if year == 2008 & system == 0 , sum(fc_ha)

*Non Dairy Fixed Costs
tab soil [weight=wt] if year == 2008 & system >1 , sum(fc_ha)


* Milk Yield

*gen milk_lu = dotomkvl/dpnolu
tab soil dgm_ha_3 [weight=wt] if year == 2008, sum(milk_lu) nost nofreq noobs

*****************************************************
* Merge in dairy platform data
*****************************************************
/* *!
sort farmcode year
merge farmcode year using D:\Data\data_NFSPanelAnalysis\OutData\dairyplatform.dta
drop _merge

gen spare_dry_platform = max(0,  DAIRY_PLATFORM_HA - daforare)
gen exceed_dry_platform = max(0,  daforare - DAIRY_PLATFORM_HA)

gen hasexceed_dry_platform = exceed_dry_platform > 0
gen hasspare_dry_platform = spare_dry_platform > 0

tab hasexceed_dry_platform [weight=wt] if year == 2008 & daforare > 0, sum(daforare)
tab hasexceed_dry_platform [weight=wt] if year == 2008 & daforare > 0, sum(dpnolu)
tab hasexceed_dry_platform [weight=wt] if year == 2008 & daforare > 0, sum(dairy_stock_rate)
tab hasexceed_dry_platform [weight=wt] if year == 2008 & daforare > 0, sum(nondairyondairy)

tab region [weight=wt] if year == 2008 & daforare > 0, sum(hasexceed_dry_platform  )

gen non_daryha = fsizuaa - daforare

gen hasdry_orig = daforare > 0 & daforare != .

qui mvencode _all, mv(0) override

*/ *!
*****************************************************
* Set up IGM Model Logs
*****************************************************

gen lnlandval_ha =ln(landval_ha)
gen lnfdferfil_ha =ln(fdferfil/fsizuaa) 
gen lndaforare =ln(daforare)  
gen lncpforacs =ln(cpforacs)  
gen lnspforacs =ln(spforacs)  
gen lntillage_area = ln(tillage_area)
gen lndpnolu_ha =ln(dpnolu/daforare)  
gen lncpnolu_ha =ln(cpnolu/cpforacs)  
gen lnspnolu_ha =ln(spnolu/spforacs)  
gen lnflabunpd =ln(flabunpd)  
gen lnogagehld =ln(ogagehld)  
gen lnfdairygm_ha = ln(fdairygm_ha)
gen lnfcatlegm_ha = ln(fcatlegm_ha)
gen lnfsheepgm_ha = ln(fsheepgm_ha)

sort farmcode year
by farmcode: gen p_doslmkvl_1 = p_doslmkvl[_n-1]


gen lnfsizuaa = ln(fsizuaa)
gen lnfsizuaa2 = ln(fsizuaa2)

gen lntillage_sh = ln(tillage_sh)
gen lndaforare_sh = ln(daforare_sh)
gen lncpforacs_sh = ln(cpforacs_sh)
gen lnspforacs_sh = ln(spforacs_sh)
gen lnspnolu = ln(spnolu)
gen lncpnolu = ln(cpnolu)
gen lndpnolu = ln(dpnolu)

*Estimate farm efficiency

capture gen fyear = year
capture drop year2
capture drop year2
tab fyear, gen(year)
gen fdairygm_ha_cond = fdairygo > 0
*xtreg lnfdairygm_ha lnlandval_ha lnfdferfil_ha lndaforare lndpnolu_ha lnflabunpd lnogagehld isofffarmy daforare_sh hasforestry teagasc hasreps fyear year6-year9  soil1 soil2 if(fdairygm_ha_cond == 1), re
*predict lnfdairygm_ha_u, u

gen fcatlegm_ha_cond = fcatlego > 0
*xtreg lnfcatlegm_ha lnlandval_ha lnfdferfil_ha lncpforacs lncpnolu_ha lnflabunpd lnogagehld isofffarmy cpforacs_sh daforare_sh hasforestry teagasc hasreps fyear year6-year9  soil1 soil2 if(fcatlegm_ha_cond == 1), re
*predict lnfcatlegm_ha_u, u

gen fsheepgm_ha_cond = fsheepgo > 0
*xtreg lnfsheepgm_ha lnlandval_ha lnfdferfil_ha lnspforacs lnspnolu_ha lnflabunpd lnogagehld isofffarmy spforacs_sh hasforestry teagasc hasreps fyear year6-year9  soil1 soil2 if(fsheepgm_ha_cond == 1), re
*predict lnfsheepgm_ha_u, u

gen lnfcerealgm_ha = ln(fcropsgm/tillage_area)
gen fcerealgm_ha_cond = fcropsgo > 0
*xtreg lnfcerealgm_ha lnlandval_ha lnfdferfil_ha lntillage_area lnflabunpd lnogagehld isofffarmy tillage_sh hasforestry teagasc hasreps fyear year6-year9  soil1 soil2 if(fcerealgm_ha_cond == 1), re
*predict lnfcerealgm_ha_u, u

*****************************************************
* Exists in 2008 - Summary Statistics
*****************************************************
/* *!
gen tyear2008 = year==2008

sort farmcode year
by farmcode: egen isyear2008 = max(tyear2008)
tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(lt_lu) nost nofreq noobs


gen tgm1_ha_q2008 = gm1_ha_q*(year == 2008)
sort farmcode year
by farmcode: egen gm1_ha_q_2008 = max(tgm1_ha_q2008)

capture log close
*!*log using D:\Data\data_NFSPanelAnalysis\OutData\LEADER\MilkExpansion.log, replace

tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(lt_lu) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(lt_lu) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(lu_ha) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(lu_ha) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(dc_lt) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(dc_lt) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(dc_lu) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(dc_lu) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(daforare) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(daforare) nost nofreq noobs


tabstat dotomkvl  if daforare > 0 [weight=wt], by(year) stats(sum)
tabstat dotomkvl  if isyear2008 == 1 & daforare > 0 [weight=wt], by(year) stats(sum)


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(dpnolu) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(dpnolu) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(dotomkvl) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(dotomkvl) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(fdairygm) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(fdairygm) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(gm_lt) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(gm_lt) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(fsizuaa) nost nofreq noobs
tab year gm1_ha_q_2008 if gm1_ha_q_2008 > 0 & isyear2008 == 1 & daforare > 0 [weight=wt], sum(fsizuaa) nost nofreq noobs


tab year gm1_ha_q  if daforare > 0 [weight=wt], sum(exit_dry) nost nofreq noobs


tab year gm1_ha_q_1  if daforare_1 > 0 [weight=wt], sum(exit_dry) nost nofreq noobs

tab year gm1_ha_q  if daforare > 0 & year == 2008  [weight=wt], sum(spare_dry_platform) nost nofreq noobs
tab year gm1_ha_q  if daforare > 0 & year == 2008  [weight=wt], sum(daforare) nost nofreq noobs
*/ *!
capture log close
