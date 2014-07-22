args bmw
/*
 - Makes tables of decompositions at enterprise level
 - Uses exchange rate adjustment
 - Scaled to livestock units
*/

capture log close
capture cmdlog close

log using "cex_`bmw'entdecomp_lu.txt", replace text

********************************************************************************************
* Ireland
********************************************************************************************

	* Small herd (IE)
	tabstat           /// 
	cex_fdairydc_lu   /// 
	cex_ddfeedgl_lu   /// 
	cex_ddfeedpp_lu   /// 
	cex_ddothlivsc_lu /// 
	cex_ddseeds_lu    /// 
	cex_ddfert_lu     /// 
	cex_ddcroppro_lu  /// 
	cex_ddothcrop_lu  /// 
	cex_ddforestsc_lu /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lu      /// 
	cex_dohcontwork_lu   /// 
	cex_dohmchbldcurr_lu /// 
	cex_dohenergy_lu     /// 
	cex_dohothdirin_lu   /// 
	cex_dohdep_lu        /// 
	cex_dohwages_lu      /// 
	cex_dohrent_lu       /// 
	cex_dohintst_lu      /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	

	* Moderate herd (IE)
	tabstat           /// 
	cex_fdairydc_lu   /// 
	cex_ddfeedgl_lu   /// 
	cex_ddfeedpp_lu   /// 
	cex_ddothlivsc_lu /// 
	cex_ddseeds_lu    /// 
	cex_ddfert_lu     /// 
	cex_ddcroppro_lu  /// 
	cex_ddothcrop_lu  /// 
	cex_ddforestsc_lu /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lu      /// 
	cex_dohcontwork_lu   /// 
	cex_dohmchbldcurr_lu /// 
	cex_dohenergy_lu     /// 
	cex_dohothdirin_lu   /// 
	cex_dohdep_lu        /// 
	cex_dohwages_lu      /// 
	cex_dohrent_lu       /// 
	cex_dohintst_lu      /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	

	* Large herd (IE)
	tabstat           /// 
	cex_fdairydc_lu   /// 
	cex_ddfeedgl_lu   /// 
	cex_ddfeedpp_lu   /// 
	cex_ddothlivsc_lu /// 
	cex_ddseeds_lu    /// 
	cex_ddfert_lu     /// 
	cex_ddcroppro_lu  /// 
	cex_ddothcrop_lu  /// 
	cex_ddforestsc_lu /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lu      /// 
	cex_dohcontwork_lu   /// 
	cex_dohmchbldcurr_lu /// 
	cex_dohenergy_lu     /// 
	cex_dohothdirin_lu   /// 
	cex_dohdep_lu        /// 
	cex_dohwages_lu      /// 
	cex_dohrent_lu       /// 
	cex_dohintst_lu      /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	



********************************************************************************************
* Northern Ireland
********************************************************************************************


	* Small herd (NI)
	tabstat           /// 
	cex_fdairydc_lu   /// 
	cex_ddfeedgl_lu   /// 
	cex_ddfeedpp_lu   /// 
	cex_ddothlivsc_lu /// 
	cex_ddseeds_lu    /// 
	cex_ddfert_lu     /// 
	cex_ddcroppro_lu  /// 
	cex_ddothcrop_lu  /// 
	cex_ddforestsc_lu /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lu      /// 
	cex_dohcontwork_lu   /// 
	cex_dohmchbldcurr_lu /// 
	cex_dohenergy_lu     /// 
	cex_dohothdirin_lu   /// 
	cex_dohdep_lu        /// 
	cex_dohwages_lu      /// 
	cex_dohrent_lu       /// 
	cex_dohintst_lu      /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	


	* Moderate herd (NI)
	tabstat           /// 
	cex_fdairydc_lu   /// 
	cex_ddfeedgl_lu   /// 
	cex_ddfeedpp_lu   /// 
	cex_ddothlivsc_lu /// 
	cex_ddseeds_lu    /// 
	cex_ddfert_lu     /// 
	cex_ddcroppro_lu  /// 
	cex_ddothcrop_lu  /// 
	cex_ddforestsc_lu /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lu      /// 
	cex_dohcontwork_lu   /// 
	cex_dohmchbldcurr_lu /// 
	cex_dohenergy_lu     /// 
	cex_dohothdirin_lu   /// 
	cex_dohdep_lu        /// 
	cex_dohwages_lu      /// 
	cex_dohrent_lu       /// 
	cex_dohintst_lu      /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	


	* Large herd (NI)
	tabstat           /// 
	cex_fdairydc_lu   /// 
	cex_ddfeedgl_lu   /// 
	cex_ddfeedpp_lu   /// 
	cex_ddothlivsc_lu /// 
	cex_ddseeds_lu    /// 
	cex_ddfert_lu     /// 
	cex_ddcroppro_lu  /// 
	cex_ddothcrop_lu  /// 
	cex_ddforestsc_lu /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat              /// 
	cex_fdairyoh_lu      /// 
	cex_dohcontwork_lu   /// 
	cex_dohmchbldcurr_lu /// 
	cex_dohenergy_lu     /// 
	cex_dohothdirin_lu   /// 
	cex_dohdep_lu        /// 
	cex_dohwages_lu      /// 
	cex_dohrent_lu       /// 
	cex_dohintst_lu      /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	

log close
