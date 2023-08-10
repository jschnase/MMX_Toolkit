# ==============================================================================
#
# _config_functions.R
#
# - utility R functions to read / show _mmx_config file
#
# ==============================================================================


read.config <- function() {

    a <- readLines ("~/MMX_Experiment/_mmx_config")

    for (i in 1:length(a)) {

        b         <- strsplit(a[i], split = "=")
        attribute <- unlist(b)[1]
        value     <- unlist(b)[2]

        if (nchar(a[i]) == 0) {
            next

        # experiment and run identifiers
        } else if (attribute == "EXPERIMENT_NAME") {
            EXPERIMENT_NAME <<- value
        } else if (attribute == "RUN_NAME") {
            RUN_NAME <<- value
        } else if (attribute == "SPECIES_NAME") {
            SPECIES_NAME <<- value
        } else if (attribute == "GBIF_TAXON_KEY") {
            GBIF_TAXON_KEY <<- value

        # spatial extent of the study area
        } else if (attribute == "SPATIAL_EXTENT_UL_LAT") {
            SPATIAL_EXTENT_UL_LAT <<- value
        } else if (attribute == "SPATIAL_EXTENT_UL_LON") {
            SPATIAL_EXTENT_UL_LON <<- value
        } else if (attribute == "SPATIAL_EXTENT_LR_LAT") {
            SPATIAL_EXTENT_LR_LAT <<- value
        } else if (attribute == "SPATIAL_EXTENT_LR_LON") {
            SPATIAL_EXTENT_LR_LON <<- value

        # temporal extent of the study
        } else if (attribute == "TEMPORAL_EXTENT_START_YR") {
            TEMPORAL_EXTENT_START_YR <<- value
        } else if (attribute == "TEMPORAL_EXTENT_STOP_YR") {
            TEMPORAL_EXTENT_STOP_YR <<- value
        } else if (attribute == "TEMPORAL_EXTENT_INTERVAL") {
            TEMPORAL_EXTENT_INTERVAL <<- value

        # annual cycle phase of the study
        } else if (attribute == "TEMPORAL_EXTENT_START_MO") {
            TEMPORAL_EXTENT_START_MO <<- value
        } else if (attribute == "TEMPORAL_EXTENT_STOP_MO") {
            TEMPORAL_EXTENT_STOP_MO <<- value
        } else if (attribute == "ANNUAL_CYCLE_PHASE") {
            ANNUAL_CYCLE_PHASE <<- value

        # mmx selection specs
        } else if (attribute == "MMX_SELECTION") {
            MMX_SELECTION <<- value
        } else if (attribute == "VARIABLE_SAMPLE_SIZE") {
            VARIABLE_SAMPLE_SIZE <<- value

        # enmeval model tuning specs
        } else if (attribute == "FULL_ENMEVAL_SCAN") {
            FULL_ENMEVAL_SCAN <<- value

        # climate match thresholds
        } else if (attribute == "CLIMATE_MATCH_THRESHOLD") {
            CLIMATE_MATCH_THRESHOLD <<- value

        # data destination directories
        } else if (attribute == "OF_DST_DIRECTORY") {
            OF_DST_DIRECTORY <<- value
        } else if (attribute == "WS_DST_DIRECTORY") {
            WS_DST_DIRECTORY <<- value

        # data source directories
        } else if (attribute == "OF_SRC_DIRECTORY") {
            OF_SRC_DIRECTORY <<- value
        } else if (attribute == "WS_SRC_DIRECTORY") {
            WS_SRC_DIRECTORY <<- value

        # predictor base collection
        } else if (attribute == "BASE_COLLECTION") {
            BASE_COLLECTION <<- value

        # system specs
        } else if (attribute == "SYSTEM_NAME") {
        SYSTEM_NAME <<- value
        } else if (attribute == "NODE_COUNT") {
        NODE_COUNT <<- value
        } else if (attribute == "CORE_COUNT") {
        CORE_COUNT <<- value

        # mmx toolkit directory paths
        } else if (attribute == "MMX_TOOLKIT_DIRECTORY") {
            MMX_TOOLKIT_DIRECTORY <<- value
        } else if (attribute == "MMX_EXPERIMENT_DIRECTORY") {
            MMX_EXPERIMENT_DIRECTORY <<- value
        } else if (attribute == "MMX_CONFIG_FILE") {
            MMX_CONFIG_FILE <<- value
        } else if (attribute == "MTK_MBOX_DIRECTORY") {
            MTK_MBOX_DIRECTORY <<- value
        } else if (attribute == "MTK_BASH_DIRECTORY") {
            MTK_BASH_DIRECTORY <<- value
        } else if (attribute == "MTK_DATA_DIRECTORY") {
            MTK_DATA_DIRECTORY <<- value
        } else if (attribute == "MTK_MMX_DIRECTORY") {
            MTK_MMX_DIRECTORY <<- value
        } else if (attribute == "MTK_TEMPLATES_DIRECTORY") {
            MTK_TEMPLATES_DIRECTORY <<- value
        } else if (attribute == "MTK_R_DIRECTORY") {
            MTK_R_DIRECTORY <<- value
        } else if (attribute == "MTK_RESOURCES_DIRECTORY") {
            MTK_RESOURCES_DIRECTORY <<- value

	    # remote mmx server
	    } else if (attribute == "EXPLORE_MMX_TOOLKIT_DIRECTORY") {
	        EXPLORE_MMX_TOOLKIT_DIRECTORY <<- value

	    # mmx toolkit shapefiles / rds
	    } else if (attribute == "STATE_LINES_RDS") {
	        STATE_LINES_RDS <<- value
	    } else if (attribute == "STATE_NAME") {
	        STATE_NAME <<- value
	    } else if (attribute == "STATE_SHAPEFILE") {
	        STATE_SHAPEFILE <<- value
	    } else if (attribute == "SPECIES_SHAPEFILE") {
	        SPECIES_SHAPEFILE <<- value

        # remaining options ...
        } else if (attribute == "EOF") {
            EOF <<- value
            break
        } else if (attribute == "#") {
            next
        }

    }

    return()

}


