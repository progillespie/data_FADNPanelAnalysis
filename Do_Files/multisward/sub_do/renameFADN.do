********************************************************
********************************************************
*    Cathal O'Donoghue, REDP Teagasc
*       &
*       Patrick R. Gillespie                            
*       Walsh Fellow                    
*       Teagasc, REDP                           
*       patrick.gillespie@teagasc.ie            
********************************************************
* Farm Level Microsimulation Model
*       Cross country SFA analysis
*       Using FADN Panel Data                                                   
*       
*       Code for PhD Thesis chapter
*       Contribution to Multisward 
*       Framework Project
*                                                                       
*       Thesis Supervisors:
*       Cathal O'Donoghue
*       Stephen Hynes
*       Thia Hennessey
*       Fiona Thorne
*
********************************************************
* sub_do file for FADN_IGM
*
* ... renames and generates variables from FADN data
* (variables from Standard Results, see RICC 882) +
* Manager/Holder age variable from second FADN request. 
* Vars are given closest NFS varname for usage in IGM
* model (see Cathal O'Donoghue). 
*
* Currently pertains to Dairy only (i.e. mostly vars
* pertaining to Dairy are manipulated).
********************************************************






********************************************************
* Farm descriptors
********************************************************
gen wt = farmsrepresented
gen ftotallu = totallivestockunits
gen total_labour_hrs = labourinputhours
capture gen fsubchen = lessfavouredarea
*gen fsubesag = 
* fsubreps is generated in the code below 
gen sfp =  singlefarmpayment 





********************************************************
* Allocation variables (these differ slightly from Fiona's as I don't have some vars)
********************************************************

gen dpalloclu = dairycowslus/(dairycowslus+othercattlelus+sheepandgoatslus)
gen cpalloclu = othercattlelus/(dairycowslus+othercattlelus+sheepandgoatslus)
gen spalloclu = sheepandgoatslus/(dairycowslus+othercattlelus+sheepandgoatslus)
gen dpallocgo = cowsmilkandmilkproducts/(cowsmilkandmilkproducts+beefandveal+sheepandgoats)
gen cpallocgo = beefandveal/(cowsmilkandmilkproducts+beefandveal+sheepandgoats)
gen spallocgo = sheepandgoats/(cowsmilkandmilkproducts+beefandveal+sheepandgoats)
gen alloc = cowsmilkandmilkproducts/(totaloutputcrops+totaloutputlivestock)





***********************************************
* CREATE PRICE INDEXES 
***********************************************

gen PTotalCattle=0
replace PTotalCattle=101.7/100 if year == 1996
replace PTotalCattle=96.3/100  if year == 1997
replace PTotalCattle=93.4/100  if year == 1998
replace PTotalCattle=89.1/100  if year == 1999
replace PTotalCattle=100.0/100  if year == 2000
replace PTotalCattle=92.3/100  if year == 2001
replace PTotalCattle=94.4/100  if year == 2002
replace PTotalCattle=93.6/100  if year == 2003
replace PTotalCattle=103.3/100  if year == 2004
replace PTotalCattle=105.6/100  if year == 2005
replace PTotalCattle=113.22/100  if year == 2006
replace PTotalCattle=113.22/100  if year == 2007


gen PSheep=0 
replace PSheep=109.6/100  if year == 1996
replace PSheep=112.4/100  if year == 1997
replace PSheep=96.5/100  if year == 1998
replace PSheep=88.7/100  if year == 1999
replace PSheep=100.0/100  if year == 2000
replace PSheep=142.9/100  if year == 2001
replace PSheep=121.3/100  if year == 2002
replace PSheep=119.5/100  if year == 2003
replace PSheep=117.7/100  if year == 2004
replace PSheep=109.6/100  if year == 2005
replace PSheep=112.21/100  if year == 2006
replace PSheep=112.21/100  if year == 2007


gen PMilk=0
replace PMilk=105.4/100  if year == 1996
replace PMilk=97.8/100  if year == 1997
replace PMilk=101.1/100  if year == 1998
replace PMilk=98.4/100  if year == 1999
replace PMilk=100.0/100  if year == 2000
replace PMilk=104.3/100  if year == 2001
replace PMilk=97.1/100  if year == 2002
replace PMilk=95.6/100  if year == 2003
replace PMilk=95.3/100  if year == 2004
replace PMilk=93.5/100  if year == 2005
replace PMilk=90.13/100  if year == 2006
replace PMilk=90.13/100  if year == 2007





********************************************************
* Enterprise Level (via allocation vars calculated above)
********************************************************



** Forage areas
gen daforare = foragearea * dpalloclu
gen cpforacs = foragearea * cpalloclu
gen spforacs = foragearea * spalloclu



** Output (deflated by relevant indices)
gen fdairygo = cowsmilkandmilkproducts/PMilk // <- euro value
gen dogrosso = fdairygo // corr fdairygo dogrosso = 1 in nfs_data.dta 

gen fcatlego = beefandveal/PTotalCattle // <- euro value
gen cogrosso = fcatlego // corr fcatlego  cogrosso = 1 in nfs_data.dta 

gen fsheepgo = sheepandgoats/PSheep // <- euro value
* corr fsheepgo sogrosso is not perfect in nfs_data.dta!

gen dotomkgl = dairyproducts/10 // <- originally 100 kg
* corr fpigsgo hogrosso is not perfect in nfs_data.dta!


** Direct Costs
* both vetmed and fdaifees are lumped in here
gen fdvetmed = (otherlivestockspecificcosts/2)
gen fdaifees = (otherlivestockspecificcosts/2)
* fdpurblk and fdpurcon not separable   
gen fdpurblk = (feedforgrazinglivestock/2)
gen fdpurcon = (feedforgrazinglivestock/2)
gen fdcrppro = cropprotection 
gen fdferfil = fertilisers 
gen fdpursed = seedsandplants 



* Prices
*gen Pmilk =  cowsmilkandmilkproducts/dairyproducts
*gen PContract =  contractwork/
*gen PRent =  rentpaid/renteduaa



********************************************************
* Farm Level vars
********************************************************

** Direct costs
* both vetmed and fdaifees are lumped in here
gen farmvetmed = otherlivestockspecificcosts/2 
gen farmaifees = otherlivestockspecificcosts/2
gen aidairy = farmaifees
* fdpurblk and fdpurcon not separable   
gen farmpurblk = feedforgrazinglivestock/2 
gen farmpurcon = feedforgrazinglivestock/2 
gen farmcrppro = cropprotection 
gen farmferfil =  fertilisers 
gen farmpursed =  seedsandplants
gen farmdc =  fdvetmed + fdaifees + fdpurblk + fdpurcon + fdcrppro + fdferfil + fdpursed + contractwork - foragecropsvalue
gen fainvfrm = totalfixedassets
gen fainvmch =  machinery
gen fainvbld =  buildings
gen fofuellu = energy


** Fixed costs
*gen labunits = totallabourinputawu
gen flabtotl = labourinputhours
gen flabpaid =  paidlabourinputhours
gen flabunpd = unpaidlabourinputhours
gen fsubreps = environmentalsubsidies
*! could use carexpenses + electricity, but don't have these variables, so set to 0 for now
gen focarelp =  0 
** Farm/holder descriptors
*! todo <- merge FADN2 in to get farmer age
gen ogagehld = 0
capture replace ogagehld = year - yrborn
gen age =  ogagehld 
gen fsizuaa = totaluaa   
** Stocking variables
gen dpnolu =  dairycowslus   
gen cpnolu =  othercattlelus   
gen spnolu =  sheepandgoatslus   



* other necessary vars (usually defined in doFarmDerivedVars.do).
gen hasreps =  fsubreps > 0 & fsubreps != .
gen hasforestry =  forestryspecificcosts > 0 & forestryspecificcosts != .
*! these may or may not be appropriate
gen landval =  landpermananentcropsquotas
gen teagasc = otherruraldevelopmentpayments


gen loan =  longmediumtermloans + shorttermloans
local unitvars fdairygo dotomkgl landval fdferfil dpnolu fdvetmed fdaifees fdpurblk fdpurcon fdcrppro fdpursed





*******************************************************
* Generate the minimum agricultural wage
*  This is used to give a value to family labour
*******************************************************

capture drop PMinAgWage
gen PMinAgWage = 0
replace PMinAgWage = 9705 if year == 1996
replace PMinAgWage = 10047 if year == 1997
replace PMinAgWage = 10278 if year == 1998
replace PMinAgWage = 10642 if year == 1999
replace PMinAgWage = 11437 if year == 2000
replace PMinAgWage = 12481 if year == 2001
replace PMinAgWage = 13208 if year == 2002
replace PMinAgWage = 13802 if year == 2003
replace PMinAgWage = 14196 if year == 2004
replace PMinAgWage = 15513 if year == 2005
replace PMinAgWage = 16062 if year == 2006
replace PMinAgWage = 17339 if year == 2007
replace PMinAgWage = 17988.36 if year == 2008
replace PMinAgWage = 18921.24 if year == 2009
replace PMinAgWage = 18907.2 if year == 2010
replace PMinAgWage = 19167.2 if year == 2011
replace PMinAgWage = 19406.4 if year == 2012
replace PMinAgWage = 19406.4 if year == 2013



*******************************************************
*******************************************************
* long list of variables
*******************************************************
*******************************************************

* !!Notes at bottom of the file!!

*gen = 0
gen flabsmds = labourinputhours/8
gen spavnoew = 0
gen spavno12 = 0
gen spavno2p = 0
gen spavnorm = 0
gen spavnlbw = 0
gen spavnool = 0
gen spavnots = 0
gen oanolt5y = 0
gen oano515y = 0
gen oano1619 = 0
gen oano2024 = 0
gen oano2544 = 0
gen oano4564 = 0
gen oanoge65 = 0
gen ffszsyst = system
gen fgrntsub = 0
gen fsubesag = 0
gen cssuckcw = 0
gen cs10mtbf = 0
gen cs22mtbf = 0
gen csslaugh = 0 
gen csextens = 0 
gen csheadag = 0 
gen csmctopu = 0
gen sosubsid = 0
gen posubsid = 0
gen dogpcomp = 0
gen fsubastp = 0
gen fsubcatp = 0
gen fsubrptp = 0
gen fsubpbtp = 0
gen fsublitp = 0
gen fsubmztp = 0
gen fsubvstp = 0
gen dqcomlrd = 0
gen dosubsvl = 0
gen farmgo = totaloutput
gen farmffi = familyfarmincome
gen fsizldow = 0
gen fsizldrt = 0
gen fsizldlt = 0
gen wwhcuarq = 0
gen swhcuarq = 0
gen wbycuarq = 0
gen sbycuarq = 0
gen mbycuarq = 0
gen wotcuarq = 0
gen sotcuarq = 0
gen osrcuarq = 0
gen pbscuarq = 0
gen lsdcuarq = 0
gen potcuarq = 0
gen sbecuarq = 0
gen faprldvl = 0
gen faprldac = 0
gen faslldvl = 0
gen faslldac = 0
gen favlfrey = 0
gen favlfrby = 0
gen forntcon = 0
gen soil = int(runiform()*8) + 1
gen soil2 = 0
gen soil3 = 0
gen hpforacs = 0
gen fsizfrac = 0
gen fsizfort = 0
gen fsizeadj = 0
gen fcropsgm = 0
gen flivstgm = 0
gen doslcmvl = 0
gen dosllmvl = 0
gen domlkbon = 0
gen domlkpen = 0
gen domkfdvl = 0
gen domkalvl = 0
gen doslmkvl = 0
gen doslcmgl = 0
gen dosllmgl = 0
gen doslmkgl = 0
gen domkfdgl = 0
gen dotomkvl = cowsmilkandmilkproducts //need this for NLOGIT. Best match is the same var as we have for fdairygo above
gen doschbvl = 0
gen doschbno = 0
gen dosldhrd = 0
gen docfslvl = 0
gen docfslno = 0
gen dotochbv = 0
gen dotochbn = 0
gen dopchbvl = 0
gen dopchbno = 0
gen dotichbv = 0
gen dotichbn = 0
gen doprdhrd = 0
gen dovlcnod = 0
gen doreplct = 0
gen docftfvl = 0
gen docftfno = 0
gen dovalclf = 0
gen ddmiscdc = 0
gen ivmalldy = 0
gen iaisfdy = 0
gen itedairy = 0
gen imiscdry = 0
gen flabccdy = 0
gen ddconval = 0
gen ddpastur = 0
gen ddwinfor = 0
gen PCattleFeed = 0
gen PTotalFert = 0
gen PVetExp = 0
gen PMotorFuels = 0
gen POtherInputs = 0
gen PLabour =  wagespaid/paidlabourinputhours
gen cpavnocw = 0
gen cpavno06 = 0
gen dpavnohd = dairycows //using dairycows here instead of dairycowslus (should be same). Will end up as H in NLOGIT.
gen cpavnohc = 0
gen cpavno61 = 0
gen cpavno12 = 0
gen cpavno2p = 0
gen cpavnobl = 0
gen cpavn12m = 0
gen cpavn12f = 0
gen cpavn2pm = 0
gen cpavn2pf  = 0
gen cosalesv = 0
gen copurval = 0
gen covalcno = 0
gen cosubsid = 0
gen cotffdvl = 0
gen cotftdvl = 0
gen coslcfvl = 0
gen coslwnvl = 0
gen coslstvl = 0
gen coslfcvl = 0
gen coslbhvl = 0
gen coslocvl = 0
gen coprcfvl = 0
gen coprwnvl = 0
gen coprstvl = 0
gen coprbhvl = 0
gen coprocvl = 0
gen coslmfno = 0
gen coslcfno = 0
gen coslwnno = 0
gen coslstno = 0
gen coslfcno = 0
gen coslbhno = 0
gen coslocno = 0
gen coprcfno = 0
gen coprwnno = 0
gen coprstno = 0
gen coprfcno = 0
gen coprbhno = 0
gen coprocno = 0
gen cotftdno = 0
gen cotffdno = 0
gen coslmsvl = 0
gen coslmsno = 0
gen coslfsvl = 0
gen coslfsno = 0
gen coprmsvl = 0
gen coprmsno = 0
gen coprfsvl = 0
gen coprfsno = 0
gen coslfmvl = 0
gen coslffvl = 0
gen coslffno = 0
gen cdmiscdc = 0
gen ivmallc = 0
gen iaisfcat = 0
gen itecattl = 0
gen imiscctl = 0
gen flabccct = 0
gen cdconcen = 0
gen cdpastur = 0
gen cdwinfor = 0
gen cdmilsub = 0
gen PCalfFeed = 0
gen sosalean = 0
gen soslhgvl = 0
gen soslflvl = 0
gen soslflno = 0
gen soslslvl = 0
gen soslslno = 0
gen soslhgno = 0
gen soslbhvl = 0
gen soslbhno = 0
gen soslervl = 0
gen soslerno = 0
gen soslbevl = 0
gen soslbeno = 0
gen soconhvl = 0
gen soconhno = 0
gen soprslvl = 0
gen soprslno = 0
gen soprbdvl = 0
gen soprbdno = 0
gen sdother = 0
gen ivmallsp = 0
gen iaisfshp = 0
gen itesheep = 0
gen imiscshp = 0
gen flabccsh= 0
gen sdconval = 0
gen sdwinfor = 0
gen sdroots = 0
gen sdpastur = 0
gen fcropsgo = 0
gen wwhcuylq  = 0
gen wwhcusdq  = 0
gen wwhcuslq  = 0
gen wwhcufdq  = 0
gen wwhcuclq  = 0
gen wwhcufnq  = 0
gen wwhcufpq  = 0
gen wwhcufkq  = 0
gen wwhcucpv  = 0
gen wwhcumhv  = 0
gen wwhcucwv  = 0
gen wwhcumcv  = 0
gen wwhcusev = 0
gen wwhcufrv  = 0
gen wwhcutcv  = 0
gen wwhcutsv  = 0
gen wwhcuwtq = 0 
gen wwhcualq  = 0
gen wwhopopv  = 0
gen wwhopopq  = 0
gen wwhopslv  = 0
gen wwhopslq  = 0
gen wwhopfdv  = 0
gen wwhopfdq  = 0
gen wwhopsdv  = 0
gen wwhopsdq  = 0
gen wwhopclv  = 0
gen wwhopclq = 0
gen wwhcugov  = 0
gen wwhopgov  = 0
gen wwhcuslv  = 0
gen wwhcufdv  = 0
gen wwhcusdv  = 0
gen wwhcuclv = 0
gen swhcuylq  = 0
gen swhcusdq  = 0
gen swhcuslq  = 0
gen swhcufdq  = 0
gen swhcuclq  = 0
gen swhcufnq  = 0
gen swhcufpq  = 0
gen swhcufkq  = 0
gen swhcucpv  = 0
gen swhcumhv  = 0
gen swhcucwv  = 0
gen swhcumcv  = 0
gen swhcufrv  = 0
gen swhcusev  = 0
gen swhcutcv  = 0
gen swhcutsv  = 0
gen swhcuwtq = 0 
gen swhcualq  = 0
gen swhopopv  = 0
gen swhopopq  = 0
gen swhopslv  = 0
gen swhopslq  = 0
gen swhopfdv  = 0
gen swhopfdq  = 0
gen swhopsdv  = 0
gen swhopsdq  = 0
gen swhopclv  = 0
gen swhopclq = 0
gen swhcugov  = 0
gen swhopgov  = 0
gen swhcuslv  = 0
gen swhcufdv  = 0
gen swhcusdv  = 0
gen swhcuclv = 0
gen wbycuylq  = 0
gen wbycusdq  = 0
gen wbycuslq  = 0
gen wbycufdq  = 0
gen wbycuclq  = 0
gen wbycufnq  = 0
gen wbycufpq  = 0
gen wbycufkq  = 0
gen wbycucpv  = 0
gen wbycumhv  = 0
gen wbycucwv  = 0
gen wbycumcv  = 0
gen wbycufrv  = 0
gen wbycusev  = 0
gen wbycutcv  = 0
gen wbycutsv  = 0
gen wbycuwtq = 0 
gen wbycualq  = 0
gen wbyopopv  = 0
gen wbyopopq  = 0
gen wbyopslv  = 0
gen wbyopslq  = 0
gen wbyopfdv  = 0
gen wbyopfdq  = 0
gen wbyopsdv  = 0
gen wbyopsdq  = 0
gen wbyopclv  = 0
gen wbyopclq = 0
gen wbycugov  = 0
gen wbyopgov  = 0
gen wbycuslv  = 0
gen wbycufdv  = 0
gen wbycusdv  = 0
gen wbycuclv = 0
gen sbycuylq  = 0
gen sbycusdq  = 0
gen sbycuslq  = 0
gen sbycufdq  = 0
gen sbycuclq  = 0
gen sbycufnq  = 0
gen sbycufpq  = 0
gen sbycufkq  = 0
gen sbycucpv  = 0
gen sbycumhv  = 0
gen sbycucwv  = 0
gen sbycumcv  = 0
gen sbycusev = 0
gen sbycufrv  = 0
gen sbycutcv  = 0
gen sbycutsv  = 0
gen sbycuwtq = 0 
gen sbycualq  = 0
gen sbyopopv  = 0
gen sbyopopq  = 0
gen sbyopslv  = 0
gen sbyopslq  = 0
gen sbyopfdv  = 0
gen sbyopfdq  = 0
gen sbyopsdv  = 0
gen sbyopsdq  = 0
gen sbyopclv  = 0
gen sbyopclq = 0
gen sbycugov  = 0
gen sbyopgov  = 0
gen sbycuslv  = 0
gen sbycufdv  = 0
gen sbycusdv  = 0
gen sbycuclv = 0
gen mbycuylq  = 0
gen mbycusdq  = 0
gen mbycuslq  = 0
gen mbycufdq  = 0
gen mbycuclq  = 0
gen mbycufnq  = 0
gen mbycufpq  = 0
gen mbycufkq  = 0
gen mbycucpv  = 0
gen mbycumhv  = 0
gen mbycucwv  = 0
gen mbycumcv  = 0
gen mbycusev = 0
gen mbycufrv  = 0
gen mbycutcv  = 0
gen mbycutsv  = 0
gen mbycuwtq = 0 
gen mbycualq  = 0
gen mbyopopv  = 0
gen mbyopopq  = 0
gen mbyopslv  = 0
gen mbyopslq  = 0
gen mbyopfdv  = 0
gen mbyopfdq  = 0
gen mbyopsdv  = 0
gen mbyopsdq  = 0
gen mbyopclv  = 0
gen mbyopclq = 0
gen mbycugov  = 0
gen mbyopgov  = 0
gen mbycuslv  = 0
gen mbycufdv  = 0
gen mbycusdv  = 0
gen mbycuclv = 0
gen potcuylq  = 0
gen potcusdq  = 0
gen potcuslq  = 0
gen potcufdq  = 0
gen potcuclq  = 0
gen potcufnq  = 0
gen potcufpq  = 0
gen potcufkq  = 0
gen potcucpv  = 0
gen potcumhv  = 0
gen potcucwv  = 0
gen potcumcv  = 0
gen potcusev = 0
gen potcufrv  = 0
gen potcutcv  = 0
gen potcutsv  = 0
gen potcuwtq = 0 
gen potcualq  = 0
gen potopopv  = 0
gen potopopq  = 0
gen potopslv  = 0
gen potopslq  = 0
gen potopfdv  = 0
gen potopfdq  = 0
gen potopsdv  = 0
gen potopsdq  = 0
gen potopclv  = 0
gen potopclq = 0
gen potcugov  = 0
gen potopgov  = 0
gen potcuslv  = 0
gen potcufdv  = 0
gen potcusdv  = 0
gen potcuclv = 0
gen sbecuylq = 0
gen sbecusdq = 0
gen sbecuslq = 0
gen sbecufdq = 0
gen sbecuclq = 0
gen sbecufnq = 0
gen sbecufpq = 0
gen sbecufkq = 0
gen sbecucpv = 0
gen sbecumhv = 0
gen sbecucwv = 0
gen sbecumcv = 0
gen sbecusev= 0
gen sbecufrv = 0
gen sbecutcv = 0
gen sbecutsv = 0
gen sbecuwtq = 0 
gen sbecualq  = 0
gen sbeopopv  = 0
gen sbeopopq  = 0
gen sbeopslv  = 0
gen sbeopslq  = 0
gen sbeopfdv  = 0
gen sbeopfdq  = 0
gen sbeopsdv  = 0
gen sbeopsdq  = 0
gen sbeopclv  = 0
gen sbeopclq = 0
gen sbecugov  = 0
gen sbeopgov  = 0
gen sbecuslv  = 0
gen sbecufdv  = 0
gen sbecusdv  = 0
gen sbecuclv = 0
gen PfertiliserNPK = 0
gen PPlantProtection = 0
gen PSeeds = 0
gen fpigsgo = 0
gen fpoultgo = 0
gen fhorsego = 0
gen fothergo= 0
gen frhiremh = 0
gen frevoth = 0
gen finttran = 0
gen suckler_welfare = 0
gen fsubhors = 0
gen fsubforh = 0 
gen fsubtbco = 0
gen fsubyfig = 0
*gen PMilk = 0 // defined at the top of this file
*gen PTotalCattle = 0 // defined at the top of this file
*gen PSheep = 0 // defined at the top of this file
gen Ppig = 0
gen Ppoultry = 0
gen PTotalCrop = 0
gen fdmachir = 0
gen fdtrans = 0
gen fdlivmnt = 0
gen fdcaslab = contractwork 
gen fvalflab = unpaidlabourinputhours * PMinAgWage
gen fdmiscel = 0
gen fdfodadj = 0
gen PStraightFeed = 0
gen fohirlab  = wagespaid
gen fointpay  = 0
gen fomacdpr  = 0
gen fomacopt  = machininerybuildingcurrentcosts
gen foblddpr  = 0
gen fobldmnt  = 0
gen fodprlim  = 0
gen foupkpld  = 0
gen foannuit  = 0
gen fomiscel  = 0
gen forates  = 0
gen fortfmer = 0
gen PElectricity = 0
gen pdmiscdc = 0
gen imiscpig = 0
gen flabccpg = 0
gen edtotldc  = 0
gen icallpyv  = 0
gen ivmallpy  = 0
gen itepolty  = 0
gen imiscpty  = 0
gen flabccpy = 0
gen icallhvl = 0
gen ivmallh  = 0
gen iaisfhrs  = 0
gen itehorse  = 0
gen imischrs = 0
gen iballhrs  = 0
gen ibhayhvl  = 0
gen ibstrhvl  = 0
gen ibsilhvl= 0
gen fdairygm = 0
gen farmohct = 0
gen fdairydc = 0
gen fcatlegm = 0
gen fsheepgm = 0
gen PTotalInputs = 0
gen DAIRY_PLATFORM = 0
gen dafedare = 0
gen dpcfbtot = 0
gen farmgm = 0
gen fototal = 0
gen fcplivgo = totaloutputcrops + totaloutputlivestock // common sense translation here. have to double check definitions though
* making fcplivgo and fdairygo are critical, as they are needed to gen alloc in the Variable Construction, which is a bottle-neck. 







* search doFarmDerivedFADN.do for "*!"

* most regressions turned off

* several tabstats turned off 


* I don't believe we will have off farm employment or number of children. section turned off starting from gen isofffarmy 

* had to shut off Dairy Platform section and Exists in 2008 altogether and I don't think the Dairy Platform stuff (data only goes to 2007 currently, and I don't think platform dat is transmissable to FADN)

* had to create random assignment of soil variable to allowtab, gen of soil to work (needs 8 values to gen 8 soil dummies)

* lt_conc was replaced with 1 if missing (which it always was due to setting of some of the divisors to 0)

* ensure all loops that go through years have the correct start and stop years for the panel (i.e. FADN I had went from 1999 - 2007). First line in which this was a problem was around 1353 (while loop under "Enterprise specific Quintile of GM")

* also under Enterprise Specific quintiles, had to take fcrops out of ent_vlist (no observations)

* must also comment the following around line 1184 in doFarmDerivedVars.do ...
	*drop if tfarmffi2 == .
* until you successfully generate this variable with non-missing values (all obs are dropped otherwise)


