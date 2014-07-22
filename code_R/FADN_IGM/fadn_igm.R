# running ti and tvd SFA models on FADN data for multisward
# tvd in Stata runs slowly and never converges in some cases. Just
# checking how it performs here.
rm(list=ls())
library("foreign")
library("plm")
library("data.table")
library("frontier")

datadir <- "/media/MyPassport/Data/data_FADNPanelAnalysis/OutData/FADN_IGM"
setwd(datadir)

fadn <- plm.data(read.dta("SFA_post.dta"), c("pid", "year"))
save(fadn, file="SFA_post.Rdata")
load("SFA_post.Rdata")
# logs of paid and unpaid labour were missing, so calculate them again
# fadn$lnflabpaid <- log(fadn$flabpaid)
# fadn$lnflabunpd <- log(fadn$flabunpd)
colnames(fadn)[grep("GREGION", names(fadn))] <- c("Bretagne"
    , "NormandieHaute", "NormandieBasse", "Wales", "Ireland.too"
    , "Bayern", "OtherRegions")
colnames(fadn)[grep("COUNTRY", names(fadn))] <- c("Germany"
    , "France", "Ireland", "UK")

# This is the model's equation (i.e. the list of y the x's)
# In Stata this is a local macro with just the varnames separated with 
# a space. Here the syntax requires the "~" and "+" characters between
# and the COUNTRY dummies have been added to it
lnfdairygo_lu_vlist1 <- lnfdairygo_lu ~ lnlandval_ha + lnfdferfil_ha  + 
      lndaforare + lndpnolu_ha + lnflabpaid + lnflabunpd + ogagehld + 
      lnfsizuaa + lnfdratio + azone2 + azone3 + hasreps + teagasc   +
      France + Ireland + UK + Bretagne + NormandieHaute + NormandieBasse +
      Wales + Bayern

# meta frontier, time invariant model  
system.time(meta.model.ti <- sfa(lnfdairygo_lu_vlist1, fadn, truncNorm=T)) 
write.csv(summary(meta.model.ti)["mleParam"], "../../code_R/FADN_IGM/sfa_ti_out_R.csv") 
summary(meta.model.ti)  

# meta frontier, time varying decay model  
system.time(meta.model.tvd <- sfa(lnfdairygo_lu_vlist1, fadn, truncNorm=T, timeEffect=T)) 
write.csv(summary(meta.model.tvd)["mleParam"], "../../code_R/FADN_IGM/sfa_tvd_out_R.csv")
summary(meta.model.tvd)

# meta frontier, time varying decay model, efficiency effects frontier
system.time(meta.model.tvd.eef <- sfa(lnfdairygo_lu ~ lnlandval_ha + 
                                      lnfdferfil_ha  + lndaforare + 
                                        lndpnolu_ha + lnflabpaid + 
                                        lnflabunpd + ogagehld + 
                                        lnfsizuaa + lnfdratio + 
                                        azone2 + azone3 + hasreps + 
                                        teagasc + France + Ireland + 
                                        UK + Bretagne + NormandieHaute + 
                                        NormandieBasse + Wales + Bayern
                                      |ogagehld, fadn, timeEffect=T))

write.csv(summary(meta.model.tvd.eef)["mleParam"], "../../code_R/FADN_IGM/sfa_tvd_eef_out_R.csv")
summary(meta.model.tvd.eef)

dir("../../code_R/FADN_IGM/")

