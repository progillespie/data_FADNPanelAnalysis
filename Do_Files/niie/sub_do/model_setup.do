set more off

* value 4 (the highest) corresponds to "not available" which we'll
*   consider missing. specifying >= instead of == will eliminate all 
*   possible categories of missings as well (., "", .a-.z) 
drop if altitudezone >= 4
* now generate azone dummies for model
*  there will be three, of which we'll include 2 in the model
tab(altitudezone), gen(azone)

gen fdratio = feedforgrazinglivestockhomegrown/feedforgrazinglivestock
gen lnfdratio = log(fdratio)

tab country, gen(COUNTRY)

qui do sub_do/grassregion.do
qui do sub_do/FarmRegrExpVars.do

gen intwt = int(farmsrepresented)

***********************************************************************
***********************************************************************
***********************************************************************
* From James Carroll's SFA workshop. Useful for exporting variables to 
* NLOGIT.
***********************************************************************
***********************************************************************
***********************************************************************

/*
*egen minyear = min(year) - 1
gen minyear = 1996 - 1 
gen t = year - minyear

***********************************************
******* CREATE PRICE INDEXES ******************
***********************************************

gen PTotalOutputs=0

replace PTotalOutputs=105.3 if t==1
replace PTotalOutputs=98.8 if t==2
replace PTotalOutputs=98.0 if t==3
replace PTotalOutputs=94.0 if t==4
replace PTotalOutputs=100.0 if t==5
replace PTotalOutputs=104.3 if t==6
replace PTotalOutputs=100.0 if t==7
replace PTotalOutputs=99.6 if t==8
replace PTotalOutputs=101.8 if t==9
replace PTotalOutputs=102.3 if t==10
replace PTotalOutputs=107.42 if t>=11


gen PPrimeCattle=0
replace PPrimeCattle=101.0 if t==1
replace PPrimeCattle=95.2 if t==2
replace PPrimeCattle=93.4 if t==3
replace PPrimeCattle=90.9 if t==4
replace PPrimeCattle=100.0 if t==5
replace PPrimeCattle=92.5 if t==6
replace PPrimeCattle=95.2 if t==7
replace PPrimeCattle=93.3 if t==8
replace PPrimeCattle=101.9 if t==9
replace PPrimeCattle=105.6 if t==10
replace PPrimeCattle=113.49 if t>=11


gen PCowSlaughter=0
replace PCowSlaughter=108.7 if t==1
replace PCowSlaughter=102.8 if t==2
replace PCowSlaughter=98.8 if t==3
replace PCowSlaughter=87.6 if t==4
replace PCowSlaughter=100.0 if t==5
replace PCowSlaughter=86.7 if t==6
replace PCowSlaughter=83.2 if t==7
replace PCowSlaughter=86.4 if t==8
replace PCowSlaughter=103.2 if t==9
replace PCowSlaughter=107.1 if t==10
replace PCowSlaughter=118 if t>=11


gen PStoreCattle=0
replace PStoreCattle=99.1 if t==1
replace PStoreCattle=95.9 if t==2
replace PStoreCattle=89.6 if t==3
replace PStoreCattle=83.0 if t==4
replace PStoreCattle=100.0 if t==5
replace PStoreCattle=97.2 if t==6
replace PStoreCattle=100.7 if t==7
replace PStoreCattle=102.8 if t==8
replace PStoreCattle=112.3 if t==9
replace PStoreCattle=104.6 if t==10
replace PStoreCattle=107.46 if t>=11


gen PTotalCattle=0
replace PTotalCattle=101.7 if t==1
replace PTotalCattle=96.3 if t==2
replace PTotalCattle=93.4 if t==3
replace PTotalCattle=89.1 if t==4
replace PTotalCattle=100.0 if t==5
replace PTotalCattle=92.3 if t==6
replace PTotalCattle=94.4 if t==7
replace PTotalCattle=93.6 if t==8
replace PTotalCattle=103.3 if t==9
replace PTotalCattle=105.6 if t==10
replace PTotalCattle=113.22 if t>=11


gen PSheep=0 
replace PSheep=109.6 if t==1
replace PSheep=112.4 if t==2
replace PSheep=96.5 if t==3
replace PSheep=88.7 if t==4
replace PSheep=100.0 if t==5
replace PSheep=142.9 if t==6
replace PSheep=121.3 if t==7
replace PSheep=119.5 if t==8
replace PSheep=117.7 if t==9
replace PSheep=109.6 if t==10
replace PSheep=112.21 if t>=11


gen PMilk=0
replace PMilk=105.4 if t==1
replace PMilk=97.8 if t==2
replace PMilk=101.1 if t==3
replace PMilk=98.4 if t==4
replace PMilk=100.0 if t==5
replace PMilk=104.3 if t==6
replace PMilk=97.1 if t==7
replace PMilk=95.6 if t==8
replace PMilk=95.3 if t==9
replace PMilk=93.5 if t==10
replace PMilk=90.13 if t>=11


gen PCereals=0
replace PCereals=115.8 if t==1
replace PCereals=94.8 if t==2
replace PCereals=99.0 if t==3
replace PCereals=104.8 if t==4
replace PCereals=100.0 if t==5
replace PCereals=104.5 if t==6
replace PCereals=91.8 if t==7
replace PCereals=109.0 if t==8
replace PCereals=100.9 if t==9
replace PCereals=96.6 if t==10
replace PCereals=110.56 if t>=11


gen PSugarBeet=0
replace PSugarBeet=96.0 if t==1
replace PSugarBeet=97.6 if t==2
replace PSugarBeet=98.6 if t==3
replace PSugarBeet=99.5 if t==4
replace PSugarBeet=100.0 if t==5
replace PSugarBeet=102.8 if t==6
replace PSugarBeet=103.8 if t==7
replace PSugarBeet=103.8 if t==8
replace PSugarBeet=103.8 if t==9
replace PSugarBeet=103.7 if t==10
replace PSugarBeet=103.7 if t>=11


gen PPotatoes=0
replace PPotatoes=85.2 if t==1
replace PPotatoes=73.0 if t==2
replace PPotatoes=146.5 if t==3
replace PPotatoes=118.2 if t==4
replace PPotatoes=100.0 if t==5
replace PPotatoes=152.1 if t==6
replace PPotatoes=148.0 if t==7
replace PPotatoes=154.2 if t==8
replace PPotatoes=97.6 if t==9
replace PPotatoes=145.5 if t==10
replace PPotatoes=236.31 if t>=11


gen PVeg=0 
replace PVeg=96.3 if t==1
replace PVeg=92.1 if t==2
replace PVeg=97.8 if t==3
replace PVeg=97.2 if t==4
replace PVeg=100.0 if t==5
replace PVeg=105.4 if t==6
replace PVeg=114.9 if t==7
replace PVeg=110.0 if t==8
replace PVeg=110.7 if t==9
replace PVeg=116.1 if t==10
replace PVeg=123.65 if t>=11


gen PTotalCrop=0 
replace PTotalCrop=100.7 if t==1
replace PTotalCrop=91.2 if t==2
replace PTotalCrop=104.7 if t==3
replace PTotalCrop=103.3 if t==4
replace PTotalCrop=100.0 if t==5
replace PTotalCrop=112.2 if t==6
replace PTotalCrop=110.4 if t==7
replace PTotalCrop=116.0 if t==8
replace PTotalCrop=104.4 if t==9
replace PTotalCrop=112.0 if t==10
replace PTotalCrop=133.86 if t>=11


gen PTotalInputs=0
replace PTotalInputs=97.3 if t==1
replace PTotalInputs=95.3 if t==2
replace PTotalInputs=93.0 if t==3
replace PTotalInputs=94.1 if t==4
replace PTotalInputs=100.0 if t==5
replace PTotalInputs=104.8 if t==6
replace PTotalInputs=106.1 if t== 7
replace PTotalInputs=108.8 if t==8
replace PTotalInputs=113.1 if t==9
replace PTotalInputs=118.0 if t==10
replace PTotalInputs=123.07 if t>=11


gen PCalfFeed=0
replace PCalfFeed=111.9 if t==1
replace PCalfFeed=107.7 if t==2
replace PCalfFeed=100.8 if t==3
replace PCalfFeed=97.9 if t==4
replace PCalfFeed=100.0 if t==5
replace PCalfFeed=103.9 if t==6
replace PCalfFeed=105.8 if t==7
replace PCalfFeed=106.8 if t==8
replace PCalfFeed=110.1 if t==9
replace PCalfFeed=116.4 if t==10
replace PCalfFeed=107.43 if t>=11


gen PCattleFeed=0
replace PCattleFeed=110.7 if t==1
replace PCattleFeed=104.4 if t==2
replace PCattleFeed=98.3 if t==3
replace PCattleFeed=96.5 if t==4
replace PCattleFeed=100.0 if t==5
replace PCattleFeed=106.4 if t==6
replace PCattleFeed=107.8 if t==7
replace PCattleFeed=107.7 if t==8
replace PCattleFeed=111.7 if t==9
replace PCattleFeed=108.9 if t==10
replace PCattleFeed=111.23 if t>=11


gen PfertiliserNPK=0
replace PfertiliserNPK=102.5 if t==1
replace PfertiliserNPK=96.4 if t==2
replace PfertiliserNPK=93.4 if t==3
replace PfertiliserNPK=94.5 if t==4
replace PfertiliserNPK=100.0 if t==5
replace PfertiliserNPK=111.6 if t==6
replace PfertiliserNPK=108.4 if t==7
replace PfertiliserNPK=111.5 if t==8
replace PfertiliserNPK=112.2 if t==9
replace PfertiliserNPK=121.2 if t==10
replace PfertiliserNPK=129.19 if t>=11


gen PfertiliserPK=0
replace PfertiliserPK=92.7 if t==1
replace PfertiliserPK=88.7 if t==2
replace PfertiliserPK=88.5 if t==3
replace PfertiliserPK=96.3 if t==4
replace PfertiliserPK=100.0 if t==5
replace PfertiliserPK=104.5 if t==6
replace PfertiliserPK=103.3 if t==7
replace PfertiliserPK=105.0 if t==8
replace PfertiliserPK=106.2 if t==9
replace PfertiliserPK=110.0 if t==10
replace PfertiliserPK=115.92 if t>=11


gen PTotalFert=0
replace PTotalFert=101.0 if t==1
replace PTotalFert=94.8 if t==2
replace PTotalFert=91.3 if t==3
replace PTotalFert=93.3 if t==4
replace PTotalFert=100.0 if t==5
replace PTotalFert=113.4 if t==6
replace PTotalFert=110.5 if t==7
replace PTotalFert=113.0 if t==8
replace PTotalFert=115.1 if t==9
replace PTotalFert=124.5 if t==10
replace PTotalFert=133.1 if t>=11


gen PSeeds=0
replace PSeeds=103.4 if t==1
replace PSeeds=100.5 if t==2
replace PSeeds=102.0 if t==3
replace PSeeds=102.1 if t==4
replace PSeeds=100.0 if t==5
replace PSeeds=103.7 if t==6
replace PSeeds=107.4 if t==7
replace PSeeds=115.2 if t==8
replace PSeeds=116.1 if t==9
replace PSeeds=115.7 if t==10
replace PSeeds=120.11 if t>=11


gen PMotorFuels=0
replace PMotorFuels=71.8 if t==1
replace PMotorFuels=73.5 if t==2
replace PMotorFuels=70.5 if t==3
replace PMotorFuels=75.6 if t==4
replace PMotorFuels=100.0 if t==5
replace PMotorFuels=95.8 if t==6
replace PMotorFuels=94.7 if t==7
replace PMotorFuels=99.1 if t==8
replace PMotorFuels=110.2 if t==9
replace PMotorFuels=131.7 if t==10
replace PMotorFuels=144.08 if t>=11


gen PElectricity=0
replace PElectricity=97.5 if t==1
replace PElectricity=99.4 if t==2
replace PElectricity=100.0 if t==3
replace PElectricity=100.0 if t==4
replace PElectricity=100.0 if t==5
replace PElectricity=101.5 if t==6
replace PElectricity=105.9 if t==7
replace PElectricity=119.6 if t==8
replace PElectricity=125.7 if t==9
replace PElectricity=135.7 if t==10
replace PElectricity=141.61 if t>=11


gen PTotalEnergy=0
replace PTotalEnergy=76.6 if t==1
replace PTotalEnergy=78.2 if t==2
replace PTotalEnergy=75.9 if t==3
replace PTotalEnergy=80.2 if t==4
replace PTotalEnergy=100.0 if t==5
replace PTotalEnergy=97.1 if t==6
replace PTotalEnergy=97.1 if t==7
replace PTotalEnergy=102.9 if t==8
replace PTotalEnergy=112.6 if t==9
replace PTotalEnergy=131.7 if t==10
replace PTotalEnergy=143.12 if t>=11

gen PPlantProtection=0
replace PPlantProtection=100.8 if t==1
replace PPlantProtection=100.4 if t==2
replace PPlantProtection=100.8 if t==3
replace PPlantProtection=100.6 if t==4
replace PPlantProtection=100.0 if t==5
replace PPlantProtection=100.8 if t==6
replace PPlantProtection=101.6 if t==7
replace PPlantProtection=101.6 if t==8
replace PPlantProtection=103.2 if t==9
replace PPlantProtection=102.7 if t==10
replace PPlantProtection=101.72 if t>=11


gen PVetExp=0
replace PVetExp=89.3 if t==1
replace PVetExp=92.3 if t==2
replace PVetExp=94.7 if t==3
replace PVetExp=95.9 if t==4
replace PVetExp=100.0 if t==5
replace PVetExp=104.7 if t==6
replace PVetExp=109.4 if t==7
replace PVetExp=114.7 if t==8
replace PVetExp=115.8 if t==9
replace PVetExp=117.6 if t==10
replace PVetExp=122.43 if t>=11


gen POtherInputs=0
replace POtherInputs=91.2 if t==1
replace POtherInputs=92.7 if t==2
replace POtherInputs=93.6 if t==3
replace POtherInputs=95.9 if t==4
replace POtherInputs=100.0 if t==5
replace POtherInputs=105.9 if t==6
replace POtherInputs=110.4 if t==7
replace POtherInputs=114.1 if t==8
replace POtherInputs=116.9 if t==9
replace POtherInputs=121.0 if t==10
replace POtherInputs=124.04 if t>=11


gen CPI=0	
replace CPI=117.1 if t==1	
replace CPI=118.8 if t==2	
replace CPI=121.7 if t==3	
replace CPI=123.7 if t==4	
replace CPI=130.6 if t==5	
replace CPI=137	if t==6
replace CPI=143.3 if t==7	
replace CPI=148.3 if t==8	
replace CPI=151.6 if t==9	
replace CPI=155.3 if t==10
replace CPI=160 if t>=11


gen PTransportcap=0
replace PTransportcap=96.736231 if t==1
replace PTransportcap=97.4031069 if t==2
replace PTransportcap=98.3445787 if t==3
replace PTransportcap=99.2468225 if t==4
replace PTransportcap=100.0166667 if t==5
replace PTransportcap=101.3416667 if t==6
replace PTransportcap=102.9916667 if t==7
replace PTransportcap=103.95 if t==8
replace PTransportcap=104.3 if t==9
replace PTransportcap=105.6916667 if t==10
replace PTransportcap=106.6909091 if t>=11


gen POthercap=0
replace POthercap=93.2354049 if t==1
replace POthercap=94.2824859 if t==2
replace POthercap=96.0903955 if t==3
replace POthercap=98.2071563 if t==4
replace POthercap=100.0083333 if t==5
replace POthercap=101.9166667 if t==6
replace POthercap=103.1333333 if t==7
replace POthercap=103.3666667 if t==8
replace POthercap=103.6166667 if t==9
replace POthercap=104.3833333 if t==10
replace POthercap=105.3727273 if t>=11



******************************************************
********** CONVERT EARLY YEARS TO EURO ***************
******************************************************

replace farmvaluee=farmvaluee/.787564 if t<=3 
replace machinee=machinee /.787564 if t<=3
replace buildingse=buildingse /.787564 if t<=3
replace landimpe=landimpe /.787564 if t<=3
replace labfame=labfame /.787564 if t<=3
replace labcase= labcase/.787564 if t<=3
replace hiredlabe= hiredlabe/.787564 if t<=3
replace intereste= intereste/.787564 if t<=3
replace opexmachinery= opexmachinery/.787564 if t<=3
replace opexbuildings= opexbuildings/.787564 if t<=3
replace upkeepe=upkeepe /.787564 if t<=3
replace limee=limee /.787564 if t<=3
replace annuitiese= annuitiese/.787564 if t<=3
replace ratee=ratee /.787564 if t<=3
replace insurancee= insurancee/.787564 if t<=3
replace fuellubse =fuellubse /.787564 if t<=3
replace esbe =esbe /.787564 if t<=3
replace phonee =phonee /.787564 if t<=3
replace rentretirefame =rentretirefame /.787564 if t<=3
replace rentretirenonfame =rentretirenonfame /.787564 if t<=3
replace miscoverheade =miscoverheade /.787564 if t<=3
replace dairyinggrossoutput =dairyinggrossoutput /.787564 if t<=3
replace cropsgrossoutput =cropsgrossoutput /.787564 if t<=3
replace cropandlivegrossoutput =cropandlivegrossoutput /.787564 if t<=3
replace othergrantsandsubs =othergrantsandsubs /.787564 if t<=3
replace aidairy =aidairy /.787564 if t<=3
replace aicattle =aicattle /.787564 if t<=3
replace aisheep =aisheep /.787564 if t<=3
replace loan =loan /.787564 if t<=3
replace sub1 =sub1 /.787564 if t<=3
replace sub2 =sub2 /.787564 if t<=3
replace sub3 =sub3 /.787564 if t<=3
replace sub4 =sub4 /.787564 if t<=3
replace sub5 =sub5 /.787564 if t<=3
replace sub6 =sub6 /.787564 if t<=3
replace sub7 =sub7 /.787564 if t<=3
replace sub8 =sub8 /.787564 if t<=3
replace sub9 =sub9 /.787564 if t<=3
replace sub10 =sub10 /.787564 if t<=3
replace sub11 =sub11 /.787564 if t<=3
replace sub12 =sub12 /.787564 if t<=3
replace sub13 =sub13 /.787564 if t<=3
replace sub14 =sub14 /.787564 if t<=3
replace sub15 =sub15 /.787564 if t<=3
replace sub16 =sub16 /.787564 if t<=3
replace sub17 =sub17 /.787564 if t<=3
replace sub18 =sub18 /.787564 if t<=3
replace sub19 =sub19 /.787564 if t<=3
replace sub20 =sub20 /.787564 if t<=3
replace sub21 =sub21 /.787564 if t<=3
replace sub22 =sub22 /.787564 if t<=3
replace sub23 =sub23 /.787564 if t<=3
replace sub24 =sub24 /.787564 if t<=3
replace sub25 =sub25 /.787564 if t<=3
replace sub26 =sub26 /.787564 if t<=3
replace sub27 =sub27 /.787564 if t<=3
replace sub28 =sub28 /.787564 if t<=3
replace sub29= sub29/.787564 if t<=3
replace sub30 =sub30 /.787564 if t<=3
replace sub31 =sub31 /.787564 if t<=3
replace sub32 =sub32 /.787564 if t<=3
replace sub33 =sub33 /.787564 if t<=3
replace sub34 =sub34 /.787564 if t<=3
replace sub35= sub35/.787564 if t<=3
replace sub36 =sub36 /.787564 if t<=3
replace sub37 =sub37 /.787564 if t<=3
replace sub38 =sub38 /.787564 if t<=3
replace sub39=sub39 /.787564 if t<=3
replace sub40= sub40/.787564 if t<=3
replace sub41 =sub41 /.787564 if t<=3
replace sub42=sub42 /.787564 if t<=3
replace sub43 =sub43/.787564 if t<=3 
replace sub44 =sub44/.787564 if t<=3
replace sub45 =sub45 /.787564 if t<=3
replace sub46 =sub46 /.787564 if t<=3
replace sub47 =sub47 /.787564 if t<=3
replace sub48 =sub48 /.787564 if t<=3
replace sub49 =sub49 /.787564 if t<=3
replace sub50 =sub50 /.787564 if t<=3
replace sub51 =sub51 /.787564 if t<=3
replace sub52=sub52 /.787564 if t<=3
replace sub53= sub53/.787564 if t<=3
replace sub54=sub54 /.787564 if t<=3
replace sub55=sub55 /.787564 if t<=3
replace sub56=sub56/.787564 if t<=3
replace sub57= sub57/.787564 if t<=3
replace sub58=sub58 /.787564 if t<=3
replace sub59= sub59/.787564 if t<=3
replace sub60=sub60 /.787564 if t<=3
replace sub61=sub61 /.787564 if t<=3
replace sub62=sub62 /.787564 if t<=3
replace sub63=sub63 /.787564 if t<=3
replace sub64= sub64/.787564 if t<=3
replace sub65=sub65 /.787564 if t<=3
replace sub66=sub66 /.787564 if t<=3
replace sub67=sub67 /.787564 if t<=3
replace sub68= sub68/.787564 if t<=3
replace sub69=sub69 /.787564 if t<=3
replace sub70 =sub70/.787564 if t<=3
replace sub71 =sub71/.787564 if t<=3
replace sub72 =sub72/.787564 if t<=3
replace sub73=sub73 /.787564 if t<=3
replace sub74=sub74 /.787564 if t<=3
replace sub75=sub75 /.787564 if t<=3
replace sub76=sub76 /.787564 if t<=3
replace sub77= sub77/.787564 if t<=3
replace sub78=sub78 /.787564 if t<=3
replace sub79 =sub79/.787564 if t<=3
replace DYcloseinv= DYcloseinv/.787564 if t<=3
replace DYmilke =DYmilke/.787564 if t<=3
replace DYsubs =DYsubs/.787564 if t<=3
replace DYconcentrates=DYconcentrates /.787564 if t<=3
replace DYpasture=DYpasture /.787564 if t<=3
replace DYwinfor= DYwinfor/.787564 if t<=3
replace DYmisccosts=DYmisccosts /.787564 if t<=3
replace advisefee=advisefee/.787564 if t<=3





********************************************
****** DROP ALL BUT SYSTEM 1 (DAIRY) *******
********************************************

drop if sys==2
drop if sys==3
drop if sys==4
drop if sys==5
drop if sys==6
drop if sys==7
drop if sys==8
drop if sys==.



**********************************************
******** CREATE ALLOCATION VARIABLE **********
**********************************************
*! Now created in sub_do/renameFADN.do
*gen alloc=dairyinggrossoutput/cropandlivegrossoutput

replace alloc=1 if alloc>1
replace alloc=0 if alloc<0



****************************************************************************
**** PRODUCTION INPUTS *****************************************************
****************************************************************************

gen C= alloc*(((machinee/PTransportcap)*100)+((buildingse/POthercap)*100))


***** Create Labour Inputs *****
* don't have
*gen L1=(alloc*(labfame + labcase + hiredlabe))/CPI*100
gen L2=alloc*labunits
* don't have
*gen L3=alloc*mandays

***** Create Herd size variable (average number) *****

gen H=dpnolu

!
***** Convert early years to LITRES!*****

replace DYmilkgal=DYmilkgal*4.546092 if t==1
replace DYmilkgal=DYmilkgal*4.546092 if t==2
replace DYmilkgal=DYmilkgal*4.546092 if t==3
replace DYmilkgal=DYmilkgal*4.546092 if t==4
replace DYmilkgal=DYmilkgal*4.546092 if t==5
replace DYmilkgal=DYmilkgal*4.546092 if t==6
rename DYmilkgal Y1  


***** Deflate Milk values ****

gen Y1=fdairygo	  
gen Y2=(fdairygo/PMilk)*100


***** Direct Costs *****
*!
*gen D= (DYconcentrates/PCattleFeed*100)+ (DYpasture/PTotalFert*100)+ (DYwinfor/PTotalFert*100) +(alloc*opexmachinery/PTotalInputs*100)+(alloc*limee/PTotalFert*100)+ (alloc*fuellubse/PMotorFuels*100)
gen D= farmdc


****** Land inputs ******

replace daforare=daforare*2.47105 if t==11
* don't have
*replace DYfeedarea=DYfeedarea*2.47105 if t==11
replace fsizuaa=fsizuaa*2.47105 if t==11

gen A1=daforare
*gen A2=DYfeedarea

***** Create Time Dummys ****

tab t, gen(T)




****************************************************
********** CREATE EFFICIENCY VARIABLES *************
****************************************************


***** divide age into dummies *****
*!
rename age AGE

gen AGE1=0 
replace AGE1=1 if AGE<=30

gen AGE2=0 
replace AGE2=1 if AGE<=40
replace AGE2=0 if AGE<=31

gen AGE3=0 
replace AGE3=1 if AGE<=50
replace AGE3=0 if AGE<=41

gen AGE4=0 
replace AGE4=1 if AGE<=60
replace AGE4=0 if AGE<=51

gen AGE5=0
replace AGE5=1 if AGE<=70
replace AGE5=0 if AGE<=61

gen AGE6=0 
replace AGE6=1 if AGE<=80
replace AGE6=0 if AGE<=71

gen AGE7=0 
replace AGE7=1 if AGE<=90
replace AGE7=0 if AGE<=81


!
***** Create soil class dummies (1 is best, followed by 2 and 3) *****

gen SOIL1=0
replace SOIL1=1 if sclass<300

gen SOIL2=0
replace SOIL2=1 if sclass<500
replace SOIL2=0 if sclass<300

gen SOIL3=0
replace SOIL3=1 if sclass<700
replace SOIL3=0 if sclass<500

***** Create AI dummy (equal to 1 if farm spends any amount) *****

replace aidairy=aidairy/PVetExp*100
gen AID=0
replace AID=1 if aidairy>0


***** Create children dummy *****
*!
gen CHILD=0
replace CHILD=1 if childunder5>0
replace CHILD=1 if childunder15>0
replace CHILD=1 if childunder19>0


***** create married dummy *****
*!
gen MARRIED=0
replace MARRIED=1 if maritalstat==1


***** gen extension variable (value and dummy) ***** 
* 
gen EXTEN=teagasc 
gen EXTEND=0 
replace EXTEND=1 if EXTEN>0


***** gen SIZE DUMMIES ****

gen SIZE1=0
gen SIZE2=0
gen SIZE3=0
gen SIZE4=0
gen SIZE5=0

replace SIZE1=1 if fsizuaa<=75

replace SIZE2=1 if fsizuaa<=100
replace SIZE2=0 if fsizuaa<75

replace SIZE3=1 if fsizuaa<=125
replace SIZE3=0 if fsizuaa<100

replace SIZE4=1 if fsizuaa<=175
replace SIZE4=0 if fsizuaa<125

replace SIZE5=1 if fsizuaa>175


********************************
******** RENAME VARIABLES ******
********************************

rename alloc ALLOC
rename sys SYS
rename t T
rename wt W
rename fc FC
*rename offjobtype JOBTYPE
rename sizeclass SCLASS
*rename hohsex SEX
rename aidairy AI
rename farmvaluee FVALUE

rename childunder5 CHILD5
rename childunder15 CHILD15
rename childunder19 CHILD19

rename loan LOAN

rename DYownquota QTOWN
rename DYleasedquota QTLEASE
rename DYletquota QTLET
rename DYquota QT

rename fsizuaa FSIZE


***** DROP UNWANTED VARIABLE *****

keep country pid farmcode region year AI SYS T W FC SCLASS FSIZE FVALUE AGE LOAN Y1 ALLOC- SIZE5


************** drop zero obs **********************
drop if Y2<=0
drop if A1<=0
*drop if A1<=0
*drop if L3<=0
drop if C<=0
drop if D<=0
drop if H<=0 


***************************************************
*********** EXPORT TO EXCEL ***********************
***************************************************

***** set appropriate file path *****

**  outsheet using "D:\R E S E A R C H\SFA workshop\DATA\DAIRY RAW.raw", replace


***************************************************
************ STATA MODELS *************************
***************************************************

***** set for panel analysis *****
tsset pid T


***** mean adjust and convert to logs ***** 

egen mY=mean(Y1)
egen mH=mean(H)
egen mC=mean(C)
egen mL=mean(L2)
egen mD=mean(D)
egen mA=mean(A1)

gen lnY=log(Y1/mY)
gen lnH=log(H/mH)
gen lnC=log(C/mC)
gen lnL=log(L2/mL)
gen lnD=log(D/mD)
gen lnA=log(A1/mA)

****************************************************
********** Production Functions ********************
****************************************************

***** cobb-douglas *****
regress lnY lnH lnC lnL lnD lnA


***** add technical change *****
regress lnY lnH lnC lnL lnD lnA T

gen TT=T*T
regress lnY lnH lnC lnL lnD lnA T TT

gen TTT=TT*T
regress lnY lnH lnC lnL lnD lnA T TT TTT

regress lnY lnH lnC lnL lnD lnA T2 T3 T4 T5 T6 T7 T8 T9  


***** translog functional form *****
gen lnHH=lnH*lnH
gen lnHC=lnH*lnC
gen lnHL=lnH*lnL
gen lnHD=lnH*lnD
gen lnHA=lnH*lnA
gen lnCC=lnC*lnC
gen lnCL=lnC*lnL
gen lnCD=lnC*lnD
gen lnCA=lnC*lnA
gen lnLL=lnL*lnL
gen lnLD=lnL*lnD
gen lnLA=lnL*lnA
gen lnDD=lnD*lnD
gen lnDA=lnD*lnA
gen lnAA=lnA*lnA

gen lnHT=lnH*T
gen lnCT=lnC*T
gen lnLT=lnL*T
gen lnDT=lnD*T
gen lnAT=lnA*T

***** translog with time dummies ***** 
*regress lnY lnH lnC lnL lnD lnA lnHH lnHC lnHL lnHD lnHA lnCC lnCL lnCD lnCA lnLL lnLD lnLA lnDD lnDA lnAA T2 T3 T4 T5 T6 T7 T8 T9  

***** translog with time trend - non-neutral technical change *****
*regress lnY lnH lnC lnL lnD lnA lnHH lnHC lnHL lnHD lnHA lnCC lnCL lnCD lnCA lnLL lnLD lnLA lnDD lnDA lnAA T TT lnHT lnCT lnLT lnDT lnAT  
*/
