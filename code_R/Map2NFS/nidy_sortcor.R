# GET DESCRIPTIONS FOR THE VARIABLES I HAVE IN THE DATA
# Loads Irish FADN dataset and the RICA datawarehouse dictionary, then searches descriptions for matches.
rm(list=ls())
datadir <- "/media/MyPassport/Data/"
dirstruct(datadir)

# import, subset, and extract varnames from fadn
fadn <- data.table(read.csv(paste(fadn9907dir, "Ireland.csv", sep='')))
setkey(fadn, "YEAR", "A30")
fadn[A30==4110,length(Farm.Code), by=YEAR]
f05 <- fadn[J(2005, 4110)]
f05[,length(Farm.Code)]
fadn.names <- data.table(fadn = names(fadn))


# import, subset, and extract varnames from nfs
nfs <- data.table(read.dta(paste(nfsoutdata, "nfs_data.dta", sep='')))
setkey(nfs, year, fffadnsy)
nfs[fffadnsy==411, length(farmcode), by=year]
n05 <- nfs[J(2005, 411)]
n05[,length(farmcode)]

# now have comparable datasets
# sort and correlate
scor <- function(DT1, DT2, ...)
          f05[, sapply(list(YEAR, Total.UAA), function(x) paste(names(f05)[x],".obj"))]
                            #n05[1:2,sapply(.SD, function(n.j) setkey(n05,n.j) cor(f.j,n.j))])]



# fadn.dict <- data.table(read.csv(paste(fadnorigdata, "fadndict.csv", sep='')), key="DESCRIPTION")
# # documentation for data tables discourages using the <- operator for creating new columns (inefficient)
# # but trying to create the match column via the := operator throws a fatal error for some reason.
# # Still very quick anyway.
# match <- fadn.names[,grep(fadn, levels(fadn.dict[selected=="y",DESCRIPTION]), ignore.case=T, value=T), by=fadn]
# fcode <- match[, list(fcode = fadn.dict[DESCRIPTION==.BY, NAME]), by=V1]
# setkey(match,V1)
# setkey(fcode,V1)
# match <- match[fcode]
# setnames(match, "V1", "DESCRIPTION")
# 
# #nfs.names <- data.table(nfs = names(nfs))
# nfs.dict <- data.table(read.csv(paste(nfsdir, "nfsdict.csv", sep='')))[,1:2, with=F]
# nfs.dict[, Variable.Description := gsub("\\(", "", Variable.Description)]
# nfs.dict[, Variable.Description := gsub("\\)", "", Variable.Description)]
# ndesc <- match[,grep(DESCRIPTION, nfs.dict[,Variable.Description], ignore.case=T, value=T), by=DESCRIPTION]
# npos <- match[,grep(DESCRIPTION, nfs.dict[,Variable.Description], ignore.case=T), by=DESCRIPTION]
# #nmatch <- data.table(DESCRIPTION= ndesc[,DESCRIPTION], nfs.dict[npos[,V1]])
# nmatch <- nfs.dict[npos[,V1], DESCRIPTION := ndesc[,DESCRIPTION]]
# setkey(nmatch, "DESCRIPTION")
# 
# match <- nmatch[match]
# matchkey <- match[Variable.Name!="NA",list(fadn, Variable.Name, DESCRIPTION, Variable.Description)]
# viewData(matchkey)
# cor(f05[,matchkey[1,fadn, with=F], n05[,matchkey[1,Variable.Name, with=F]]])
# f05[,matchkey[1,fadn], with=F]


