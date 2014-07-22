/*
TODO

1 table  NM GO DC OH
3 tables GO, DC, OH
all over time
all reporting shares (components % of GO, DC, OH, DC OH share of GO)
all reporting in per ha, per lu, and per labu
*/

capture log close
capture cmdlog close

********************************************************************************************
* Generating share variables
********************************************************************************************

* Clear out vars created below, so file can be run repeatedly
capture drop ddfeedgl 
capture drop ddfeedpp 	
capture drop ddothlivsc
capture drop ddseeds 	
capture drop ddfert 	
capture drop ddcroppro 	
capture drop ddothcrop 	
capture drop ddforestsc 	
capture drop sh_feedgl 	
capture drop sh_feedpp 	
capture drop sh_othlivsc 	
capture drop sh_seeds 	
capture drop sh_fert 	
capture drop sh_croppro 	
capture drop sh_othcrop 	
capture drop sh_forestsc 	
capture drop ddfeedgl_ha 	
capture drop ddfeedpp_ha 	
capture drop ddothlivsc_ha 	
capture drop ddseeds_ha 	
capture drop ddfert_ha 	
capture drop ddcroppro_ha 	
capture drop ddothcrop_ha 	
capture drop ddforestsc_ha
capture drop sh_ddfeedgl 	
capture drop sh_ddfeedpp 	
capture drop sh_ddothlivsc 	
capture drop sh_ddseeds 	
capture drop sh_ddfert 	
capture drop sh_ddcroppro 	
capture drop sh_ddothcrop 	
capture drop sh_ddforestsc 	
capture drop dohcontwork  	
capture drop dohmchbldcurr 	
capture drop dohenergy 	
capture drop dohothdirin 	
capture drop dohdep 		
capture drop dohwages 	
capture drop dohrent 	
capture drop dohintst 	
capture drop sh_contwork 	
capture drop sh_mchbldcurr 	
capture drop sh_energy 	
capture drop sh_othdirin 	
capture drop sh_dep 		
capture drop sh_wages 	
capture drop sh_rent 	
capture drop sh_intst	
capture drop sh_dohcontwork  	
capture drop sh_dohmchbldcurr 	
capture drop sh_dohenergy 	
capture drop sh_dohothdirin 	
capture drop sh_dohdep 		
capture drop sh_dohwages 	
capture drop sh_dohrent 	
capture drop sh_dohintst 	
capture drop sh_dc_farmgo
capture drop sh_dc_fdairygo
capture drop sh_oh_farmgo
capture drop sh_oh_fdairygo
capture drop dohcontwork_ha 
capture drop dohmchbldcurr_ha 
capture drop dohenergy_ha 
capture drop dohothdirin_ha 
capture drop dohdep_ha 
capture drop dohwages_ha 
capture drop dohrent_ha 
capture drop dohintst_ha 


*-----------------------------------------------------------------------
* Allocate components of GO, DC, OH
*-----------------------------------------------------------------------

* GO

* DC
gen ddfeedgl = feedforgrazinglivestock * dpalloclu
gen ddfeedpp = feedforpigspoultry * dpalloclu
gen ddothlivsc = otherlivestockspecificcosts * dpalloclu
gen ddseeds = seedsandplants * dpalloclu
gen ddfert = fertilisers * dpalloclu
gen ddcroppro = cropprotection * dpalloclu
gen ddothcrop = othercropspecific * dpalloclu
gen ddforestsc = forestryspecificcosts * dpalloclu

*OH
gen dohcontwork = contractwork * dpalloclu
gen dohmchbldcurr = machininerybuildingcurrentcosts * dpalloclu
gen dohenergy = energy * dpalloclu
gen dohothdirin = otherdirectinputs * dpalloclu
gen dohdep = depreciation * dpalloclu
gen dohwages = wagespaid * dpalloclu
gen dohrent = rentpaid * dpalloclu
gen dohintst = interestpaid * dpalloclu


