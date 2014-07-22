********************************************************
********************************************************
* Author:    
*	Patrick R. Gillespie				
*	Walsh Fellow from 2010-2014
*	Teagasc, REDP				
*	patrick.gillespie@teagasc.ie		
*
********************************************************
*
* This file explains the structure and usage of  
*  this project folder. 
*
********************************************************


DO NOT REMOVE THIS FILE FROM THIS FOLDER!
BE SURE TO READ THE COMMENTS IN THE DO-FILES!


1: Master files control the whole analysis. All do files in 
    this project folder's root should be masters. 


2: The folder sub_do contains support files. Each has a 
    specific task, and they are intended to be called 
    by a master file. IN MANY CASES, RUNNING A FILE DIRECTLY
    FROM /sub_do WON'T WORK!


3: Update the CD command at the top of the relevant master 
    to point to this folder


4: You may rename the project folder where this file lives, 
    or any parent directory of it, but don't move/rename any 
    subfolders or files until you're comfortable with how 
    they work. Even then, create a copy beforehand. 


5: This project folder is not portable; it requires the data 
    stored in a subfolder with the same name as this one, but
    located in OrigData (two levels up). However, if you copy 
    both of these folders, and place them in your own OutData 
    and Do_Files folders, then the files should run, and they
    should create any other needed folders for you. 



Contents of this project folder

   >> output		 -- subdirectory which contains all the 
			     generated output 

	>>> docs	 -- for Text documents (doc files) and 
			     formatted results (rtf files)

	>>> spreadsheets -- csv files for use in spreadsheets 
			     (collapsed data)

	>>> graphs	 -- for graphs


   >> sub_do		 -- subdirectory with all the do-files 
			     called by a master file

	+ <various>.do   -- do files which are called by a master. 


   >> logs		 -- for log files

	+ <file>.smcl  	 -- Log documenting the most recent run of 
			     master file (for diagnostics)

	+ <file>.txt   	 -- Cmd Log documenting the most recent run 
			     of master file (diagnostic)

	> results   	 -- logs for model results specifically. May 
			     or may not be used.

   + README.txt	   	 -- this file

   + <various>.do	 -- Master do files which run analysis from raw 
			     data through to finished output. 



Required Data Directories   	

-- on my system these are stored in "Data/data_FADNPanelAnalysis/OrigData


   >> eupanel0407	-- 2004 to 2007 FADN data (original data request) 


   >> eupanel9907	-- 1999 to 2007 FADN data (original data request.
                            "Standard Results", see RI CC 1256)


   >> FADN_2	   	-- contains additional FADN data 

 	>>> TEAGSC	-- 1999 to 2007 FADN data (2nd data request. 
			    These are specific vars found in RI CC 882)



Files = “+”, Folders = “>”, Subfolders = “>>”, Subsubfolders = “>>>”






*FADN supporting documentation in Data/data_FADNPanelAnalysis/SupportDocs.* 










