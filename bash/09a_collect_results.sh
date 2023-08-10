#!/bin/bash

# ==============================================================================
#
# 09a_collect_results.sh 
#
# - script to collect key results into a summary directory
#
# ==============================================================================


# clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
# show_config


function collect_results () {  

	DST_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Summaries
	
	# trend results
	SRC_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Trends
	FILE1=$SRC_DIR/ENM/TheilSen/$SPECIES_NAME-ENM-TheilSen-Maps.png
	FILE2=$SRC_DIR/ENM/TheilSen/$SPECIES_NAME-ENM-TheilSen-Slope.png
	FILE3=$SRC_DIR/ENM/TheilSen/$SPECIES_NAME-ENM-TheilSen-Slope-Z-Overlay.png
	FILE4=$SRC_DIR/ENM/TheilSen/$SPECIES_NAME-ENM-TheilSen-Stats.txt
	
	cp $FILE1 $DST_DIR
	cp $FILE2 $DST_DIR
	cp $FILE3 $DST_DIR
	cp $FILE4 $DST_DIR
	
	# velocity results
	SRC_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Velocities
	FILE5=$SRC_DIR/ENM/$SPECIES_NAME-ENM-Weighted-Centroid.csv
	FILE6=$SRC_DIR/ENM/$SPECIES_NAME-ENM-Weighted-Centroid.png
	
	cp $FILE5 $DST_DIR
	cp $FILE6 $DST_DIR
	
	# -----
	
	# top variables results
	YEAR=$TEMPORAL_EXTENT_START_YR
	while [ $YEAR -le $TEMPORAL_EXTENT_STOP_YR ]
		do
			SRC=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/model/$YEAR\_model_permutation_importance.csv
			DST=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Summaries/$SPECIES_NAME-Variable-PI-Summary.csv
			cat $SRC >> $DST
			YEAR=$(( $YEAR + $TEMPORAL_EXTENT_INTERVAL))
		done
	
return 0; }


# main -------------------------------------------------------------------------

echo " "; echo "Collecting run results ..."; echo " "
collect_results
echo " "; echo "Done ..."; echo " "
exit 0


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# Date: 2023.03.12
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