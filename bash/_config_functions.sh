# ==============================================================================
#
# _config_functions.sh
#
# ==============================================================================


function read_config () {
	
	while IFS= read -r line
		do
			ATTRIBUTE=${line%=*}
			VALUE=${line#*=}
			case $ATTRIBUTE in
				
				# experiment and run identifiers
				EXPERIMENT_NAME          ) eval EXPERIMENT_NAME=$VALUE ;;
				RUN_NAME                 ) eval RUN_NAME=$VALUE ;;
				SPECIES_NAME             ) eval SPECIES_NAME=$VALUE ;;
				GBIF_TAXON_KEY           ) eval GBIF_TAXON_KEY=$VALUE ;;
				
				# spatial extent of the study area
				SPATIAL_EXTENT_UL_LAT    ) eval SPATIAL_EXTENT_UL_LAT=$VALUE ;;
				SPATIAL_EXTENT_UL_LON    ) eval SPATIAL_EXTENT_UL_LON=$VALUE ;;
				SPATIAL_EXTENT_LR_LAT    ) eval SPATIAL_EXTENT_LR_LAT=$VALUE ;;
				SPATIAL_EXTENT_LR_LON    ) eval SPATIAL_EXTENT_LR_LON=$VALUE ;;
				
				# temporal extent of the study ;;
				TEMPORAL_EXTENT_START_YR ) eval TEMPORAL_EXTENT_START_YR=$VALUE ;;
				TEMPORAL_EXTENT_STOP_YR  ) eval TEMPORAL_EXTENT_STOP_YR=$VALUE ;;
				TEMPORAL_EXTENT_INTERVAL ) eval TEMPORAL_EXTENT_INTERVAL=$VALUE ;;
				
				# annual cycle phase of the study
				TEMPORAL_EXTENT_START_MO ) eval TEMPORAL_EXTENT_START_MO=$VALUE ;;
				TEMPORAL_EXTENT_STOP_MO  ) eval TEMPORAL_EXTENT_STOP_MO=$VALUE ;;
				ANNUAL_CYCLE_PHASE       ) eval ANNUAL_CYCLE_PHASE=$VALUE ;;
				
				# mmx selection specs
				MMX_SELECTION            ) eval MMX_SELECTION=$VALUE ;;
				VARIABLE_SAMPLE_SIZE     ) eval VARIABLE_SAMPLE_SIZE=$VALUE ;;
				
				# enmeval model tuning specs
				FULL_ENMEVAL_SCAN        ) eval FULL_ENMEVAL_SCAN=$VALUE ;;
				
				# climate match thresholds
				CLIMATE_MATCH_THRESHOLD  ) eval CLIMATE_MATCH_THRESHOLD=$VALUE ;;
				
				# data source directories
				OF_SRC_DIRECTORY         ) eval OF_SRC_DIRECTORY=$VALUE ;;
				WS_SRC_DIRECTORY         ) eval WS_SRC_DIRECTORY=$VALUE ;;
				
				# predictor base collection
				BASE_COLLECTION          ) eval BASE_COLLECTION=$VALUE ;;
				
				# system specs
				SYSTEM_NAME              ) eval SYSTEM_NAME=$VALUE ;;
				NODE_COUNT               ) eval NODE_COUNT=$VALUE ;;
				CORE_COUNT               ) eval CORE_COUNT=$VALUE ;;
				
				# mmx toolkit directory paths
				MMX_TOOLKIT_DIRECTORY    ) eval MMX_TOOLKIT_DIRECTORY=$VALUE ;;
				MMX_EXPERIMENT_DIRECTORY ) eval MMX_EXPERIMENT_DIRECTORY=$VALUE ;;
				MMX_CONFIG_FILE          ) eval MMX_CONFIG_FILE=$VALUE ;;
				MTK_MBOX_DIRECTORY       ) eval MTK_MBOX_DIRECTORY=$VALUE ;;
				MTK_BASH_DIRECTORY       ) eval MTK_BASH_DIRECTORY=$VALUE ;;
				MTK_DATA_DIRECTORY       ) eval MTK_DATA_DIRECTORY=$VALUE ;;
				MTK_MMX_DIRECTORY        ) eval MTK_MMX_DIRECTORY=$VALUE ;;
				MTK_TEMPLATES_DIRECTORY  ) eval MTK_TEMPLATES_DIRECTORY=$VALUE ;;
				MTK_R_DIRECTORY          ) eval MTK_R_DIRECTORY=$VALUE ;;
				MTK_RESOURCES_DIRECTORY  ) eval MTK_RESOURCES_DIRECTORY=$VALUE ;;
				
				# remote mmx server
				EXPLORE_MMX_TOOLKIT_DIRECTORY  ) eval EXPLORE_MMX_TOOLKIT_DIRECTORY=$VALUE ;;
				
				# shapefile / rds paths
				STATE_LINES_RDS          ) eval STATE_LINES_RDS=$VALUE ;;
				STATE_NAME               ) eval STATE_NAME=$VALUE ;;
				STATE_SHAPEFILE          ) eval STATE_SHAPEFILE=$VALUE ;;
				SPECIES_SHAPEFILE        ) eval SPECIES_SHAPEFILE=$VALUE ;;
				
			esac
	done < ~/MMX_Experiment/_mmx_config

