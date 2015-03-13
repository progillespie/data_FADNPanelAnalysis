* Compares the datasets produced by the different versions of FADNprep.do
*   in terms of listed variables. These should be the variables in the particular
*   specification of the models used in the thesis.

* This was the second step after having done a dta_equal on each version of 
*   the 4 datasets for the multisward project. These found that none of the
*   datasets were *identical*, but it seems likely that it was just a matter of there being
*   a few exta obs in either version. They could still be "very close" to identical
*   so I decided to look at the summary stats. Differences do look like they 
*   could be due to the exclusion of a few, relatively high leverage obs.

* Next step is to try and ID the actual obs which are missing.
/*
local vlist "totalspecificcosts PTotalCattle"
foreach var of local vlist{

  quietly{
  
      noisily di _newline(2) "************ `var' ***********"
  
      foreach nu of numlist 1 2 3 4 { 
        noisily di _newline(2) "--------------" _newline "  data`nu'  " _newline "--------------"
		local Data "D:\Data_real"
        use `Data'/data_FADNPanelAnalysis/OutData/multisward/data`nu', clear
        noisily di _newline "Real data`nu'" 
		noisily di 
	    noisily summ `var'

        
		local Data "D:\Data"
        use `Data'/data_FADNPanelAnalysis/OutData/multisward/data`nu', clear
        noisily di _newline "Portable data`nu'"
	    noisily summ `var'
		noisily di _newline "--------------"
	
	}
	
  }

}
*/
local nu = 4
use "D:\Data_real/data_FADNPanelAnalysis/OutData/multisward/data`nu'", clear
merge 1:1 farmcode year using "D:\Data/data_FADNPanelAnalysis/OutData/multisward/data`nu'"


quietly{
/*
Results from various merges:

data1
 not matched                        75
 from master                        44     (_merge==1)
 from using                         31     (_merge==2)
 matched                            14,880 (_merge==3)

	
data2 
 not matched                        199
 from master                        104    (_merge==1)
 from using                         95     (_merge==2)
 matched                            4,521  (_merge==3)

 
 data3
  not matched                       8
  from master                       3      (_merge==1)
  from using                        5      (_merge==2)
  matched                           3,798  (_merge==3)
 
 
 data4
  not matched                       152
  from master                       75     (_merge==1)
  from using                        77     (_merge==2)
  matched                           5,508  (_merge==3)

  
The largest % difference in the samples are in FRA and UK (WALES). So 
  the differences in the model are due to differences in the underlying
  data. This makes sense, as the code is essentially identical, and confirms
  that the one or two changes I made in the code running the models (changing casing of 
  three variables) doesn't seem to have mattered.

 Clearly, something else in the setup files has changed, and these changes
   mattered for the multisward analysis (which had already been run).
 
 */
}
