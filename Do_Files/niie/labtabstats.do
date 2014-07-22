use ../OutData/IGM/data1
append using ../OutData/IGM/data2
drop if country=="UKI"
qui append using ../OutData/IGM/data2

do sub_do/cex_vargen
collapse exchangerate cex if country=="UKI", by(year)
tw (line exchangerate year) (line cex year)
restore

tabstat lt_lu, by(country)

gen     lt_labu   = dotomkgl  /(labourinputhours)
replace lt_lu     = dotomkgl  /dpnolu
replace lt_ha     = dotomkgl  /daforare
gen     lt_ha     = dotomkgl  /daforare
gen     labu_ha   = labourinputhours/totaluaa
gen     labu_lu   = labourinputhours/totallivestockunits
/* contractwork measured in euro. Includes machin. hire too, so not directly
    comparable with other farm labour. However, we can calc. a rough measure
	of the contract hours which tells us what amount of normal paid labour equates
	to the same expenditure (although not necessarily the same work or production). 
*/
gen 	meanwage  = wagespaid  /flabpaid
gen 	flabcont  = contractwork  /meanwage

tabstat wagespaid contractwork if country=="IRE" [weight=wt], by(year) format(%9.0f)
tabstat wagespaid contractwork if country=="UKI" [weight=wt], by(year) format(%9.0f)

tabstat labu_ha  totaluaa labourinputhours flabunpd flabpaid if country=="IRE" [weight=wt], by(year) format(%9.0f)
tabstat labu_ha  totaluaa labourinputhours flabunpd flabpaid contractwork if country=="UKI" [weight=wt], by(year) format(%9.0f)

tabstat lt_labu lt_lu lt_ha, by(country) format(%9.0f)
tabstat flabunpd flabpaid, by(country) format(%9.0f)

tabstat labu_ha  totaluaa dpalloclu if country=="IRE" [weight=wt], by(year) format(%9.2f)
tabstat labu_ha  totaluaa dpalloclu if country=="UKI" [weight=wt], by(year) format(%9.2f)

tabstat labu_lu labourinputhours totallivestockunits if country=="UKI" [weight=wt], by(year) format(%9.2f)
tabstat labu_lu labourinputhours totallivestockunits if country=="IRE" [weight=wt], by(year) format(%9.2f)
tabstat labu_lu labourinputhours totallivestockunits if country=="UKI" [weight=wt], by(year) format(%9.2f)


tabstat labu_lu stockingdensity if country=="IRE" [weight=wt], by(year) format(%9.2f)
tabstat labu_lu stockingdensity if country=="UKI" [weight=wt], by(year) format(%9.2f)


tabstat milkyield dotomkgl dpnolu if country=="IRE" [weight=wt], by(year) format(%9.2f)
tabstat milkyield dotomkgl dpnolu if country=="IRE" [weight=wt], by(year) format(%9.0f)
tabstat milkyield dotomkgl dpnolu if country=="UKI" [weight=wt], by(year) format(%9.0f)



log close
