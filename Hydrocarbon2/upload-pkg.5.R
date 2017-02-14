install_github("ropensci/datapack")

# This script creates a DataPackage from the HydroCarbon dataset and uploads it to the
# specified member node. The `datapack::addRunProv` function is used to add the provenance relationships
#
# The resolveURI is used to construct the DataONE object URIs. The default is to use the 
# DataONE 'resolve' service URL, but the URL for a test environment can be used instead, for example,.
# "https://cn-dev-2.test.dataone.org/cn/v2/resolve".
# This script version uses the newest R datapack package as of 2017 01 20
library(dataone)
library(datapack)
library(EML)

uploadPkg <- function() {
    resolveURI <- "https://cn-dev-2.test.dataone.org/cn/v2/resolve"
    #resolveURI <- "https://cn.dataone.org/cn/v2/resolve"
    
    dp <- new("DataPackage")
    dataDir <- "/home/goldstein/Hydrocarbon"
      # "/Users/slaughter/Projects/DataONE/Provenance/GOA-HydroCarbonDB/newdatapack"
    emlFile <- sprintf("%s/metadata1.xml", dataDir)
    EMLdoc <- read_eml(emlFile)
    
    cn <- CNode("DEV2")
    mn <- getMNode(cn, "urn:node:mnDevUCSB1")
    d1c <- new("D1Client", cn=cn, mn=mn)
    
    #
    #----- Execution #0
    #
    message("Adding package objects for execution #0...")
    inputs <- list()
    outputs <- list()
    # Create a DataObject to hold the script file
    progObj <- new("DataObject", format="application/R", filename=sprintf("%s/%s", dataDir, "DataDownload.R"), 
                   mediaType="text/x-rsrc", 
                   suggestedFilename="DataDownload.R")
    # Add the script DataObject to the DataPackage
    dp <- addData(dp, progObj)
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="DataDownload.R", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(progObj)))
    
    do <- new("DataObject", format="application/octet-stream", filename=sprintf("%s/%s", dataDir, "EVTHD Feb 2016.accdb"), suggestedFilename="EVTHD Feb 2016.accdb")
    dp <- addData(dp, do)
    inputs[[length(inputs)+1]] <- do
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="EVTHD Feb 2016.accdb", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    doOut <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "Alkane.csv"), suggestedFilename="Alkane.csv")
    dp <- addData(dp, doOut)
    outputs[[length(outputs)+1]] <- doOut
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Alkane data input file", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(doOut)))
    
    doOut <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "PAH.csv"), suggestedFilename="PAH.csv")
    dp <- addData(dp, doOut)
    outputs[[length(outputs)+1]] <- doOut
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="PAH data input file", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(doOut)))
    
    doOut <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "Sample.csv"), suggestedFilename="Sample.csv")
    dp <- addData(dp, doOut)
    outputs[[length(outputs)+1]] <- doOut
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Samples input file", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(doOut)))
    
    doOut <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "CollectionMethods.csv"), suggestedFilename="CollectionMethods.csv")
    dp <- addData(dp, doOut)
    outputs[[length(outputs)+1]] <- doOut
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="CollectionMethods.csv", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(doOut)))

