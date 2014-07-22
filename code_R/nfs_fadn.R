rm(list=ls())
paneldir <- "/media/MyPassport/Data/data_NFSPanelAnalysis/"
source(paste(paneldir, "code_R/dirstruct.R", sep='')) 
setwd(Rdir)
logfile <-paste(outdatadir, "nfs_fadn.Rlog", sep='') # specify log path and name
sink(logfile, split=TRUE) # then turn log on      
cat("********************************************************\n
********************************************************\n
* Patrick R. Gillespie\n      	
* Walsh Fellow\n
* Teagasc, REDP\n			
* Athenry, Co Galway, Ireland\n
* patrick.gillespie@teagasc.ie\n
********************************************************\n
Log file for nfs_fadn.R\n
This Rscript was last run on...\n",date(),
"\n*********************************************************")
#sink() # turns off log until we get to interesting output
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#

library(foreign) # used here for the ability to read .dta files
library(data.table) # very useful for big datasets (makes manipulation quicker & easier)

       
#-----------------------------------------------------------#       
# Setting up the data
#------------------------------------------------------------#       
       
# read the Stata dataset into a data.table (type of data.frame - useful for large datasets)
# and ID the key variables (i.e. like subscripts for the data). Sorts by those too.         
nfs <- data.table(read.dta(paste(nfsdatadir, "nfs_data.dta", sep='')))
setkey(nfs, farmcode, year)

# Get regional weights from file in outdatadir then merge...
regional.weights <- data.table(read.dta(paste(regional.outdatadir, "regional_weights.dta", sep='')))
setkey(regional.weights, farmcode, year)

# This is the command to merge the two data tables. There is a merge() command in R
# but this is much quicker. In this case the [] operator merges, rather than subsets, 
# because its first argument is another data table. Type vignette("datatable-faq") 
# to see a pdf document in which this is addressed (search for the text X[Y]). You 
# can also type ?data.table or simply Google "merge, data.table, R" for more.
nfs <- regional.weights[nfs] 

# just to make sure that we got what we expected...
summary(nfs[,list(rweight, region)])
summary(regional.weights[,list(rweight, region)])

rm(regional.weights)
#sink(logfile, split=TRUE, append=T)
#oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo#
#oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo#


# the R equivalent of Stata's <tabstat wt region, by(year)> (using the data.table package)
cat("\n\n\n\t\t\t Mean of wt and region, by year (comparable to Stata command <tabstat wt region, by(year)>")
nfs[, list(mean(wt), mean(region)), by=year]
       
       
# can collapse the data and save it as a separate data.table       
nfs.yr <- nfs[,lapply(.SD, mean), by=year]
       # NOTE: .SD is a symbol meaning Subset of Data Table. It's a shortcut for 
       # avoiding long lists of column names for that second term (j term in the package's terminology)

cat("\n \n \n    Yearly per farm means of selected variables (unweighted) \n", fill=T)
nfs.yr[,list(year, fsizuaa, daforare, farmgo, farmdc, farmohct, farmgm)]
       
cat("\n \n \n  Yearly per farm means of selected variables (unweighted and transposed)\n", fill=T)
t(nfs.yr[,list(year, fsizuaa, daforare, farmgo, farmdc, farmohct, farmgm)])
       
       
# using collapsed data to generate descriptives
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
dev.off() # tells R you're done with this graph 
detach(nfs.yr) # undoes attach()


#end of file
#sink()