*-----------------------------------------------------------------------
* Shares of GO, DC, OH
*-----------------------------------------------------------------------
* Shares of GO (whole farm level)
gen sh_dc_farmgo = farmdc/farmgo
gen sh_oh_farmgo = farmohct/farmgo

* Shares of GO (enterprise level)
gen sh_dc_fdairygo = fdairydc/fdairygo
gen sh_oh_fdairygo = fdairyoh/fdairygo

* Shares of DC (whole farm level)
gen sh_feedgl = feedforgrazinglivestock/farmdc
gen sh_feedpp = feedforpigspoultry/farmdc
gen sh_othlivsc = otherlivestockspecificcosts/farmdc
gen sh_seeds = seedsandplants/farmdc
gen sh_fert = fertilisers/farmdc
gen sh_croppro = cropprotection/farmdc
gen sh_othcrop = othercropspecific/farmdc
gen sh_forestsc = forestryspecificcosts/farmdc

* Shares of DC (enterprise level)
gen sh_ddfeedgl = ddfeedgl/fdairydc
gen sh_ddfeedpp = ddfeedpp/fdairydc
gen sh_ddothlivsc = ddothlivsc/fdairydc
gen sh_ddseeds = ddseeds/fdairydc
gen sh_ddfert = ddfert/fdairydc
gen sh_ddcroppro = ddcroppro/fdairydc
gen sh_ddothcrop = ddothcro/fdairydc
gen sh_ddforestsc = ddforests/fdairydc


* Shares of OH (whole farm level)
gen sh_contwork = contractwork/farmohct
gen sh_mchbldcurr = machininerybuildingcurrentcosts/farmohct
gen sh_energy = energy/farmohct
gen sh_othdirin = otherdirectinputs/farmohct
gen sh_dep = depreciation/farmohct
gen sh_wages = wagespaid/farmohct
gen sh_rent = rentpaid/farmohct
gen sh_intst = interestpaid/farmohct


* Shares of OH (enterprise level)
gen sh_dohcontwork = dohcontwork/fdairyoh
gen sh_dohmchbldcurr = dohmchbldcurr/fdairyoh
gen sh_dohenergy = dohenergy/fdairyoh
gen sh_dohothdirin = dohothdirin/fdairyoh
gen sh_dohdep = dohdep/fdairyoh
gen sh_dohwages = dohwages/fdairyoh
gen sh_dohrent = dohrent/fdairyoh
gen sh_dohintst = dohintst/fdairyoh


*-----------------------------------------------------------------------
* Scaled units GO, DC, OH
*-----------------------------------------------------------------------

* Per hectare components of DC (enterprise level)
gen ddfeedgl_ha  	= ddfeedgl/daforare  		
gen ddfeedpp_ha  	= ddfeedpp/daforare  		
gen ddothlivsc_ha  	= ddothlivsc/daforare  		
gen ddseeds_ha  	= ddseeds/daforare  		
gen ddfert_ha  		= ddfert/daforare  		
gen ddcroppro_ha  	= ddcroppro/daforare  		
gen ddothcrop_ha  	= ddothcrop/daforare  		
gen ddforestsc_ha 	= ddforestsc/daforare  		

	
* Per hectare components of OH (enterprise level)
gen dohcontwork_ha = dohcontwork/daforare  		
gen dohmchbldcurr_ha = dohmchbldcurr/daforare  		
gen dohenergy_ha = dohenergy/daforare  		
gen dohothdirin_ha = dohothdirin/daforare  		
gen dohdep_ha = dohdep/daforare  		
gen dohwages_ha = dohwages/daforare  		
gen dohrent_ha = dohrent/daforare  		
gen dohintst_ha = dohintst/daforare  		

