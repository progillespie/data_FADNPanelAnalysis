rm(list=ls())
library(parallel)
library(iterators)
library(doParallel)
library(foreach)
library(data.table)
library(frontier)


fadn <- plm.data(read.csv("/media/MyPassport/Data/data_FADNPanelAnalysis/OutData/multisward/exported_data.csv")
                 ,indexes=c("pid","year"))
fadn <- data.table(fadn, key=c("country","pid", "year"))
#View(fadn)



# split fadn data over levels of country
country.split <- split(fadn, fadn[,list(country)])
summary(country.split)



# create a cluster using local CPU cores (multi-threading)
cl <- makeCluster(detectCores())
registerDoParallel(cl)
#View(detectCores())



# lm.models <- foreach(i=country.split) %dopar% {
#   results<- summary(lm(lntotalinputs ~ 
#                           lndotomkgl 
#                         + lnPCompoundfeedingstuffsforcatt 
#                         + lnPFERTILISERSANDSOILIMPROVERS
#                         , data=i
#   )
#   );
#   return(results)
# }
# lm.models


# bc92.models <- foreach(i=country.split) %dopar% {
#   library(frontier)
#   results<- summary(sfa(lntotalinputs ~ 
#                            lndotomkgl 
#                          + lnPCompoundfeedingstuffsforcatt 
#                          + lnPFERTILISERSANDSOILIMPROVERS
#                          , data=i          
#                          , ineffDecrease=FALSE
#                          , truncNorm=TRUE
#                          , maxit=30
#                         )
#                     );
#   return(results)
# }
# bc92.models


# bc95.models <- foreach(i=country.split) %dopar% {
#   library(frontier)
#   results<- summary(sfa(lntotalinputs ~ 
#                           lndotomkgl 
#                         + lnPCompoundfeedingstuffsforcatt 
#                         + lnPFERTILISERSANDSOILIMPROVERS
#                         | fdratio
#                         , data=i          
#                         , ineffDecrease=FALSE
#                         , truncNorm=TRUE
#                         #, maxit=30
#   )
#   );
#   return(results)
# }
# bc95.models


bc95.models <- foreach(i=country.split) %dopar% {
  library(frontier)
  results<- summary(sfa(lntotalinputs ~ 
                          X_1 
                        + X_2
                        + X_3
                        | fdratio
                        , data=i          
                        , ineffDecrease=FALSE
                        , truncNorm=TRUE
                        #, maxit=30
  )
  );
  return(results)
}
bc95.models

stopCluster(cl)
STOP!!!


bc95_IE <- sfa(lntotalinputs ~ 
                 lndotomkgl
               + lnPCompoundfeedingstuffsforcatt 
               + lnPFERTILISERSANDSOILIMPROVERS 
               | fdratio
               , data=fadn[country=="IRE"]
               , ineffDecrease=FALSE
               , truncNorm=TRUE )
summary(bc95_IE)



# Plots of feed ratio variable
plot(fdrat_mn[country=="IRE", cbind(year, V1)], type="l", lwd="2.5"
     , col="green", main="FEED RATIOS", ylim = c(0, 0.5)
     )

  points(fdrat_mn[country=="UKI", cbind(year, V1)], type="l"
    ,lwd="2.5", col="red"
         )

  points(fdrat_mn[country=="DEU", cbind(year, V1)], type="l"
    ,lwd="2.5", col="blue"
         )

  points(fdrat_mn[country=="FRA", cbind(year, V1)], type="l"
      ,lwd="2.5", col="black"
         )

  legend(7,.49
       ,c("IRE","UKI","DEU", "FRA")
       ,lty=c(1,1,1,1)
       ,lwd=c(2.5,2.5,2.5,2.5)
       ,col=c("green","red", "blue","black")
         ) 
