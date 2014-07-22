rm(list=ls())

datadir = "/media/MyPassport/Data/"
dirstruct(datadir)

nfs <- data.table(read.dta(paste(nfsoutdata, "nfs_data.dta", sep='')))
setkey(nfs, farmcode, year)
nfs <- nfs[year==2005]
nfs[, length(farmcode), by="year"]
#fadn <- data.table(read.csv(paste(fadn2dir, "ire2005.csv", sep='')))
fadn <- data.table(read.csv(paste(fadn9907dir, "Ireland.csv", sep='')))

#fadn[,length()]
names(fadn)

