# clear all objects from the workspace
rm(list=ls())

# specify the project's 'root directory'
paneldir <- "/media/MyPassport/Data/data_NFSPanelAnalysis/"
source(paste(paneldir, "code_R/dirstruct.R", sep='')) 
setwd(Rdir) # set working directory - see what it is with getwd()
# and start a log file. R log files get text output only... no graphs, no commands. No comments either - unless inside cat().

sink(file=paste(outdatadir, "testlog.txt", sep=''))       

# ********************************************************
# ********************************************************
# * Patrick R. Gillespie\n      	
# * Walsh Fellow\n
# * Teagasc, REDP\n				
# * Athenry, Co Galway, Ireland\n
# * patrick.gillespie@teagasc.ie\n	
# *
# ********************************************************
# Log file for draft_nidy.R.
#This Rscript was last run on..." 
date()
#********************************************************
sink() 
# turns off the log file until we get to interesting output


# load the required libraries (R packages... sets of commands you can use)
library(foreign) # used here for the ability to read .dta files
library(data.table) # very useful for big datasets (makes manipulation quicker & easier)

       
#------------------------------------------------------------#       
# Setting up the data
#------------------------------------------------------------#       
       
# read the Stata dataset into an object (it will be a data frame class of object)...
nfs <- read.dta(paste(nfsdatadir, "nfs_data.dta", sep=''))
         #NOTE: read.dta() needs a filepath, but I've opted not to hardcode it (i.e. just type it in), Instead, I
         #store parts of the filepath as ojects themselves and then paste() on the last bit as appropriate. We've 
         #used macros in Stata to accomplish the same thing, and the effect is you only have to specify the correct 
         #'project root' once. All other filepaths are relative to paneldir
   
       
# reclassify the object as data.table (new type of data.frame object. easier to use)
nfs <- data.table(nfs)
setkey(nfs, farmcode, year)

       # if you wanted to, you could save/load in R data format using the following
       #save(nfs, file=paste(outdatadir, "nfs_data.R", sep=''))
       #load(paste(outdatadir, "nfs_data.R", sep=''))
       
       # but it's probably just as handy to save in Stata formatted files using
       #write.dta()

# Project specific files with complete filepaths specified. You can simply give these objects to the 
# save/write.dta command. Second argument of paste() is the filename you save the file as. 
#intdata <- paste(outdatadir, "test.R", sep='') 
      #intdata2 <- paste(outdatadir, "", sep='') 
      #intdata3 <- paste(outdatadir, "", sep='') 
      # etc....

# # so for example, if i create some data
# test <- data.frame(x=c(1:10), y=c(10:1), row.names=NULL)
# # this saves that object as a .dta in your outdatadir with the filename you chose
# write.dta(test, intdata)
# # which you can then read back in...
# read.dta(intdata)
# but note that it's just screen output until I store it in an object...

       
# Get regional weights from file in outdatadir then merge...
regional.weights <- read.dta(paste(regional.outdatadir, "regional_weights.dta", sep=''))
   
  # there is a merge() command in R, but...
  #nfs <- merge(nfs, regional.weights, by=c("farmcode", "year"))
       
# ... the data.tables package provides the := operator which is pretty fast
nfs[, rweight:=regional.weights$rweight, by=list(farmcode, year)]
nfs[, region:=regional.weights$region, by=list(farmcode, year)]       
# for the sake of computing efficiency, you should remove objects you don't need anymore using rm()...
rm(regional.weights)
       
       
sink(file=paste(outdatadir, "testlog.txt", sep=''), append=T)       
# because we have a data.table we can use this object class' improved subsetting capabilities
# to create the R equivalent of Stata's <tabstat wt region, by(year)> with
cat("\n\n\n\t\t\t Mean of wt and region, by year (comparable to Stata command <tabstat wt region, by(year)>")
nfs[, list(mean(wt), mean(region)), by=year]
# # and it's just as easy with any function or expression in the middle term, e.g. weighted mean
# nfs[, list(weighted.mean(wt, wt), weighted.mean(region, wt)), by=year]
# # ... although that makes no sense here.
       
       
# This is admittedly a few more keystrokes than <tabstat wt region, by(year)>, but this is an example
# of doing things "the Stata way" inside of R (bad idea). Do it the R way instead, i.e. create a new object which is
# the collapsed dataset. Again, using the <data.table> package...
       
nfs.yr <- nfs[,lapply(.SD, mean), by=year]
       # NOTE: .SD is a symbol meaning Subset of Data Table. It's a shortcut for 
       # avoiding long lists of column names for that second term (j term in the package's terminology)

# You now have both the collapsed, and the uncollapsed data in memory simultaneously! In Stata you can only hold
# one dataset in memory at a time, which means a lot of loading and saving. In R, you just reference the object
# you want.
       
cat("\n \n \n    Yearly per farm means of selected variables (unweighted) \n", fill=T)
nfs.yr[,list(year, fsizuaa, daforare, farmgo, farmdc, farmohct, farmgm)]

       
cat("\n \n \n  Yearly per farm means of selected variables (unweighted and transposed)\n", fill=T)
t(nfs.yr[,list(year, fsizuaa, daforare, farmgo, farmdc, farmohct, farmgm)])
       
       
# That collapsed table is also very handy for generating descriptives! We can even save keystrokes by 'attaching' 
# the collapsed data.
       
attach(nfs.yr) # When attached, we don't have to write nfs.yr$ before varnames
png(file=paste(outdatadir,"graphtest.png",sep='')) #save's graphs
plot(year, fsizuaa
     , type="l"
     , lwd=2
     , ylim=c(0,75)
     , ylab="mean hectares per farm")
       
# ... it's  easy to overlay another series on the graph...
points(year, daforare
       , type="l"
       , lwd=1 )
dev.off() # tells R you're done graphing. Don't forget this command, otherwise your graphs won't work!
detach(nfs.yr) # Can only attach one object at a time, so detach() when done
## attach() and detach() just alter R's "focus". All objects remain in memory the whole time, 
## and you can still manipulate any object by specifying its name before varname, e.g. nfs$year

#end of file
sink()