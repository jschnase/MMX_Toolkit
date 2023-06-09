#!/bin/bash

# ==============================================================================
#
# select_vars_remote02.sh (run on local host)
# - completes the MMX selection process by transfering selected variables from
#   the remote server to the local host and setting up continued processing
#
# ==============================================================================


# clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
show_config


function get_remote_mbox () {
	
	# transfer remote mbox to local machine
	echo ">>> transfering remote mbox to local host"
	# echo ">>> enter the follow command line at the terminal prompt:
	# echo scp -r adaptlogin.nccs.nasa.gov:$EXPLORE_MMX_TOOLKIT_DIRECTORY/_mbox $MMX_TOOLKIT_DIRECTORY
	SRC=adaptlogin.nccs.nasa.gov:$EXPLORE_MMX_TOOLKIT_DIRECTORY/_mbox
	DST=$MMX_TOOLKIT_DIRECTORY
	scp -r $SRC $DST
	echo ">>> done ..."
	
return 0; }


function populate_local_ss_directory () {
    # symlinks variables from local collection

	YEAR=$TEMPORAL_EXTENT_START_YR
	while [ $YEAR -le $TEMPORAL_EXTENT_STOP_YR ]
	do
		echo ">>> symlinking $YEAR selection_set variables"
		# SRC=/Users/jschnase/Dropbox/MMX-Project/MMX-Experiments/$EXPERIMENT_NAME/Cassins_Sparrow-Annual-V1/TimeSeries/$YEAR/selection_set/_SS-$YEAR.csv
		SRC=$MTK_MBOX_DIRECTORY/Exp000/Run000/$YEAR/selection_set/ss_top_ten.csv
		DST=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/selection_set/_SS-$YEAR.csv
		cp $SRC $DST

		while IFS=, read -r VAR CNT SUM AVG
		do
		    # If var matches header line value, continue
		     if [[ $VAR == "var" ]]; then
		        continue
		     fi
		# cp -r $WS_SRC_DIRECTORY/$YEAR/$VAR.asc $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/selection_set
		ln -s $WS_SRC_DIRECTORY/$YEAR/$VAR.asc $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/selection_set
		done < $DST

		YEAR=$(( $YEAR + $TEMPORAL_EXTENT_INTERVAL ))
	done

return 0; }


function back_up_mbox () {
	
    TIME_STAMP0=`date +%s`
	TIME_STAMP1=`date +%m.%d.%Y-%H.%M`

	# create backup mbox
	echo ">>> creating backup mbox"
	MBOX_BAK=$MMX_TOOLKIT_DIRECTORY/_mbox_archive/_mbox-$EXPERIMENT_NAME-$RUN_NAME-$TIME_STAMP0
	mv $MTK_MBOX_DIRECTORY $MBOX_BAK
	touch $MBOX_BAK/_$TIME_STAMP1
	echo ">>> $MTK_MBOX_DIRECTORY/$EXPERIMENT_NAME/$RUN_NAME backup mbox created"
	
	# creating a new empty mbox
	echo ">>> creating new empty mbox"
	mkdir $MMX_TOOLKIT_DIRECTORY/_mbox

	echo ">>> done ..."

return 0; }


# main -------------------------------------------------------------------------


echo " "; echo "Starting 04a_select_vars_remote03.sh ..."; echo " "

get_remote_mbox

populate_local_ss_directory

back_up_mbox

echo " "; echo "Done ..."; echo " "



# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase, NASA
# Revision Date: 2023.03.27
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
