*-------------------------------------------------------------------------
*-------------------------------------------------------------------------
/* Attempts to follow methodology set out in FADN's 
	EU Dairy Farms Report (pg. 62 in ANNEX I)

	which was available at the following URL at the time of writing

	http://ec.europa.eu/agriculture/rica/pdf/dairy_report_2010.pdf
	last accessed @ 16:55 20th Jan. 2014
*/
*-------------------------------------------------------------------------
*-------------------------------------------------------------------------



*-------------------------------------------------------------------------
* FADN conditions for farm sample (see e.g. pg 61 of report)
*-------------------------------------------------------------------------
capture drop outplussubs
capture drop milkplussubs
gen outplussubs 	= totaloutput + totalsubsidiesexcludingoninvestm + subsidiesoninvest  
gen milkplussubs	= cowsmilkandmilkproducts + totalsubsidiesexcludingoninvestm + subsidiesoninvest 

drop if totaloutput <= 0 
drop if outplussubs <= 0 
drop if outplussubs <= milkplussubs
drop if totaloutput <= cowsmilkandmilkproducts 

drop outplussubs milkplussubs	
*-------------------------------------------------------------------------





*-------------------------------------------------------------------------
* Impute family labour cost
*-------------------------------------------------------------------------
capture drop meanwage 
capture drop familylabourcost 
gen meanwage         = wagespaid / paidlabourinputhours
gen familylabourcost = unpaidlabourinputhours * meanwage
*-------------------------------------------------------------------------



*-------------------------------------------------------------------------
* Own capital cost (opportunity cost of land owned) 
*-------------------------------------------------------------------------
capture drop meanrent
capture drop ownlandcost	 
gen meanrent 	 = rentpaid / renteduaa
gen ownlandcost	 = uaainowneroccupation * meanrent
*-------------------------------------------------------------------------



*-------------------------------------------------------------------------
* Own capital cost (except land) 
*-------------------------------------------------------------------------
* Don't know the details of the "weighted interest" calculation
*  Text states that they use the Global Insight rate as the minimum
*  rate anyway, so I'll just use that. 

* Global Insight Long Term interest rate (taken from table)
capture drop GI_LTrate	 
gen     GI_LTrate	 = . 
replace GI_LTrate	 = 4.65  if year == 1999 & country =="IRE"
replace GI_LTrate	 = 5.48  if year == 2000 & country =="IRE"
replace GI_LTrate	 = 5.09  if year == 2001 & country =="IRE"
replace GI_LTrate	 = 4.99  if year == 2002 & country =="IRE"
replace GI_LTrate	 = 4.15  if year == 2003 & country =="IRE"
replace GI_LTrate	 = 4.07  if year == 2004 & country =="IRE"
replace GI_LTrate	 = 3.32  if year == 2005 & country =="IRE"
replace GI_LTrate	 = 3.79  if year == 2006 & country =="IRE"
replace GI_LTrate	 = 4.34  if year == 2007 & country =="IRE"
replace GI_LTrate	 = 4.55  if year == 2008 & country =="IRE"
replace GI_LTrate	 = 5.19  if year == 2009 & country =="IRE"

replace GI_LTrate	 = 4.98  if year == 1999 & country =="UKI"
replace GI_LTrate	 = 5.27  if year == 2000 & country =="UKI"
replace GI_LTrate	 = 4.91  if year == 2001 & country =="UKI"
replace GI_LTrate	 = 4.87  if year == 2002 & country =="UKI"
replace GI_LTrate	 = 4.48  if year == 2003 & country =="UKI"
replace GI_LTrate	 = 4.87  if year == 2004 & country =="UKI"
replace GI_LTrate	 = 4.41  if year == 2005 & country =="UKI"
replace GI_LTrate	 = 4.50  if year == 2006 & country =="UKI"
replace GI_LTrate	 = 5.01  if year == 2007 & country =="UKI"
replace GI_LTrate	 = 4.50  if year == 2008 & country =="UKI"
replace GI_LTrate	 = 3.58  if year == 2009 & country =="UKI"

* Inflation rate (taken from table)
capture drop inflationrate	 
gen     inflationrate	 = . 
replace inflationrate	 = 2.5  if year == 1999 & country =="IRE"
replace inflationrate	 = 5.3  if year == 2000 & country =="IRE"
replace inflationrate	 = 4.0  if year == 2001 & country =="IRE"
replace inflationrate	 = 4.7  if year == 2002 & country =="IRE"
replace inflationrate	 = 4.0  if year == 2003 & country =="IRE"
replace inflationrate	 = 2.3  if year == 2004 & country =="IRE"
replace inflationrate	 = 2.2  if year == 2005 & country =="IRE"
replace inflationrate	 = 2.7  if year == 2006 & country =="IRE"
replace inflationrate	 = 2.9  if year == 2007 & country =="IRE"
replace inflationrate	 = 3.1  if year == 2008 & country =="IRE"
replace inflationrate	 =-1.7   if year == 2009 & country =="IRE"

replace inflationrate	 = 1.3  if year == 1999 & country =="UKI"
replace inflationrate	 = 0.8  if year == 2000 & country =="UKI"
replace inflationrate	 = 1.2  if year == 2001 & country =="UKI"
replace inflationrate	 = 1.3  if year == 2002 & country =="UKI"
replace inflationrate	 = 1.4  if year == 2003 & country =="UKI"
replace inflationrate	 = 1.3  if year == 2004 & country =="UKI"
replace inflationrate	 = 2.1  if year == 2005 & country =="UKI"
replace inflationrate	 = 2.3  if year == 2006 & country =="UKI"
replace inflationrate	 = 2.3  if year == 2007 & country =="UKI"
replace inflationrate	 = 3.6  if year == 2008 & country =="UKI"
replace inflationrate	 =2.12  if year == 2009 & country =="UKI"

capture drop realrate 
capture drop owncapvalue
capture drop owncapcost	     
gen realrate     = ((GI_LTrate - inflationrate)/100)
gen owncapvalue	 =           ///
      breedinglivestock    + ///
      nonbreedinglivestock + ///
      machinery            + ///
      buildings            + ///
      stockofagriculturalproducts 
gen owncapcost	 = owncapvalue * realrate 
    * NOTE that averagefarmcapital is NOT the correct var to use above
*-------------------------------------------------------------------------



*-------------------------------------------------------------------------
* Unpaid capital costs
*-------------------------------------------------------------------------
capture drop unpaidcapcost 
gen unpaidcapcost = ownlandcost + owncapcost - interestpaid
*-------------------------------------------------------------------------





*-------------------------------------------------------------------------
*-------------------------------------------------------------------------
* All of which gives you the components for...
*-------------------------------------------------------------------------
*-------------------------------------------------------------------------

* Imputed unpaid family factors
capture drop unpaidfamilyfactors 
gen unpaidfamilyfactors = familylabourcost + unpaidcapcost

*-------------------------------------------------------------------------
*-------------------------------------------------------------------------