# Now add the provenance relationships for this script, and it's inputs and outputs
dp <- insertDerivation(dp, sources=inputs, program=progObj, derivations=outputs) 
    
    #
    #----- Execution #1
    #
    message("Adding package objects for execution #1...")
    inputs <- list()
    outputs <- list()
    # Create a DataObject to hold the script file
    progObj <- new("DataObject", format="application/R", filename=sprintf("%s/%s", dataDir, "df35b.268.1.R"), 
                   mediaType="text/x-rsrc", 
                   suggestedFilename="Total_PAH_and_Alkanes_GoA_Hydrocarbons_Clean.R")
    # Add the script DataObject to the DataPackage
    dp <- addData(dp, progObj)
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Data merging R script", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(progObj)))
    
    do <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "df35b.256.1.csv"), suggestedFilename="Non-EVOS SINs.csv")
    dp <- addData(dp, do)
    inputs[[length(inputs)+1]] <- do
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Non-EVOS SINs.csv", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    do <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "Sample.csv"), suggestedFilename="Sample.csv")
    dp <- addData(dp, do)
    inputs[[length(inputs)+1]] <- do
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Samples input file", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    do <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "PAH.csv"), suggestedFilename="PAH.csv")
    dp <- addData(dp, do)
    inputs[[length(inputs)+1]] <- do
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="PAH data input file", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    do <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "Alkane.csv"), suggestedFilename="Alkane.csv")
    dp <- addData(dp, do)
    inputs[[length(inputs)+1]] <- do
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Alkane data input file", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    doOut <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "df35b.254.3.csv"), suggestedFilename="Total_Aromatic_Alkanes_PWS.csv")
    dp <- addData(dp, doOut)
    outputs[[length(outputs)+1]] <- doOut
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Total_Aromatic_Alkanes_PWS.csv", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(doOut)))
    
    # Now add the provenance relationships for this script, and it's inputs and outputs
    dp <- insertDerivation(dp, sources=inputs, program=progObj, derivations=outputs) 
    
    # Add the auxillary file - this file does not have any prov relations, so don't need to add it to the inputs or outputs list
    anxillaryFile <- "CollectionMethods.csv"
    do <- new("DataObject", format="text/csv", filename=sprintf("%s/%s", dataDir, "CollectionMethods.csv"), suggestedFilename="CollectionMethods.csv")
    dp <- addData(dp, do)
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="CollectionMethods.csv", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    #
    #----- Execution #2
    #
    
    message("Adding package objects for execution #2...")
    # Reset the input, output lists
    inputs <- list()
    outputs <- list()
    # This is the step that links execution #1 and execution #2.
    # The output object from step one is input to step 2, so don't need to create another DataObject, just record
    # the new relationship for the object (as an input to execution #2).
    inputs[[length(inputs)+1]] <- doOut
    
    # Create a DataObject to hold the script file
    progObj <- new("DataObject", format="application/R", filename=sprintf("%s/%s", dataDir, "df35b.265.1.R"), 
                   mediaType="text/x-rsrc", 
                   suggestedFilename="hcdbSites.R")
    # Add the script DataObject to the DataPackage
    dp <- addData(dp, progObj)
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Locations map R script", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(progObj)))
    
    do <- new("DataObject", format="image/png", filename=sprintf("%s/%s", dataDir, "df35b.266.1.png"), suggestedFilename="hcdbSampleLocs.png")
    dp <- addData(dp, do)
    outputs[[length(outputs)+1]] <- do
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Map of sampling locations in the Northern Gulf of Alaska", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    do <- new("DataObject", format="image/png", filename=sprintf("%s/%s", dataDir, "df35b.267.1.png"), suggestedFilename="hcdbSamplesGOA.png")
    dp <- addData(dp, do)
    outputs[[length(outputs)+1]] <- do
    EMLdoc <- updateEMLdistURL(EMLdoc, entityName="Map of sampling locations in the Gulf of Alaska", resolveUrl=sprintf("%s/%s", resolveURI, getIdentifier(do)))
    
    # Now add the provenance relationships for this script, and it's inputs and outputs
    dp <- insertDerivation(dp, sources=inputs, program=progObj, derivations=outputs) 
    
    message("Writing EML document...")
    write_eml(EMLdoc, emlFile)
    message("Done writing EML document.")
    # Read in the metadata file
    emlFile <- sprintf("%s/metadata1.xml", dataDir)
    metadataObj <- new("DataObject", format="eml://ecoinformatics.org/eml-2.1.1", filename=emlFile)
    dp <- addData(dp, metadataObj)
    
    # Associate the metadata object with all objects in the package
    pids <- getIdentifiers(dp)
    for(iPid in 1:length(pids)) {
        thisPid <- pids[[iPid]]
        dp <- insertRelationship(dp, subjectID=getIdentifier(metadataObj), objectIDs=thisPid)
    }
    
    # Upload to DataONE member node
    resourceMapId <- uploadDataPackage(d1c, dp, replicate=TRUE, public=TRUE, quiet=F, resolveURI=resolveURI)
}

# Update the distribution url in the EML object with the DataONE 
updateEMLdistURL <- function(EMLdoc, entityName, resolveUrl) {
    # Search for the entity among the 'otherEntity' elements
    found <- FALSE
    for (iEntity in 1:length(EMLdoc@dataset@otherEntity@.Data)) {
        thisEntityName <- EMLdoc@dataset@otherEntity@.Data[[iEntity]]@entityName
        if(thisEntityName == entityName) {
            message(sprintf("Updating otherEntity %s in EML\n", thisEntityName))
            EMLdoc@dataset@otherEntity@.Data[[iEntity]]@physical[[1]]@distribution[[1]]@online@url@.Data <- resolveUrl
            found <- TRUE
        }
    }
    if(found) return(EMLdoc)
    # If not already found, search for the entity among the 'dataTable' elements
    for (iEntity in 1:length(EMLdoc@dataset@dataTable@.Data)) {
        thisEntityName <- EMLdoc@dataset@dataTable@.Data[[iEntity]]@entityName
        if(thisEntityName == entityName) {
            message(sprintf("Update dataTable %s in EML\n", thisEntityName))
            EMLdoc@dataset@dataTable@.Data[[iEntity]]@physical[[1]]@distribution[[1]]@online@url@.Data <- resolveUrl
        }
    }
    return(EMLdoc)
} 

uploadPkg()