return 0; }


function show_config () {
	
    echo " "
    echo "================================"
	echo "MMX TOOLKIT SYSTEM CONFIGURATION"
    echo "================================"
	echo " "
	
	# experiment and run identifiers
	echo "EXPERIMENT_NAME                = " $EXPERIMENT_NAME
	echo "RUN_NAME                       = " $RUN_NAME
	echo "SPECIES_NAME                   = " $SPECIES_NAME
	echo "GBIF_TAXON_KEY                 = " $GBIF_TAXON_KEY
	echo " "
	
	# spatial extent of the study area
	echo "SPATIAL_EXTENT_UL_LAT          = " $SPATIAL_EXTENT_UL_LAT
	echo "SPATIAL_EXTENT_UL_LON          = " $SPATIAL_EXTENT_UL_LON
	echo "SPATIAL_EXTENT_LR_LAT          = " $SPATIAL_EXTENT_LR_LAT
	echo "SPATIAL_EXTENT_LR_LON          = " $SPATIAL_EXTENT_LR_LON
	echo " "
	
	# temporal extent of the study
	echo "TEMPORAL_EXTENT_START_YR       = " $TEMPORAL_EXTENT_START_YR
	echo "TEMPORAL_EXTENT_STOP_YR        = " $TEMPORAL_EXTENT_STOP_YR
	echo "TEMPORAL_EXTENT_INTERVAL       = " $TEMPORAL_EXTENT_INTERVAL
	echo " "
	
	# annual cycle phase of the study
    echo "TEMPORAL_EXTENT_START_MO       = " $TEMPORAL_EXTENT_START_MO
	echo "TEMPORAL_EXTENT_STOP_MO        = " $TEMPORAL_EXTENT_STOP_MO
	echo "ANNUAL_CYCLE_PHASE             = " $ANNUAL_CYCLE_PHASE
	echo " "
	
	# mmx selection specs
	echo "MMX_SELECTION                  = " $MMX_SELECTION
	echo "VARIABLE_SAMPLE_SIZE           = " $VARIABLE_SAMPLE_SIZE
	echo " "
	
	# enmeval model tuning specs
	echo "FULL_ENMEVAL_SCAN              = " $FULL_ENMEVAL_SCAN
	echo " "
	
	# climate match thresholds
	echo "CLIMATE_MATCH_THRESHOLD        = " $CLIMATE_MATCH_THRESHOLD
	echo " "
	
	# data source directories
	echo "OF_SRC_DIRECTORY               = " $OF_SRC_DIRECTORY
	echo "WS_SRC_DIRECTORY               = " $WS_SRC_DIRECTORY
	echo " "
	
	# predictor base collection
	echo "BASE_COLLECTION                = " $BASE_COLLECTION
	echo " "
	
	# system specs
	echo "SYSTEM_NAME                    = " $SYSTEM_NAME
	echo "NODE_COUNT                     = " $NODE_COUNT
	echo "CORE_COUNT                     = " $CORE_COUNT
	echo " "
	
	# mmx toolkit directory paths
	echo "MMX_TOOLKIT_DIRECTORY          = " $MMX_TOOLKIT_DIRECTORY
	echo "MMX_EXPERIMENT_DIRECTORY       = " $MMX_EXPERIMENT_DIRECTORY
	echo "MMX_CONFIG_FILE                = " $MMX_CONFIG_FILE
	echo "MTK_MBOX_DIRECTORY             = " $MMX_MBOX_DIRECTORY
	echo "MTK_BASH_DIRECTORY             = " $MTK_BASH_DIRECTORY
	echo "MTK_DATA_DIRECTORY             = " $MTK_DATA_DIRECTORY
	echo "MTK_MMX_DIRECTORY              = " $MTK_MMX_DIRECTORY
	echo "MTK_TEMPLATES_DIRECTORY        = " $MTK_TEMPLATES_DIRECTORY
	echo "MTK_R_DIRECTORY                = " $MTK_R_DIRECTORY
	echo "MTK_RESOURCES_DIRECTORY        = " $MTK_RESOURCES_DIRECTORY
	echo " "
	
	# remote mmx server
	echo "EXPLORE_MMX_TOOLKIT_DIRECTORY  = " $EXPLORE_MMX_TOOLKIT_DIRECTORY
	echo " "
	
	# shapefile / rds paths
	echo "STATE_LINES_RDS                = " $STATE_LINES_RDS
	echo "STATE_NAME                     = " $STATE_NAME
	echo "STATE_SHAPEFILE                = " $STATE_SHAPEFILE
	echo "SPECIES_SHAPEFILE              = " $SPECIES_SHAPEFILE
	echo " "
	
    echo "================================"
    echo " "

return 0; }



# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase, NASA
# Revision Date: 2023.02.24
#
# ------------------------------------------------------------------------------
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


