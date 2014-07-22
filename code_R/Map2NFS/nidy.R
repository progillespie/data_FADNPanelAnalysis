rm(list=ls()) 
#paneldir <- "/media/MyPassport/Data/data_NFSPanelAnalysis/"
paneldir <- "D:\\Data/data_NFSPanelAnalysis/"
source(paste(paneldir, "code_R/dirstruct.R", sep='')) 
setwd(Rdir)
library(foreign) #...for the ability to read .dta files
library(data.table) #... for big datasets (manipulate faster & easier)
library(xtable) #... to get nice looking tables.



nfs <- data.table(read.dta(paste(nfsdatadir
                                 , "nfs_data.dta"
                                 , sep='')), key="fffadnsy")
nfs <- nfs[fffadnsy==411]
setkey(nfs, farmcode, year) # reset key
nfs.farms <- nfs[year>1998 & year<2008
                 , length(farmcode), by=year]



fadn <- data.table(read.csv(paste(fadndir9907
                                  , "Ireland.csv"
                                  , sep=''))
                   , key="A30")
fadn <- fadn[A30==4110]
setkey(fadn, Farm.Code, YEAR) # reset key
fadn.farms <- fadn[, length(Farm.Code), by=YEAR]

xtable(data.frame(NFS=nfs.farms$V1
                  , FADN=fadn.farms$V1
                  , row.names=nfs.farms$year)
       , "Sampled Specialist Dairy farms by year")



# create two new data tables, with varnames and mean values
nfs05 <- nfs[year==2005]  
fadn05 <-fadn[YEAR==2005]

# round off the means in hopes of getting exact matches this way
#nfs05[, Means:=round(Means)]
#fadn05[, Means:=round(Means)]

# set the key for each to the farm size variables 
#   in each dataset (which I think match up)
setkey(nfs05, fsizuaa)
setkey(fadn05, Total.UAA)



# create a logical vector for the comparison of total uaa
nfs05$in.range <- nfs05$fsizuaa >= .99*fadn05$Total.UAA & nfs05$fsizuaa <= 1.01*fadn05$Total.UAA
# copy the UAA variable and fadn farmcode from the fadn to the nfs data
nfs05$Total.UAA <- fadn05$Total.UAA
nfs05$Farm.Code <- fadn05$Farm.Code
# have a look at the data to double check it's what we expect
View(nfs05[in.range==TRUE,list(in.range, farmcode, fsizuaa, Farm.Code,  Total.UAA)])
#viewData(nfs05[in.range==TRUE,list(in.range, farmcode, fsizuaa, Farm.Code,  Total.UAA)]) # for viewing data within the GUI if you are using the most recent version of RStudio

# count of farmcodes with matching UAA in both datasets
length(nfs05[in.range==TRUE, farmcode])

# select one of these farmcodes to compare variable by variable for potential variable matches (creating a key). 
nfs.in.range <- nfs05[in.range==TRUE]
nfs.farm <- nfs.in.range[1] 
length(names(nfs.farm)) # number of variables starting out
nums <- nfs.farm[,sapply(.SD, is.numeric)] # numeric variables
nfs.farm <- nfs.farm[,nums==T, with=F] # select only those variables
length(names(nfs.farm)) # number of variables after selection
over0 <- nfs.farm[,sapply(.SD, function(x) x>0)] # variables with value > 0
nfs.farm <- nfs.farm[, over0==T, with=F] # select only those variables
length(names(nfs.farm)) # number of variables after selection

# store the corresponding farm ID's for each dataset
farmcode.sel <- nfs.farm[,farmcode]
Farm.Code.sel <- nfs.farm[,Farm.Code]


# extract corresponding row from FADN
fadn.farm <- fadn05[Farm.Code== Farm.Code.sel]
length(names(fadn.farm)) # number of variables starting out
nums <- fadn.farm[,sapply(.SD, is.numeric)] # numeric variables
fadn.farm <- fadn.farm[,nums==T, with=F]
length(names(fadn.farm)) # number of variables after selection
over0 <- fadn.farm[,sapply(.SD, function(x) x>0)] # variables with value > 0
fadn.farm <- fadn.farm[,over0==T, with=F]
length(names(fadn.farm)) # number of variables after selection


# transpose both and search fadn column for possible matches for each value of the NFS column
nfs.farm <- data.table(na.omit(data.frame(nfs.names = names(nfs.farm), values=t(nfs.farm), row.names=NULL, stringsAsFactors=F)), key="values")

fadn.farm <- data.table(na.omit(data.frame(fadn.names = names(fadn.farm), values = t(fadn.farm), row.names=NULL, stringsAsFactors=F)), key="values")

# creates a logical matrix for potential matches
key <- nfs.farm[,sapply(.SD, function(x) ifelse(x >= .98*fadn.farm$values & x <= 1.02*fadn.farm$values, fadn.farm$fadn.name, NA))] # ], fadn.names=fadn.farm$fadn.names),by=nfs.names]


# now collapse that to a list of names of fadn variable names for each nfs variable name

key2 <- data.table(key)
key2 <- key2[, sapply(.SD, function(x) list(na.omit(x)))]
View(key2)


save(key2, file="key2.Rdata")