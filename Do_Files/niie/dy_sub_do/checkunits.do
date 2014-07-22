*****************************************************
*capture log close
*log using `outdatadir'/tab_logs/checkunits.log, text replace
*****************************************************

*=================================
* Convert from gallons to litres
*=================================
* Variables which could be in gallons or litres
local gl2lt_vlist "lt_lu doslcmgl dosllmgl domkfdgl doslmkgl"
local gl2lt_plist "p_doslcm p_dosllm p_domkfd"

* this table makes it clear that the dataset has units in gallons for years < 2002
tabstat year `gl2lt_vlist', by(year)
tabstat year `gl2lt_plist', by(year)


/* The FADN data is stated in quintals for all years, so
    the following two loops don't apply. We will convert 
    to litres below.
* convert pre-2002 to litres
foreach var in `gl2lt_vlist'{
	replace `var' = `var'*4.54609 if year <= 2001
}

foreach var in `gl2lt_plist'{
	replace `var' = `var'/4.54609 if year <= 2001
}
*/


*=================================
* Convert from quintals to litres
*=================================

/* 
Determination of milk specific gravity

"The specific gravity of milk averages 1.032, i.e. at 4°C 1 ml of milk weighs 1.032 g." 

Source: 
http://www.ilri.org/InfoServ/Webpub/fulldocs/
ilca_manual4/DairyAccounting.htm#P347_17658 

Last Accessed: 30/09/2013 15:16


Given this fact a conversion from from litres to kg
      100 litres × 1.032 = 103.2 kg.

and kg  to litres 
      100 kg     x .96899225 = 96.899225

therefore multiply volumes by 96.899225 to arrive at
quantity of litres (100 kg = 1 quintal).
*/
 
* Converts quintals to litres
foreach var in `gl2lt_vlist'{
	replace `var' = `var'*96.899225  
}

*=================================
* Convert punts to euro
*=================================

/* Not an issue for either NFS or FADN it seems. Tabstat
    tabstat below provided for validating.*/
tabstat p_* *vl*, by(year)