*/



	tabstat								/// 
	fdairydc_ha							///
	ddfeedgl_ha     					        /// 
	ddfeedpp_ha 							/// 
	ddothlivsc_ha 							/// 
	ddseeds_ha  	                 				/// 
	ddfert_ha 						        ///
	ddcroppro_ha 							///
	ddothcrop_ha 							///
	ddforestsc_ha 							///
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh_ha							///
	dohcontwork_ha 							///
	dohmchbldcurr_ha 					        ///
	dohenergy_ha 							///
	dohothdirin_ha 							///
	dohdep_ha 					         	///
	dohwages_ha 							///
	dohrent_ha 							///
	dohintst_ha 							///
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	


	tabstat								/// 
	fdairydc_ha							///
	ddfeedgl_ha     					        /// 
	ddfeedpp_ha 							/// 
	ddothlivsc_ha 							/// 
	ddseeds_ha  	                 				/// 
	ddfert_ha 						        ///
	ddcroppro_ha 							///
	ddothcrop_ha 							///
	ddforestsc_ha 							///
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh_ha							///
	dohcontwork_ha 							///
	dohmchbldcurr_ha 					        ///
	dohenergy_ha 							///
	dohothdirin_ha 							///
	dohdep_ha 					         	///
	dohwages_ha 							///
	dohrent_ha 							///
	dohintst_ha 							///
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	


	tabstat								/// 
	fdairydc_ha							///
	ddfeedgl_ha     					        /// 
	ddfeedpp_ha 							/// 
	ddothlivsc_ha 							/// 
	ddseeds_ha  	                 				/// 
	ddfert_ha 						        ///
	ddcroppro_ha 							///
	ddothcrop_ha 							///
	ddforestsc_ha 							///
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh_ha							///
	dohcontwork_ha 							///
	dohmchbldcurr_ha 					        ///
	dohenergy_ha 							///
	dohothdirin_ha 							///
	dohdep_ha 					         	///
	dohwages_ha 							///
	dohrent_ha 							///
	dohintst_ha 							///
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	




	tabstat								/// 
	fdairydc_ha							///
	ddfeedgl_ha     					        /// 
	ddfeedpp_ha 							/// 
	ddothlivsc_ha 							/// 
	ddseeds_ha  	                 				/// 
	ddfert_ha 						        ///
	ddcroppro_ha 							///
	ddothcrop_ha 							///
	ddforestsc_ha 							///
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh_ha							///
	dohcontwork_ha 							///
	dohmchbldcurr_ha 					        ///
	dohenergy_ha 							///
	dohothdirin_ha 							///
	dohdep_ha 					         	///
	dohwages_ha 							///
	dohrent_ha 							///
	dohintst_ha 							///
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	


	tabstat								/// 
	fdairydc_ha							///
	ddfeedgl_ha     					        /// 
	ddfeedpp_ha 							/// 
	ddothlivsc_ha 							/// 
	ddseeds_ha  	                 				/// 
	ddfert_ha 						        ///
	ddcroppro_ha 							///
	ddothcrop_ha 							///
	ddforestsc_ha 							///
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh_ha							///
	dohcontwork_ha 							///
	dohmchbldcurr_ha 					        ///
	dohenergy_ha 							///
	dohothdirin_ha 							///
	dohdep_ha 					         	///
	dohwages_ha 							///
	dohrent_ha 							///
	dohintst_ha 							///
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	


	tabstat								/// 
	fdairydc_ha							///
	ddfeedgl_ha     					        /// 
	ddfeedpp_ha 							/// 
	ddothlivsc_ha 							/// 
	ddseeds_ha  	                 				/// 
	ddfert_ha 						        ///
	ddcroppro_ha 							///
	ddothcrop_ha 							///
	ddforestsc_ha 							///
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh_ha							///
	dohcontwork_ha 							///
	dohmchbldcurr_ha 					        ///
	dohenergy_ha 							///
	dohothdirin_ha 							///
	dohdep_ha 					         	///
	dohwages_ha 							///
	dohrent_ha 							///
	dohintst_ha 							///
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	