show.config <- function() {

    print(paste0(" "))
    print(paste0("================================"))
    print(paste0("SYSTEM CONFIGURATION"))
    print(paste0("================================"))
    print(paste0(" "))

    # experiment and run identifiers
    print(paste0("EXPERIMENT_NAME                = ", EXPERIMENT_NAME))
    print(paste0("RUN_NAME                       = ", RUN_NAME))
    print(paste0("SPECIES_NAME                   = ", SPECIES_NAME))
    print(paste0("GBIF_TAXON_KEY                 = ", GBIF_TAXON_KEY))
    print(paste0(" "))

    # spatial extent of the study area
    print(paste0("SPATIAL_EXTENT_UL_LAT          = ", SPATIAL_EXTENT_UL_LAT))
    print(paste0("SPATIAL_EXTENT_UL_LON          = ", SPATIAL_EXTENT_UL_LON))
    print(paste0("SPATIAL_EXTENT_LR_LAT          = ", SPATIAL_EXTENT_LR_LAT))
    print(paste0("SPATIAL_EXTENT_LR_LON          = ", SPATIAL_EXTENT_LR_LON))
    print(paste0(" "))

    # temporal extent of the study
    print(paste0("TEMPORAL_EXTENT_START_YR       = ", TEMPORAL_EXTENT_START_YR))
    print(paste0("TEMPORAL_EXTENT_STOP_YR        = ", TEMPORAL_EXTENT_STOP_YR))
    print(paste0("TEMPORAL_EXTENT_INTERVAL       = ", TEMPORAL_EXTENT_INTERVAL))
    print(paste0(" "))

    # annual cycle phase of the study
    print(paste0("TEMPORAL_EXTENT_START_MO       = ", TEMPORAL_EXTENT_START_MO))
    print(paste0("TEMPORAL_EXTENT_STOP_MO        = ", TEMPORAL_EXTENT_STOP_MO))
    print(paste0("ANNUAL_CYCLE_PHASE             = ", ANNUAL_CYCLE_PHASE))
    print(paste0(" "))

    # mmx selection specs
    print(paste0("MMX_SELECTION                  = ", MMX_SELECTION))
    print(paste0("VARIABLE_SAMPLE_SIZE           = ", VARIABLE_SAMPLE_SIZE))
    print(paste0(" "))

    # enmeval model tuning specs
    print(paste0("FULL_ENMEVAL_SCAN              = ", FULL_ENMEVAL_SCAN))
    print(paste0(" "))

    # climate match thresholds
    print(paste0("CLIMATE_MATCH_THRESHOLD        = ", CLIMATE_MATCH_THRESHOLD))
    print(paste0(" "))

    # data destination directories
    print(paste0("OF_DST_DIRECTORY               = ", OF_DST_DIRECTORY))
    print(paste0("WS_DST_DIRECTORY               = ", WS_DST_DIRECTORY))
    print(paste0(" "))

    # data source directories
    print(paste0("OF_SRC_DIRECTORY               = ", OF_SRC_DIRECTORY))
    print(paste0("WS_SRC_DIRECTORY               = ", WS_SRC_DIRECTORY))
    print(paste0(" "))

    # predictor base collection
    print(paste0("BASE COLLECTION                = ", BASE_COLLECTION))
    print(paste0(" "))

    # system specs
    print(paste0("SYSTEM_NAME                    = ", SYSTEM_NAME))
    print(paste0("NODE_COUNT                     = ", NODE_COUNT))
    print(paste0("CORE_COUNT                     = ", CORE_COUNT))
    print(paste0(" "))

    # mmx toolkit directory paths
    print(paste0("MMX_TOOLKIT_DIRECTORY          = ", MMX_TOOLKIT_DIRECTORY))
    print(paste0("MMX_EXPERIMENT_DIRECTORY       = ", MMX_EXPERIMENT_DIRECTORY))
    print(paste0("MMX_CONFIG_FILE                = ", MMX_CONFIG_FILE))
    print(paste0("MTK_MBOX_DIRECTORY             = ", MTK_MBOX_DIRECTORY))
    print(paste0("MTK_BASH_DIRECTORY             = ", MTK_BASH_DIRECTORY))
    print(paste0("MTK_DATA_DIRECTORY             = ", MTK_DATA_DIRECTORY))
    print(paste0("MTK_MMX_DIRECTORY              = ", MTK_MMX_DIRECTORY))
    print(paste0("MTK_TEMPLATES_DIRECTORY        = ", MTK_TEMPLATES_DIRECTORY))
    print(paste0("MTK_R_DIRECTORY                = ", MTK_R_DIRECTORY))
    print(paste0("MTK_RESOURCES_DIRECTORY        = ", MTK_RESOURCES_DIRECTORY))
    print(paste0(" "))

    # remote mmx server
	print(paste0("EXPLORE_MMX_TOOLKIT_DIRECTORY  = ", EXPLORE_MMX_TOOLKIT_DIRECTORY))
    print(paste0(" "))

    # mmx toolkit shapefiles / rds
    print(paste0("STATE_LINES_RDS                = ", STATE_LINES_RDS))
    print(paste0("STATE_NAME                     = ", STATE_NAME))
    print(paste0("STATE_SHAPEFILE                = ", STATE_SHAPEFILE))
    print(paste0("SPECIES_SHAPEFILE              = ", SPECIES_SHAPEFILE))
    print(paste0(" "))

    print(paste0("================================"))
    print(paste0(" "))

    return()

}


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# Date: 2023.02.24
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
