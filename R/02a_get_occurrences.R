# ==============================================================================
#
# 02a_get_occurrences.R
#
# - script gathers observational data from the Global Biodiversity Information
#   Facility (GBIF) and builds a times series occurrence files
#
# - Useful refs:
#   https://cran.csiro.au/web/packages/rangeModelMetadata/vignettes/
#         rmm_workflowWithExampleRangeModel.html
#   https://ropensci.org/tutorials/rgbif_tutorial/
#   https://gbif-europe.github.io/nordic_oikos_2018_r/s3_gbif_demo/gbif_demo.html
#
# ==============================================================================


# set up the RStudio environment -----------------------------------------------

# rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
# show.config()

# install.packages("rgbif", dependencies = TRUE)
library("rgbif")


# initializations --------------------------------------------------------------

sp_key   <- GBIF_TAXON_KEY
sp_name  <- SPECIES_NAME

start_yr <- as.numeric(TEMPORAL_EXTENT_START_YR)
stop_yr  <- as.numeric(TEMPORAL_EXTENT_STOP_YR)
step     <- as.numeric(TEMPORAL_EXTENT_INTERVAL)
yr_span  <- paste0(start_yr, ",", stop_yr)

start_mo <- TEMPORAL_EXTENT_START_MO
stop_mo  <- TEMPORAL_EXTENT_STOP_MO
season   <- ANNUAL_CYCLE_PHASE
mo_span  <- paste0(start_mo, ",", stop_mo)

# the occurrence_file collection created here is stored in what will be the
# occurrence_file source directory used in downstream processing; by default,
# the directory is named for the species being processed ...
of_dir   <- OF_DST_DIRECTORY
out_dir  <- paste0(of_dir, "/", sp_key, "-", sp_name,"-", season)
if (!dir.exists(out_dir)){
    dir.create(out_dir)
}else{
    print(">>> of directory exists")
}


# main -------------------------------------------------------------------------

print(" "); print("Starting 02a_get_occurrences.R ..."); print(" ")


# building time series occurrence file intervals
for (int_year in seq(start_yr, stop_yr, step)) {

    print(paste0(">>> processing interval year: ", int_year))
    
    obs_int_file_name <- paste0(out_dir, "/", "OF-", int_year, ".csv")
    src_int_file_name <- paste0(out_dir, "/", "OF-", int_year, "-src.csv")

    int_file_stack <- list()
    src_file_stack <- list()
    
    obs_year <- int_year
    while (obs_year < (int_year + step)) {

        print(paste0(">>> getting observations for ", obs_year))
        spp <- occ_search(taxonKey = sp_key,
                          year     = obs_year,
                          month    = mo_span,
                          fields   = "all",
                          limit    = occ_count(taxonKey      = sp_key,
                                               hasCoordinate = TRUE,
                                               year          = obs_year))
        # snarf coordinates from the species record set
        occs <- dplyr::select(spp$data, decimalLongitude, decimalLatitude)
        src  <- dplyr::select(spp$data, decimalLongitude, decimalLatitude, month, year)

        # remove NAs
        occs <- occs[complete.cases(occs),]
        src  <- src [complete.cases(src),]

        # remove duplicates
        occs <- occs[!duplicated(occs),]
        src  <- src[!duplicated(src),]

        # create a data frame for the year's occurrences
        obs_file_rows <- data.frame(species=sp_name,
                                    longitude=occs$decimalLongitude,
                                    latitude=occs$decimalLatitude)
        src_file_rows <- data.frame(species=sp_name,
                                    longitude=src$decimalLongitude,
                                    latitude=src$decimalLatitude,
                                    month=src$month,
                                    year=src$year)

        # write the year's occurrence file
        obs_file_name <- paste0(out_dir, "/", "YR-", obs_year, ".csv")
        write.table(obs_file_rows, obs_file_name, col.names=TRUE, row.names=FALSE, sep=",")
        
        src_file_name <- paste0(out_dir, "/", "YR-", obs_year, "-src.csv")
        write.table(src_file_rows, src_file_name, col.names=TRUE, row.names=FALSE, sep=",")

        # stack the year's observations into the time series interval
        int_file_stack <- rbind(int_file_stack, obs_file_rows)
        src_file_stack <- rbind(src_file_stack, src_file_rows)

        obs_year  <- obs_year + 1
    }

    # write the interval's occurrence file and complete spp data set
    write.table(int_file_stack, obs_int_file_name, col.names=TRUE, row.names=FALSE, sep=",")
    write.table(src_file_stack, src_int_file_name, col.names=TRUE, row.names=FALSE, sep=",")
}


print(" "); print("Done ..."); print(" ")


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# Date: 2023.03.03
#
# -------------------------------------------------------------------------
#
# THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY WARRANTY OF ANY
# KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT
# LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM TO
# SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
# A PARTICULAR PURPOSE, OR FREEDOM FROM INFRINGEMENT, ANY WARRANTY THAT
# THE SUBJECT SOFTWARE WILL BE ERROR FREE, OR ANY WARRANTY THAT
# DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT SOFTWARE. THIS
# AGREEMENT DOES NOT, IN ANY MANNER, CONSTITUTE AN ENDORSEMENT BY
# GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT OF ANY RESULTS, RESULTING
# DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY OTHER APPLICATIONS RESULTING
# FROM USE OF THE SUBJECT SOFTWARE.  FURTHER, GOVERNMENT AGENCY DISCLAIMS
# ALL WARRANTIES AND LIABILITIES REGARDING THIRD-PARTY SOFTWARE, IF
# PRESENT IN THE ORIGINAL SOFTWARE, AND DISTRIBUTES IT "AS IS".
#
# RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS AGAINST THE UNITED STATES
# GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY PRIOR
# RECIPIENT.  IF RECIPIENT'S USE OF THE SUBJECT SOFTWARE RESULTS IN ANY
# LIABILITIES, DEMANDS, DAMAGES, EXPENSES OR LOSSES ARISING FROM SUCH USE,
# INCLUDING ANY DAMAGES FROM PRODUCTS BASED ON, OR RESULTING FROM,
# RECIPIENT'S USE OF THE SUBJECT SOFTWARE, RECIPIENT SHALL INDEMNIFY AND
# HOLD HARMLESS THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT, TO THE EXTENT PERMITTED
# BY LAW.  RECIPIENT'S SOLE REMEDY FOR ANY SUCH MATTER SHALL BE THE
# IMMEDIATE, UNILATERAL TERMINATION OF THIS AGREEMENT.
# ------------------------------------------------------------------------------

