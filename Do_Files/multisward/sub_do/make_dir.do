********************************************************
********************************************************
*       Patrick R. Gillespie                            
*       Walsh Fellow                    
*	FADN_IGM/sub_do/make_dir.do
********************************************************
* Create folder output and its subfolders if they
*   don't already exist 
********************************************************
capture mkdir $outdatadir
capture mkdir $origdatadir
capture mkdir $fadn9907dir
capture mkdir $fadn2dir
capture mkdir output
capture mkdir output/docs
capture mkdir output/graphs
capture mkdir logs/results
