local outdatadir $outdatadir
*****************************************************
log close
log using `outdatadir'/tab_logs/checkunits.log, text replace
*****************************************************

* Variables which could be in gallons or litres
local gl2lt_vlist "lt_lu doslcmgl dosllmgl domkfdgl doslmkgl"
local gl2lt_plist "p_doslcm p_dosllm p_domkfd"

* this table makes it clear that the dataset has units in gallons for years < 2002
tabstat year `gl2lt_vlist', by(year)
tabstat year `gl2lt_plist', by(year)

* convert pre-2002 to litres
foreach var in `gl2lt_vlist'{
	replace `var' = `var'*4.54609 if year <= 2001
}

foreach var in `gl2lt_plist'{
	replace `var' = `var'/4.54609 if year <= 2001
}

* but this suggests that monetary units are already converted to euro for the pre 1999 years
tabstat p_* *vl*, by(year)
