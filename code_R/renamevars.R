# This file extracts the var names from to FADN datasets (i.e. 
# "the Standard results" and a subsequent data request which was
# mostly tillage related variables). The 
library("stringr")
rm(list=ls())

datadir = "/media/MyPassport/Data/"
dirstruct(datadir)

# read NAME and DESCRIPTION columns of csv version of second worksheet
# of any #model_rica_datawarehouse variables...(etc.) type file, which will
# have been provided along with the actual data. This is a type of data
# dictionary spreadsheet which complements the documentation provided in 
# RI/CC 882 and RI/CC 1256 (both available on the Internet). Create the 
# csv file, then make sure that the command below is given the appropriate
# filename and filepath to it. 
fadn.dict <- data.table(read.csv(
  paste(fadndir
        , "SupportDocs/fadndict.csv"
        , sep=''
        )
  )
  , key = "NAME"
)[,2:3, with=F]


# import Irish data for both FADN datasets 
fadn <- data.table(read.csv(paste(fadn9907dir, "Ireland.csv", sep='')))
fadn2 <- data.table(read.csv(paste(fadn2dir, "ire2005.csv", sep='')))

# names() gives a list of the varnames in the respective files. c()
# puts the two lists together, and we store as a data table called fadn.names. 
# length() gives the number of varnames we have (stored in default V1 of fadn.names)
# we can see we've put them together correctly. 
length(names(fadn))
length(names(fadn2))
length(c(names(fadn),names(fadn2)))
fadn.names <- data.table(c(names(fadn),names(fadn2)))
fadn.names[,length(V1)]
# str_pad places leading 0's in FADN code. prevents spurious matches (A2 != A24)
#   in the grep() command below
fadn.names[,padV1 := str_pad(V1,5,side="left", pad = "0")]

# now we have a single list of all the names, but some are alpha-numeric
# codes (as FADN would have originally supplied them) and others have been
# given descriptive names (better to work with). The following commands
# will search fadn.names[,V1] (i.e. the mixed list of names in the data)
# and replace any alpha-numerics with descriptive names using the DESCRIPTION
# column of fadn.dict 
# str_pad places leading 0's in FADN code. prevents spurious matches (A2 != A24)
fadn.dict[,padNAME := str_pad(NAME,5,side="left", pad ="0")]

# creates key for matched var names using line positions in fadn.names
alphapos <- fadn.dict[, list(grep(padNAME, fadn.names[,padV1], fixed=T), NAME, DESCRIPTION), by=padNAME]

# updates V1 in fadn.names (the column with the names in it)
fadn.names[alphapos[V1!="NA",V1], V1:= alphapos[V1!="NA",DESCRIPTION]]
View(fadn.names)

write.csv(fadn.names, 
          paste(fadndir
          , "SupportDocs/listfadnvars.csv"
          , sep=''
          )
)
