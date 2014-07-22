*****************************************************
* 5* System selection
*****************************************************
gen syst = ffszsyst-int(ffszsyst/10)*10
keep if syst == 1 | syst == 2


*****************************************************
* 6* Code borrowed from 
*    data_NFSPanelAnalysis/Do_Files/FarmLevelModel/FarmLevel_dairy.do
*    ... originally thought it was Thia's, but she wasn't
*    familiar with it, although her name is on the file.
*    ************************************************
*    Subset
*    Keep only farms with dairy gross output
*****************************************************
* Farms with no milk sales
keep if fdairygo > 0 & fdairygo < .
keep if doslcmgl > 0 & doslcmgl < .

* Farms with 50% liquid milk sales
keep if dosllmgl < 0.5*dotomkgl

* No herds with less than 10 dairy cows
keep if dpopinvd > 10
