*****************************************************
*	Patrick R. Gillspie
*	Walsh Fellow
*	FADN_IGM/sub_do/dirstruct.do
*****************************************************
* 1* Declare global macros for directory paths
*****************************************************
* paneldir is the path to data_???PanelAnalysis (NFS 
* or FADN for the ???). all subsequent filepath 
* macros depend on this one, and it should be set at 
* the top of the master do-file for your project


* filepaths of subdirectories of $fadnpaneldir
local origdatadir `fadnpaneldir'/OrigData 
local fadn9907dir  `origdatadir'/eupanel9907
local fadn0407dir  `origdatadir'/eupanel0407
local fadn2dir  `origdatadir'/FADN_2/TEAGSC
local fadnoutdatadir `fadnpaneldir'/OutData/FADN_IGM

******************************************
* Original Data
******************************************
*local pov_orig_data `datadir'\Data_Pov87\OutData
local censusofagdatadir `datadir'\data_WFD\Orig_data
local filldatadir `datadir'\Data_lii\Out_Data\PanelCreate\lii
local silcdatadir `datadir'\data_AIMAP\Out_Data\EUSILCBenefits
local histdata `datadir'\Data_lii\Out_Data\SMILECreate\lii
local ttw `datadir'\data_AIMAP\Orig_Data\TTW
local exp_origdatadir `datadir'\data_AIMAP\Orig_Data\ExpAnalysis
local nfspaneldir `datadir'/data_NFSPanelAnalysis
local SMILEFarmdatadir `nfspaneldir'\OutData\SpatialMatch
local nfsdatadir `nfspaneldir'\OutData
global nfsdatadir1 = "`nfsdatadir'"

local silc_orig_data `datadir'\data_AIMAP\Out_Data\EUSILCBenefits
local hbsnfsdatadir `datadir'\data_NFSPanelAnalysis\OutData\HBSNFSMatch

local orig_ibsas_nfs = "`nfspaneldir'\OutData\ConvertIBSAS"
global orig_ibsas_nfs1 = "`orig_ibsas_nfs'"


******************************************
* Do-file directories
******************************************
local dodir `fadnpaneldir'\Do_Files\FADN_IGM
global dodir1 = "`dodir'"

local exp_dodir `datadir'\data_AIMAP\Do_Files\ExpAnalysis
local smiledodir `datadir'\Data_SmileCreate\Do_files\DoSmileCreate


******************************************
* Output Data
******************************************
local outdatadir `nfspaneldir'\OutData\IGM
global outdatadir1 = "`outdatadir'"

local Regional_outdatadir \Data\data_NFSPanelAnalysis\OutData\RegionalAnalysis
global Regional_outdatadir1 = "`Regional_outdatadir'"

cd `dodir'\
