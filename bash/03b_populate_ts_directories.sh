#!/bin/bash

# ==============================================================================
#
# 03b_populate_ts_directories.sh
#
# ==============================================================================


# clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
# show_config


function setup_02 () {  # 03b_setup_ts_directories

	START_YEAR=$TEMPORAL_EXTENT_START_YR
	STOP_YEAR=$TEMPORAL_EXTENT_STOP_YR
	STEP=$TEMPORAL_EXTENT_INTERVAL

	EXP_DIR=$MMX_EXPERIMENT_DIRECTORY
	TS_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries
	TA_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Trends
	VA_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Velocities

	# populate the time series subdirectories
	[ ! -d $TS_DIR ] && mkdir $TS_DIR

	YEAR=$START_YEAR
	while [ $YEAR -le $STOP_YEAR ]
		do

			echo " "; echo ">>> working on $EXPERIMENT_NAME/$RUN_NAME $YEAR"
			[ ! -d $TS_DIR/$YEAR ] && mkdir $TS_DIR/$YEAR

			echo ">>> creating empty model directory"
			[ ! -d $TS_DIR/$YEAR/model ] && mkdir $TS_DIR/$YEAR/model

			echo ">>> creating empty model_set directory"
			[ ! -d $TS_DIR/$YEAR/model_set ] && mkdir $TS_DIR/$YEAR/model_set
			
			echo ">>> creating and populating occurrence_file directory"
			# create the of directory, then either (1) physically populate w/ of-files (default) or (2) symlink to local of-files ...
			[ ! -d $TS_DIR/$YEAR/occurrence_file ] && mkdir $TS_DIR/$YEAR/occurrence_file
			[ ! -f $TS_DIR/$YEAR/occurrence_file/OF-$YEAR.csv ] && cp -r $OF_SRC_DIRECTORY/OF-$YEAR.csv $TS_DIR/$YEAR/occurrence_file/OF-$YEAR.csv
			# ln -s $OF_SRC_DIRECTORY/OF-$YEAR.csv $TS_DIR/$YEAR/occurrence_file/OF-$YEAR.csv

			echo ">>> creating empty selection_set directory"
			[ ! -d $TS_DIR/$YEAR/selection_set ] && mkdir $TS_DIR/$YEAR/selection_set
			
			echo ">>> creating and populating working_set directory"
			# create the ws directory, then either (1) physically populate w/ ws files or (2) symlink to local ws files (default) ...
			# [ ! -d $TS_DIR/$YEAR/working_set ] && cp -r $WS_SRC_DIRECTORY/$YEAR $TS_DIR/$YEAR/working_set
			[ ! -d $TS_DIR/$YEAR/working_set ] && ln -s $WS_SRC_DIRECTORY/$YEAR $TS_DIR/$YEAR/working_set
			
			YEAR=$(( $YEAR + $STEP))

		done
		
return 0; }


# main -------------------------------------------------------------------------

echo " "; echo "Setting up time series directories..."; echo " "
setup_02
echo " "; echo "Done ..."; echo " "
exit 0


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# Date: 2023.02.08
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