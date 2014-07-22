args bmw
/*
 - Makes tables of decompositions at enterprise level
 - Uses exchange rate adjustment
*/



capture log close
capture cmdlog close

log using "cex_`bmw'entdecomp.txt", replace text

********************************************************************************************
* Ireland
********************************************************************************************

	* Small herd (IE)
	tabstat        /// 
	cex_fdairydc   /// 
	cex_ddfeedgl   /// 
	cex_ddfeedpp   /// 
	cex_ddothlivsc /// 
	cex_ddseeds    /// 
	cex_ddfert     /// 
	cex_ddcroppro  /// 
	cex_ddothcrop  /// 
	cex_ddforestsc /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat           /// 
	cex_fdairyoh      /// 
	cex_dohcontwork   /// 
	cex_dohmchbldcurr /// 
	cex_dohenergy     /// 
	cex_dohothdirin   /// 
	cex_dohdep        /// 
	cex_dohwages      /// 
	cex_dohrent       /// 
	cex_dohintst      /// 
	if cntry==1 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	

	* Moderate herd (IE)
	tabstat        /// 
	cex_fdairydc   /// 
	cex_ddfeedgl   /// 
	cex_ddfeedpp   /// 
	cex_ddothlivsc /// 
	cex_ddseeds    /// 
	cex_ddfert     /// 
	cex_ddcroppro  /// 
	cex_ddothcrop  /// 
	cex_ddforestsc /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	
	tabstat           /// 
	cex_fdairyoh      /// 
	cex_dohcontwork   /// 
	cex_dohmchbldcurr /// 
	cex_dohenergy     /// 
	cex_dohothdirin   /// 
	cex_dohdep        /// 
	cex_dohwages      /// 
	cex_dohrent       /// 
	cex_dohintst      /// 
	if cntry==1 & dpnolu > 45 & dpnolu <= 65 [weight=wt],stats(mean) by(year)
	

	* Large herd (IE)
	tabstat        /// 
	cex_fdairydc   /// 
	cex_ddfeedgl   /// 
	cex_ddfeedpp   /// 
	cex_ddothlivsc /// 
	cex_ddseeds    /// 
	cex_ddfert     /// 
	cex_ddcroppro  /// 
	cex_ddothcrop  /// 
	cex_ddforestsc /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	
	tabstat           /// 
	cex_fdairyoh      /// 
	cex_dohcontwork   /// 
	cex_dohmchbldcurr /// 
	cex_dohenergy     /// 
	cex_dohothdirin   /// 
	cex_dohdep        /// 
	cex_dohwages      /// 
	cex_dohrent       /// 
	cex_dohintst      /// 
	if cntry==1 & dpnolu > 65 [weight=wt],stats(mean) by(year)
	



********************************************************************************************
* Northern Ireland
********************************************************************************************


	* Small herd (NI)
	tabstat        /// 
	cex_fdairydc   /// 
	cex_ddfeedgl   /// 
	cex_ddfeedpp   /// 
	cex_ddothlivsc /// 
	cex_ddseeds    /// 
	cex_ddfert     /// 
	cex_ddcroppro  /// 
	cex_ddothcrop  /// 
	cex_ddforestsc /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	
	tabstat           /// 
	cex_fdairyoh      /// 
	cex_dohcontwork   /// 
	cex_dohmchbldcurr /// 
	cex_dohenergy     /// 
	cex_dohothdirin   /// 
	cex_dohdep        /// 
	cex_dohwages      /// 
	cex_dohrent       /// 
	cex_dohintst      /// 
	if cntry==2 & dpnolu <= 45 [weight=wt],stats(mean) by(year)
	


	* Moderate herd (NI)
	tabstat        /// 
	cex_fdairydc   /// 
	cex_ddfeedgl   /// 
	cex_ddfeedpp   /// 
	cex_ddothlivsc /// 
	cex_ddseeds    /// 
	cex_ddfert     /// 
	cex_ddcroppro  /// 
	cex_ddothcrop  /// 
	cex_ddforestsc /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	
	tabstat           /// 
	cex_fdairyoh      /// 
	cex_dohcontwork   /// 
	cex_dohmchbldcurr /// 
	cex_dohenergy     /// 
	cex_dohothdirin   /// 
	cex_dohdep        /// 
	cex_dohwages      /// 
	cex_dohrent       /// 
	cex_dohintst      /// 
	if cntry==2 & dpnolu > 45 & dpnolu <= 85 [weight=wt],stats(mean) by(year)
	


	* Large herd (NI)
	tabstat        /// 
	cex_fdairydc   /// 
	cex_ddfeedgl   /// 
	cex_ddfeedpp   /// 
	cex_ddothlivsc /// 
	cex_ddseeds    /// 
	cex_ddfert     /// 
	cex_ddcroppro  /// 
	cex_ddothcrop  /// 
	cex_ddforestsc /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	
	tabstat           /// 
	cex_fdairyoh      /// 
	cex_dohcontwork   /// 
	cex_dohmchbldcurr /// 
	cex_dohenergy     /// 
	cex_dohothdirin   /// 
	cex_dohdep        /// 
	cex_dohwages      /// 
	cex_dohrent       /// 
	cex_dohintst      /// 
	if cntry==2 & dpnolu > 85 [weight=wt],stats(mean) by(year)
	

log close
