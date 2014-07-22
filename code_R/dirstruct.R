#*****************************************************
# This file gives the basic file structure to REDP
# projects using the FADN. It is meant to be generic
# so project specific tasks should be carried out in a 
# separate script which calls this one in its heading.
#*****************************************************

# First - Define paneldir as the project's root directory in your project's Rscript. 
# All other filepaths will be defined relative to this one.

# These two directories always reside in data_NFSPanelAnalysis project directory, no matter
# which project you're working on. Will always look for data_NFSPanelAnalysis one directory above paneldir
nfsdatadir <- paste(paneldir, "../data_NFSPanelAnalysis/OutData/", sep='')
regional.outdatadir <- paste(paneldir, "../data_NFSPanelAnalysis/OutData/RegionalAnalysis/", sep='') 

# FADN panel data always resides in data_FADNPanelAnalysis, no matter which project you're working on
# ... will always look for data_FADNPanelAnalysis one directory above paneldir
fadndir <- paste(paneldir, "../data_FADNPanelAnalysis/OrigData/", sep='')
fadndir9907 <- paste(fadndir, "eupanel9907/csv/", sep='')
fadndir0407 <- paste(fadndir, "eupanel0407/csv/", sep='')
fadndir2 <- paste(fadndir, "FADN_2/TEAGSC/", sep='')

# All other filepaths (should be relative to your project's definition of paneldir (directly or indirectly))
Rdir <- paste(paneldir, "code_R/", sep='') 
outdatadir <- paste(paneldir, "OutData/", sep='')
origdatadir <- paste(paneldir, "OrigData/", sep='') 







