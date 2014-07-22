/* Create tables for comparison with 2011 EU Dairy Farms Report (pg 78 for Ireland, 169 for NI - 2008 only) */

* Milk tonnes 
capture drop milktons
gen milktons = dairyproduct * 1.03/1000
qui tabstat milktons if country=="IRE" [weight=wt], by(year) save
matrix MILKTONS =    ///
	(r(Stat2 ) \ ///
	 r(Stat3 ) \ ///
	 r(Stat4 ) \ ///
	 r(Stat5 ) \ ///
	 r(Stat6 ) \ ///
	 r(Stat7 ) \ ///
	 r(Stat8 ) \ /// 
	 r(Stat9 ) \ /// 
	 r(Stat10))
matrix rownames MILKTONS = 2000 2001 2002 2003 2004 2005 ///
			   2006 2007 2008 

* Enterprise level (allocated) values of unpaid family factors 
qui tabstat 	     ///
	fdairygo     ///
	ddfeedgl    ///
	feedforgrazinglivestock    ///
	fdairydc     ///
	dohmchbldcurr    ///
	dohenergy    ///
	dohcontwork  ///
	dohothdirin  ///
	dohdep       ///
	dohwages     ///
	dohrent      ///
	dohintst     ///
	dohfamlab    ///
	dohunpdcap   ///
	if country=="IRE" [weight=wt] ///
	, by(year) save
matrix FACTORS_IE =  /// 
	(r(Stat2 ) \ ///
	 r(Stat3 ) \ ///
	 r(Stat4 ) \ ///
	 r(Stat5 ) \ ///
	 r(Stat6 ) \ ///
	 r(Stat7 ) \ ///
	 r(Stat8 ) \ /// 
	 r(Stat9 ) \ /// 
	 r(Stat10))
matrix rownames FACTORS_IE = 2000 2001 2002 2003 2004 2005 ///
			   2006 2007 2008 

* Euro/ton enterprise level (allocated) values of unpaid family factors 
matrix FACTORS_IE_TON = FACTORS_IE
mata
FACTORS_IE_TON = st_matrix("FACTORS_IE") :/ st_matrix("MILKTONS")
st_matrix("FACTORS_IE_TON", FACTORS_IE_TON)
st_matrixrowstripe("FACTORS_IE_TON", st_matrixrowstripe("FACTORS_IE"))
st_matrixcolstripe("FACTORS_IE_TON", st_matrixcolstripe("FACTORS_IE"))
end

matrix FACTORS_IE_TON = FACTORS_IE_TON'
matrix list FACTORS_IE_TON
