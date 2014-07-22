dirstruct(datadir)

# reads each line of code in doFarmDerivedVars.do (1 line per cell)
doFarm <- data.table(lines = scan(
      paste(nfsdir, "Do_Files/REDP_Book/doFarmDerivedVars.do", sep='')
      , what=character()
      , comment.char="*"
      , sep="\r"
      )
)

# reads first three columns of csv version of Data Dictionary (Data 
# Dictionary Sheet)
nfs.dict <- data.table(read.csv(
        paste(nfsdir
              , "nfsdict.csv"
              , sep=''
              )
        )
        , key = "Variable.Name"
)[,1:2, with=F]

# for each variable name listed in the Data Dictionary, search all the 
# lines of doFarmDerivedVars for a call to that variable (returning a 
# logical vector for each line on which it is used). Since I just want 
# to know if it's used at all, subset that vector to just the matches, 
# and output "y" if the length of the subset > 0 (i.e. there was at least
# one match), or output "n" otherwise. Store the y's and n's in a new 
# column in nfs.dict called InDoFarm and write out a new csv.
nfs.dict[Variable.Name!=""
     , InDoFarm:= ifelse(
          length(data.table(grepl(Variable.Name, doFarm[,lines]))[V1==TRUE,V1])>0
          ,"y"
          ,"n"
          )
,by=Variable.Name]

nfs.dict[, Variable.Description := gsub("\\(", "", Variable.Description)]
nfs.dict[, Variable.Description := gsub("\\(", "", Variable.Description)]
nfs.dict[, Variable.Description := gsub("\\)", "", Variable.Description)]
nfs.dict[, Variable.Description := gsub("\\)", "", Variable.Description)]

# get names of FADN variables in data, clean up, and store in character vector
fadn.names <- names(read.csv(paste(fadn9907dir, "Ireland.csv", sep=''), nrows=1))

# print them to screen to check (there's not too many)
fadn.names

# search for matches in Variable Description and list them in a new column of nfs.dict called FADN
nfs.dict[Variable.Description!="",FADN:=paste0(grep(Variable.Description, fadn.names, ignore.case=T, value=T), collapse=","), by=Variable.Description]


# write out to csv files
write.csv(nfs.dict
        , file=paste(nfsdir
        ,"InDoFarm.csv"
        , sep=''
        )
)

write.csv(fadn.names
        , file=paste(fadndir, "fadnnames.csv", sep=''
        )
)