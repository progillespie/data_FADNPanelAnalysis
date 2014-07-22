args bmw
/*
 - Makes tables of decompositions at enterprise level
 - Uses exchange rate adjustment
 - Scaled to per litre units
*/

capture log close
capture cmdlog close

log using "cex_`bmw'entdecomp_lt.txt", replace text

********************************************************************************************
* Ireland
********************************************************************************************

	* Small herd (IE)
	tabstat           /// 
	cex_fdairydc_lt   /// 
	cex_ddfeedgl_lt   /// 
	cex_ddfeedpp_lt   /// 
	cex_ddothlivsc_lt /// 
	cex_ddseeds_lt    /// 
	cex_ddfert_lt     /// 
	cex_ddcroppro_lt  /// 
	cex_ddothcrop_lt  /// 
	cex_ddforestsc_lt /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lt      /// 
	cex_dohcontwork_lt   /// 
	cex_dohmchbldcurr_lt /// 
	cex_dohenergy_lt     /// 
	cex_dohothdirin_lt   /// 
	cex_dohdep_lt        /// 
	cex_dohwages_lt      /// 
	cex_dohrent_lt       /// 
	cex_dohintst_lt      /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	

	* Moderate herd (IE)
	tabstat           /// 
	cex_fdairydc_lt   /// 
	cex_ddfeedgl_lt   /// 
	cex_ddfeedpp_lt   /// 
	cex_ddothlivsc_lt /// 
	cex_ddseeds_lt    /// 
	cex_ddfert_lt     /// 
	cex_ddcroppro_lt  /// 
	cex_ddothcrop_lt  /// 
	cex_ddforestsc_lt /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lt      /// 
	cex_dohcontwork_lt   /// 
	cex_dohmchbldcurr_lt /// 
	cex_dohenergy_lt     /// 
	cex_dohothdirin_lt   /// 
	cex_dohdep_lt        /// 
	cex_dohwages_lt      /// 
	cex_dohrent_lt       /// 
	cex_dohintst_lt      /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	

	* Large herd (IE)
	tabstat           /// 
	cex_fdairydc_lt   /// 
	cex_ddfeedgl_lt   /// 
	cex_ddfeedpp_lt   /// 
	cex_ddothlivsc_lt /// 
	cex_ddseeds_lt    /// 
	cex_ddfert_lt     /// 
	cex_ddcroppro_lt  /// 
	cex_ddothcrop_lt  /// 
	cex_ddforestsc_lt /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lt      /// 
	cex_dohcontwork_lt   /// 
	cex_dohmchbldcurr_lt /// 
	cex_dohenergy_lt     /// 
	cex_dohothdirin_lt   /// 
	cex_dohdep_lt        /// 
	cex_dohwages_lt      /// 
	cex_dohrent_lt       /// 
	cex_dohintst_lt      /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	



********************************************************************************************
* Northern Ireland
********************************************************************************************


	* Small herd (NI)
	tabstat           /// 
	cex_fdairydc_lt   /// 
	cex_ddfeedgl_lt   /// 
	cex_ddfeedpp_lt   /// 
	cex_ddothlivsc_lt /// 
	cex_ddseeds_lt    /// 
	cex_ddfert_lt     /// 
	cex_ddcroppro_lt  /// 
	cex_ddothcrop_lt  /// 
	cex_ddforestsc_lt /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lt      /// 
	cex_dohcontwork_lt   /// 
	cex_dohmchbldcurr_lt /// 
	cex_dohenergy_lt     /// 
	cex_dohothdirin_lt   /// 
	cex_dohdep_lt        /// 
	cex_dohwages_lt      /// 
	cex_dohrent_lt       /// 
	cex_dohintst_lt      /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	


	* Moderate herd (NI)
	tabstat           /// 
	cex_fdairydc_lt   /// 
	cex_ddfeedgl_lt   /// 
	cex_ddfeedpp_lt   /// 
	cex_ddothlivsc_lt /// 
	cex_ddseeds_lt    /// 
	cex_ddfert_lt     /// 
	cex_ddcroppro_lt  /// 
	cex_ddothcrop_lt  /// 
	cex_ddforestsc_lt /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lt      /// 
	cex_dohcontwork_lt   /// 
	cex_dohmchbldcurr_lt /// 
	cex_dohenergy_lt     /// 
	cex_dohothdirin_lt   /// 
	cex_dohdep_lt        /// 
	cex_dohwages_lt      /// 
	cex_dohrent_lt       /// 
	cex_dohintst_lt      /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	


	* Large herd (NI)
	tabstat           /// 
	cex_fdairydc_lt   /// 
	cex_ddfeedgl_lt   /// 
	cex_ddfeedpp_lt   /// 
	cex_ddothlivsc_lt /// 
	cex_ddseeds_lt    /// 
	cex_ddfert_lt     /// 
	cex_ddcroppro_lt  /// 
	cex_ddothcrop_lt  /// 
	cex_ddforestsc_lt /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lt      /// 
	cex_dohcontwork_lt   /// 
	cex_dohmchbldcurr_lt /// 
	cex_dohenergy_lt     /// 
	cex_dohothdirin_lt   /// 
	cex_dohdep_lt        /// 
	cex_dohwages_lt      /// 
	cex_dohrent_lt       /// 
	cex_dohintst_lt      /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	

log close