*-------------------------------------
/*
********************************************************************************************
* Ireland
********************************************************************************************

log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/nmcomponents.txt", replace text
*-----------------------------------------------------------------------
* Enterprise level values
*-----------------------------------------------------------------------

* Components of NM
*-------------------------------------
* Small herd group (whole enterprise)
tabstat fdairynm  fdairygo fdairydc fdairyoh if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group (whole enterprise)
tabstat fdairynm  fdairygo fdairydc fdairyoh if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)

* Large herd group (whole enterprise)
tabstat fdairynm  fdairygo fdairydc fdairyoh if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
*-------------------------------------
* Small herd group (per ha)
tabstat nm_ha1  fdairygo_ha fdairydc_ha fdairyoh_ha if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group (per ha)
tabstat nm_ha1   fdairygo_ha fdairydc_ha fdairyoh_ha if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)

* Large herd group (per ha)
tabstat nm_ha1   fdairygo_ha fdairydc_ha fdairyoh_ha if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
*-------------------------------------
* Small herd group (per lu)
tabstat nm_lu1 fdairynm  fdairygo_lu fdairydc_lu fdairyoh_lu if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group (per lu)
tabstat nm_lu1 fdairynm  fdairygo_lu fdairydc_lu fdairyoh_lu if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)

* Large herd group (per lu)
tabstat nm_lu1 fdairynm  fdairygo_lu fdairydc_lu fdairyoh_lu if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
*-------------------------------------
* Small herd group (per labu)
tabstat nm_labu1 fdairygo_labu fdairydc_labu fdairyoh_labu if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group  (per labu)
tabstat nm_labu1 fdairygo_labu fdairydc_labu fdairyoh_labu if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)

* Large herd group (per labu)
tabstat nm_labu1 fdairygo_labu fdairydc_labu fdairyoh_labu if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)

log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/entdecomp.txt", text replace

*-----------------------------------------------------------------------
* Enterprise level shares
*-----------------------------------------------------------------------


	* Small herd group
	tabstat								/// 
	fdairygo		 						///
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairydc								///
	sh_ddfeedgl     						/// sh_feedgl = feedforgrazinglivestock/fdairydc
	sh_ddfeedpp 							/// sh_feedpp = feedforpigspoultry/fdairydc
	sh_ddothlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/fdairydc
	sh_ddseeds  	                 		/// sh_seeds = seedsandplants/fdairydc
	sh_ddfert 							/// sh_fert = fertilisers/fdairydc
	sh_ddcroppro 							/// sh_croppro = cropprotection/fdairydc
	sh_ddothcrop 							/// sh_othcrop = othercropspecific/fdairydc
	sh_ddforestsc 						/// sh_forestsc = forestryspecificcosts/fdairydc
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh								///
	sh_dohcontwork 						/// sh_contwork = contractwork/fdairyoh
	sh_dohmchbldcurr 						/// sh_mchbldcurr = machininerybuildingcurrentcosts/fdairyoh
	sh_dohenergy 							/// gen = energy/fdairyoh
	sh_dohothdirin 						/// sh_othdirin = otherdirectinputs/fdairyoh
	sh_dohdep 								/// sh_dep = depreciation/fdairyoh
	sh_dohwages 							/// sh_wages = wagespaid/fdairyoh
	sh_dohrent 							/// sh_rent = rentpaid/fdairyoh
	sh_dohintst 							/// sh_intst = interestpaid/fdairyoh
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	
	* Moderate herd group
	tabstat								/// 
	fdairygo		 						///
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	

	tabstat								/// 
	fdairydc								///
	sh_ddfeedgl     						/// sh_feedgl = feedforgrazinglivestock/fdairydc
	sh_ddfeedpp 							/// sh_feedpp = feedforpigspoultry/fdairydc
	sh_ddothlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/fdairydc
	sh_ddseeds  	                 		/// sh_seeds = seedsandplants/fdairydc
	sh_ddfert 							/// sh_fert = fertilisers/fdairydc
	sh_ddcroppro 							/// sh_croppro = cropprotection/fdairydc
	sh_ddothcrop 							/// sh_othcrop = othercropspecific/fdairydc
	sh_ddforestsc 						/// sh_forestsc = forestryspecificcosts/fdairydc
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh								///
	sh_dohcontwork 						/// sh_contwork = contractwork/fdairyoh
	sh_dohmchbldcurr 						/// sh_mchbldcurr = machininerybuildingcurrentcosts/fdairyoh
	sh_dohenergy 							/// gen = energy/fdairyoh
	sh_dohothdirin 						/// sh_othdirin = otherdirectinputs/fdairyoh
	sh_dohdep 								/// sh_dep = depreciation/fdairyoh
	sh_dohwages 							/// sh_wages = wagespaid/fdairyoh
	sh_dohrent 							/// sh_rent = rentpaid/fdairyoh
	sh_dohintst 							/// sh_intst = interestpaid/fdairyoh
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
		
	
	* Large herd group
	tabstat								/// 
	fdairygo		 						///
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)

	tabstat								///
	fdairydc								///
	sh_ddfeedgl     						/// sh_feedgl = feedforgrazinglivestock/fdairydc
	sh_ddfeedpp 							/// sh_feedpp = feedforpigspoultry/fdairydc
	sh_ddothlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/fdairydc
	sh_ddseeds  	                 		/// sh_seeds = seedsandplants/fdairydc
	sh_ddfert 							/// sh_fert = fertilisers/fdairydc
	sh_ddcroppro 							/// sh_croppro = cropprotection/fdairydc
	sh_ddothcrop 							/// sh_othcrop = othercropspecific/fdairydc
	sh_ddforestsc 						/// sh_forestsc = forestryspecificcosts/fdairydc	
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh								///
	sh_dohcontwork 						/// sh_contwork = contractwork/fdairyoh
	sh_dohmchbldcurr 						/// sh_mchbldcurr = machininerybuildingcurrentcosts/fdairyoh
	sh_dohenergy 							/// gen = energy/fdairyoh
	sh_dohothdirin 						/// sh_othdirin = otherdirectinputs/fdairyoh
	sh_dohdep 								/// sh_dep = depreciation/fdairyoh
	sh_dohwages 							/// sh_wages = wagespaid/fdairyoh
	sh_dohrent 							/// sh_rent = rentpaid/fdairyoh
	sh_dohintst 							/// sh_intst = interestpaid/fdairyoh
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)

log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/entsh_go.txt", text replace
tabstat sh_dc_fdairygo sh_oh_fdairygo	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
tabstat sh_dc_fdairygo sh_oh_fdairygo 	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
tabstat sh_dc_fdairygo sh_oh_fdairygo 	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)



log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/farmdecomp.txt", text replace

*-----------------------------------------------------------------------
* Whole farm level shares
*-----------------------------------------------------------------------


	* Small herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmdc								///
	sh_feedgl     						/// sh_feedgl = feedforgrazinglivestock/farmdc
	sh_feedpp 							/// sh_feedpp = feedforpigspoultry/farmdc
	sh_othlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/farmdc
	sh_seeds  	                 		/// sh_seeds = seedsandplants/farmdc
	sh_fert 							/// sh_fert = fertilisers/farmdc
	sh_croppro 							/// sh_croppro = cropprotection/farmdc
	sh_othcrop 							/// sh_othcrop = othercropspecific/farmdc
	sh_forestsc 						/// sh_forestsc = forestryspecificcosts/farmdc
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmohct								///
	sh_contwork 						/// sh_contwork = contractwork/farmohct
	sh_mchbldcurr 						/// sh_mchbldcurr = machininerybuildingcurrentcosts/farmohct
	sh_energy 							/// gen = energy/farmohct
	sh_othdirin 						/// sh_othdirin = otherdirectinputs/farmohct
	sh_dep 								/// sh_dep = depreciation/farmohct
	sh_wages 							/// sh_wages = wagespaid/farmohct
	sh_rent 							/// sh_rent = rentpaid/farmohct
	sh_intst 							/// sh_intst = interestpaid/farmohct
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	
	* Moderate herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)

	tabstat								/// 
	farmdc								///
	sh_feedgl     						/// sh_feedgl = feedforgrazinglivestock/farmdc
	sh_feedpp 							/// sh_feedpp = feedforpigspoultry/farmdc
	sh_othlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/farmdc
	sh_seeds  	                 		/// sh_seeds = seedsandplants/farmdc
	sh_fert 							/// sh_fert = fertilisers/farmdc
	sh_croppro 			farmgo				/// sh_croppro = cropprotection/farmdc
	sh_othcrop 							/// sh_othcrop = othercropspecific/farmdc
	sh_forestsc 						/// sh_forestsc = forestryspecificcosts/farmdc
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmohct			farmgo					///
	sh_contwork 						/// sh_contwork = contractwork/farmohct
	sh_mchbldcurr 						/// sh_mchbldcurr = machininerybuildingcurrentcosts/farmohct
	sh_energy 							/// gen = energy/farmohct
	sh_othdirin 						/// sh_othdirin = otherdirectinputs/farmohct
	sh_dep 								/// sh_dep = depreciation/farmohct
	sh_wages 							/// sh_wages = wagespaid/farmohct
	sh_rent 							/// sh_rent = rentpaid/farmohct
	sh_intst 							/// sh_intst = interestpaid/farmohct
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
		
	
	* Large herd groupfarmgo
	tabstat								/// 
	farmgo		 						///
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)

	tabstat								///
	farmdc								///
	sh_feedgl     						/// sh_feedgl = feedforgrazinglivestock/farmdc
	sh_feedpp 							/// sh_feedpp = feedforpigspoultry/farmdc
	sh_othlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/farmdc
	sh_seeds  	                 		/// sh_seeds = seedsandplants/farmdc
	sh_fert 							/// sh_fert = fertilisers/farmdc
	sh_croppro 			farmgo				/// sh_croppro = cropprotection/farmdc
	sh_othcrop 							/// sh_othcrop = othercropspecific/farmdc
	sh_forestsc 						/// sh_forestsc = forestryspecificcosts/farmdc	
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmohct								///
	sh_contwork 						/// sh_contwork = contractwork/farmohct
	sh_mchbldcurr 						/// sh_mchbldcurr = machininerybuildingcurrentcosts/farmohct
	sh_energy 							/// gen = energy/farmohct
	sh_othdirin 						/// sh_othdirin = otherdirectinputs/farmohct
	sh_dep 								/// sh_dep = depreciation/farmohct
	sh_wages 			farmgo				/// sh_wages = wagespaid/farmohct
	sh_rent 							/// sh_rent = rentpaid/farmohct
	sh_intst 							/// sh_intst = interestpaid/farmohct
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	

log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/farmsh_go.txt", text replace
tabstat sh_dc_farmgo sh_oh_farmgo 	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
tabstat sh_dc_farmgo sh_oh_farmgo 	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
tabstat sh_dc_farmgo sh_oh_farmgo 	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)



	
	
********************************************************************************************
* NORTHERN IRELAND
********************************************************************************************

log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/nmcomponents.txt", text append
*-----------------------------------------------------------------------
* Enterprise level
*-----------------------------------------------------------------------

*-------------------------------------
* Components of NM
*-------------------------------------
* Small herd group (whole enterprise)
tabstat fdairynm  fdairygo fdairydc fdairyoh if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group (whole enterprise)
tabstat fdairynm  fdairygo fdairydc fdairyoh if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)

* Large herd group (whole enterprise)
tabstat fdairynm  fdairygo fdairydc fdairyoh if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
*-------------------------------------
* Small herd group (per ha)
tabstat nm_ha1  fdairygo_ha fdairydc_ha fdairyoh_ha if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group (per ha)
tabstat nm_ha1   fdairygo_ha fdairydc_ha fdairyoh_ha if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)

* Large herd group (per ha)
tabstat nm_ha1   fdairygo_ha fdairydc_ha fdairyoh_ha if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
*-------------------------------------
* Small herd group (per lu)
tabstat nm_lu1 fdairynm  fdairygo_lu fdairydc_lu fdairyoh_lu if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group (per lu)
tabstat nm_lu1 fdairynm  fdairygo_lu fdairydc_lu fdairyoh_lu if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)

* Large herd group (per lu)
tabstat nm_lu1 fdairynm  fdairygo_lu fdairydc_lu fdairyoh_lu if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
*-------------------------------------
* Small herd group (per labu)
tabstat nm_labu1 fdairygo_labu fdairydc_labu fdairyoh_labu if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

* Moderate herd group  (per labu)
tabstat nm_labu1 fdairygo_labu fdairydc_labu fdairyoh_labu if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)

* Large herd group (per labu)
tabstat nm_labu1 fdairygo_labu fdairydc_labu fdairyoh_labu if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)

log close 
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/entdecomp.txt", text append
*-----------------------------------------------------------------------
* Enterprise level shares
*-----------------------------------------------------------------------
*Components of GO, DC, OH
	* Small herd group
	
	tabstat								/// 
	fdairygo		 						///
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

	tabstat								///
	fdairydc								///
	sh_ddfeedgl     						///
	sh_ddfeedpp 							///
	sh_ddothlivsc 						/// 
	sh_ddseeds  	                 		/// 
	sh_ddfert 							/// 
	sh_ddcroppro 							/// 
	sh_ddothcrop 							/// 
	sh_ddforestsc 						/// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh								///
	sh_dohcontwork 						///
	sh_dohmchbldcurr 						///
	sh_dohenergy 							///
	sh_dohothdirin 						/// 
	sh_dohdep 								///
	sh_dohwages 							/// 
	sh_dohrent 							/// 
	sh_dohintst 							/// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	

	* Moderate herd group
	tabstat								/// 
	fdairygo		 						///
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean)by(year)
	
	tabstat								/// 
	fdairydc								///
	sh_ddfeedgl     						///
	sh_ddfeedpp 							///
	sh_ddothlivsc 						/// 
	sh_ddseeds  	                 		/// 
	sh_ddfert 							/// 
	sh_ddcroppro 							/// 
	sh_ddothcrop 							/// 
	sh_ddforestsc 							///
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh							///
	sh_dohcontwork 							/// 
	sh_dohmchbldcurr 							/// 
	sh_dohenergy 							/// 
	sh_dohothdirin 							/// 
	sh_dohdep 								/// 
	sh_dohwages 							/// 
	sh_dohrent 							/// 
	sh_dohintst 							/// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	
	* Large herd group
	tabstat								/// 
	fdairygo		 						///
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairydc								///
	sh_ddfeedgl     							/// 
	sh_ddfeedpp 							/// 
	sh_ddothlivsc 							/// 
	sh_ddseeds  	                 				/// 
	sh_ddfert 							/// 
	sh_ddcroppro 							/// 
	sh_ddothcrop 							/// 
	sh_ddforestsc 							/// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	fdairyoh							///
	sh_dohcontwork 							/// 
	sh_dohmchbldcurr 							/// 
	sh_dohenergy 							/// 
	sh_dohothdirin 							/// 
	sh_dohdep 								/// 
	sh_dohwages 							///
	sh_dohrent 							///
	sh_dohintst 							///
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)

log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/entsh_go.txt", text append
tabstat sh_dc_fdairygo sh_oh_fdairygo	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
tabstat sh_dc_fdairygo sh_oh_fdairygo 	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
tabstat sh_dc_fdairygo sh_oh_fdairygo 	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)

log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/farmdecomp.txt", text append
*-----------------------------------------------------------------------
* Whole farm level shares
*-----------------------------------------------------------------------


	* Small herd group
	
	tabstat								/// 
	farmgo		 						///
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)

	tabstat								///
	farmdc								///
	sh_feedgl     						/// sh_feedgl = feedforgrazinglivestock/farmdc    
	sh_feedpp 							/// sh_feedpp = feedforpigspoultry/farmdc 
	sh_othlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/farmdc
	sh_seeds  	                 		/// sh_seeds = seedsandplants/farmdc
	sh_fert 							/// sh_fert = fertilisers/farmdc
	sh_croppro 							/// sh_croppro = cropprotection/farmdc
	sh_othcrop 							/// sh_othcrop = othercropspecific/farmdc
	sh_forestsc 						/// sh_forestsc = forestryspecificcosts/farmdc	
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmohct								///
	sh_contwork 						/// sh_contwork = contractwork/farmohct
	sh_mchbldcurr 						/// sh_mchbldcurr = machininerybuildingcurrentcosts/farmohct
	sh_energy 							/// gen = energy/farmohct
	sh_othdirin 						/// sh_othdirin = otherdirectinputs/farmohct
	sh_dep 								/// sh_dep = depreciation/farmohct
	sh_wages 							/// sh_wages = wagespaid/farmohct
	sh_rent 							/// sh_rent = rentpaid/farmohct
	sh_intst 							/// sh_intst = interestpaid/farmohct
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	

	* Moderate herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean)by(year)
	
	tabstat								/// 
	farmdc								///
	sh_feedgl     						/// sh_feedgl = feedforgrazinglivestock/farmdc
	sh_feedpp 							/// sh_feedpp = feedforpigspoultry/farmdc
	sh_othlivsc 						/// sh_othlivsc = otherlivestockspecificcosts/farmdc
	sh_seeds  	                 		/// sh_seeds = seedsandplants/farmdc
	sh_fert 							/// sh_fert = fertilisers/farmdc
	sh_croppro 							/// sh_croppro = cropprotection/farmdc
	sh_othcrop 							/// sh_othcrop = othercropspecific/farmdc
	sh_forestsc 							/// sh_forestsc = forestryspecificcosts/farmdc	
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmohct							///
	sh_contwork 							/// sh_contwork = contractwork/farmohct
	sh_mchbldcurr 							/// sh_mchbldcurr = machininerybuildingcurrentcosts/farmohct
	sh_energy 							/// gen = energy/farmohct
	sh_othdirin 							/// sh_othdirin = otherdirectinputs/farmohct
	sh_dep 								/// sh_dep = depreciation/farmohct
	sh_wages 							/// sh_wages = wagespaid/farmohct
	sh_rent 							/// sh_rent = rentpaid/farmohct
	sh_intst 							/// sh_intst = interestpaid/farmohct	
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	
	* Large herd group
	tabstat								/// 
	farmgo		 						///
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmdc								///
	sh_feedgl     							/// sh_feedgl = feedforgrazinglivestock/farmdc
	sh_feedpp 							/// sh_feedpp = feedforpigspoultry/farmdc
	sh_othlivsc 							/// sh_othlivsc = otherlivestockspecificcosts/farmdc
	sh_seeds  	                 				/// sh_seeds = seedsandplants/farmdc
	sh_fert 							/// sh_fert = fertilisers/farmdc
	sh_croppro 							/// sh_croppro = cropprotection/farmdc
	sh_othcrop 							/// sh_othcrop = othercropspecific/farmdc
	sh_forestsc 							/// sh_forestsc = forestryspecificcosts/farmdc	
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat								/// 
	farmohct							///
	sh_contwork 							/// sh_contwork = contractwork/farmohct
	sh_mchbldcurr 							/// sh_mchbldcurr = machininerybuildingcurrentcosts/farmohct
	sh_energy 							/// gen = energy/farmohct
	sh_othdirin 							/// sh_othdirin = otherdirectinputs/farmohct
	sh_dep 								/// sh_dep = depreciation/farmohct
	sh_wages 							/// sh_wages = wagespaid/farmohct
	sh_rent 							/// sh_rent = rentpaid/farmohct
	sh_intst 							/// sh_intst = interestpaid/farmohct
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
log close
log using "D:\Data/data_FADNPanelAnalysis/Do_Files/IGM/farmsh_go.txt", text append
tabstat sh_dc_farmgo sh_oh_farmgo 	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
tabstat sh_dc_farmgo sh_oh_farmgo 	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
tabstat sh_dc_farmgo sh_oh_farmgo 	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)

log close
*/
