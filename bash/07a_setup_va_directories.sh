#!/bin/bash

# ==============================================================================
#
# 07a_setup_va_directories.sh
#
# - script creates and sets up directory for the velocity analysis
#
# ==============================================================================


# clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
show_config


function setup_dir () {  # 08a_setup_va_directories

	START_YEAR=$TEMPORAL_EXTENT_START_YR
	STOP_YEAR=$TEMPORAL_EXTENT_STOP_YR
	STEP=$TEMPORAL_EXTENT_INTERVAL

	EXP_DIR=$MMX_EXPERIMENT_DIRECTORY
	TS_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries
	TA_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Trends
	VA_DIR=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Velocities

	# create and populate enm velocity analysis directory
	echo ">>> creating ENM velocity analysis directory"
	[ ! -d $VA_DIR/ENM ] && mkdir $VA_DIR/ENM

return 0; }


# main -------------------------------------------------------------------------

echo " "; echo "Setting up velocity analysis directories ..."; echo " "
setup_dir
echo " "; echo "Done ..."; echo " "
exit 0


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase, NASA
# Revision Date: 2023.02.08
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