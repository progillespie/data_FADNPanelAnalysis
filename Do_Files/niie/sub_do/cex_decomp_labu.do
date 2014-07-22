args bmw
/*
 - Makes tables of decompositions at enterprise level
 - Uses exchange rate adjustment
 - Scaled to labour units
*/

capture log close
capture cmdlog close

log using "cex_`bmw'entdecomp_labu1.txt", replace text

********************************************************************************************
* Ireland
********************************************************************************************

	* Small herd (IE)
	tabstat              /// 
	cex_fdairydc_labu1   /// 
	cex_ddfeedgl_labu1   /// 
	cex_ddfeedpp_labu1   /// 
	cex_ddothlivsc_labu1 /// 
	cex_ddseeds_labu1    /// 
	cex_ddfert_labu1     /// 
	cex_ddcroppro_labu1  /// 
	cex_ddothcrop_labu1  /// 
	cex_ddforestsc_labu1 /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat                 /// 
	cex_fdairyoh_labu1      /// 
	cex_dohcontwork_labu1   /// 
	cex_dohmchbldcurr_labu1 /// 
	cex_dohenergy_labu1     /// 
	cex_dohothdirin_labu1   /// 
	cex_dohdep_labu1        /// 
	cex_dohwages_labu1      /// 
	cex_dohrent_labu1       /// 
	cex_dohintst_labu1      /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	

	* Moderate herd (IE)
	tabstat              /// 
	cex_fdairydc_labu1   /// 
	cex_ddfeedgl_labu1   /// 
	cex_ddfeedpp_labu1   /// 
	cex_ddothlivsc_labu1 /// 
	cex_ddseeds_labu1    /// 
	cex_ddfert_labu1     /// 
	cex_ddcroppro_labu1  /// 
	cex_ddothcrop_labu1  /// 
	cex_ddforestsc_labu1 /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	tabstat                 /// 
	cex_fdairyoh_labu1      /// 
	cex_dohcontwork_labu1   /// 
	cex_dohmchbldcurr_labu1 /// 
	cex_dohenergy_labu1     /// 
	cex_dohothdirin_labu1   /// 
	cex_dohdep_labu1        /// 
	cex_dohwages_labu1      /// 
	cex_dohrent_labu1       /// 
	cex_dohintst_labu1      /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	

	* Large herd (IE)
	tabstat              /// 
	cex_fdairydc_labu1   /// 
	cex_ddfeedgl_labu1   /// 
	cex_ddfeedpp_labu1   /// 
	cex_ddothlivsc_labu1 /// 
	cex_ddseeds_labu1    /// 
	cex_ddfert_labu1     /// 
	cex_ddcroppro_labu1  /// 
	cex_ddothcrop_labu1  /// 
	cex_ddforestsc_labu1 /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	tabstat                 /// 
	cex_fdairyoh_labu1      /// 
	cex_dohcontwork_labu1   /// 
	cex_dohmchbldcurr_labu1 /// 
	cex_dohenergy_labu1     /// 
	cex_dohothdirin_labu1   /// 
	cex_dohdep_labu1        /// 
	cex_dohwages_labu1      /// 
	cex_dohrent_labu1       /// 
	cex_dohintst_labu1      /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	



********************************************************************************************
* Northern Ireland
********************************************************************************************


	* Small herd (NI)
	tabstat              /// 
	cex_fdairydc_labu1   /// 
	cex_ddfeedgl_labu1   /// 
	cex_ddfeedpp_labu1   /// 
	cex_ddothlivsc_labu1 /// 
	cex_ddseeds_labu1    /// 
	cex_ddfert_labu1     /// 
	cex_ddcroppro_labu1  /// 
	cex_ddothcrop_labu1  /// 
	cex_ddforestsc_labu1 /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat                 /// 
	cex_fdairyoh_labu1      /// 
	cex_dohcontwork_labu1   /// 
	cex_dohmchbldcurr_labu1 /// 
	cex_dohenergy_labu1     /// 
	cex_dohothdirin_labu1   /// 
	cex_dohdep_labu1        /// 
	cex_dohwages_labu1      /// 
	cex_dohrent_labu1       /// 
	cex_dohintst_labu1      /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	


	* Moderate herd (NI)
	tabstat              /// 
	cex_fdairydc_labu1   /// 
	cex_ddfeedgl_labu1   /// 
	cex_ddfeedpp_labu1   /// 
	cex_ddothlivsc_labu1 /// 
	cex_ddseeds_labu1    /// 
	cex_ddfert_labu1     /// 
	cex_ddcroppro_labu1  /// 
	cex_ddothcrop_labu1  /// 
	cex_ddforestsc_labu1 /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat                 /// 
	cex_fdairyoh_labu1      /// 
	cex_dohcontwork_labu1   /// 
	cex_dohmchbldcurr_labu1 /// 
	cex_dohenergy_labu1     /// 
	cex_dohothdirin_labu1   /// 
	cex_dohdep_labu1        /// 
	cex_dohwages_labu1      /// 
	cex_dohrent_labu1       /// 
	cex_dohintst_labu1      /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	


	* Large herd (NI)
	tabstat              /// 
	cex_fdairydc_labu1   /// 
	cex_ddfeedgl_labu1   /// 
	cex_ddfeedpp_labu1   /// 
	cex_ddothlivsc_labu1 /// 
	cex_ddseeds_labu1    /// 
	cex_ddfert_labu1     /// 
	cex_ddcroppro_labu1  /// 
	cex_ddothcrop_labu1  /// 
	cex_ddforestsc_labu1 /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat                 /// 
	cex_fdairyoh_labu1      /// 
	cex_dohcontwork_labu1   /// 
	cex_dohmchbldcurr_labu1 /// 
	cex_dohenergy_labu1     /// 
	cex_dohothdirin_labu1   /// 
	cex_dohdep_labu1        /// 
	cex_dohwages_labu1      /// 
	cex_dohrent_labu1       /// 
	cex_dohintst_labu1      /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	

log close
