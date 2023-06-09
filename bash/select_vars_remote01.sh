#!/bin/bash

# ==============================================================================
#
# select_vars_remote01.sh (run on local host)
# - starts the MMX selection process by preparing the local host's mbox
#
# ==============================================================================


# clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
show_config


function set_up_local_mbox () {
	
	# create the run's local mbox oc folder and populate with occurrence files
	if [ -d $MTK_MBOX_DIRECTORY/Exp000/Run000 ]
		then
			echo ">>> $MTK_MBOX_DIRECTORY/Exp000/Run000 directory exists"
			echo ">>> stopping ..."
			exit 1
		else
			echo ">>> creating $MTK_MBOX_DIRECTORY/Exp000/Run000 directory"
			mkdir $MTK_MBOX_DIRECTORY/Exp000
			mkdir $MTK_MBOX_DIRECTORY/Exp000/Run000
			cp $MMX_EXPERIMENT_DIRECTORY/_mmx_config $MTK_MBOX_DIRECTORY
			cp $MMX_EXPERIMENT_DIRECTORY/_mmx_config $MTK_MBOX_DIRECTORY/Exp000/Run000
			
			YEAR=$TEMPORAL_EXTENT_START_YR
			while [ $YEAR -le $TEMPORAL_EXTENT_STOP_YR ]
			do
				echo ">>> copying $YEAR occurrence file to mbox directory"
				mkdir $MTK_MBOX_DIRECTORY/Exp000/Run000/$YEAR
				mkdir $MTK_MBOX_DIRECTORY/Exp000/Run000/$YEAR/occurrence_file
				SRC=$MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/occurrence_file/OF-$YEAR.csv
				DST=$MTK_MBOX_DIRECTORY//Exp000/Run000/$YEAR/occurrence_file/OF-$YEAR.csv
				cp $SRC $DST
				
				echo ">>> creating selection_set directory"
				mkdir $MTK_MBOX_DIRECTORY/Exp000/Run000/$YEAR/selection_set
				
				YEAR=$(( $YEAR + $TEMPORAL_EXTENT_INTERVAL ))
			done
			
			echo ">>> done ..."
	fi
	
return 0; }


function send_local_mbox () {
	
	# transfer local mbox to remote machine
	echo ">>> transfering local mbox to remote mmx cluster"
	# echo ">>> enter the follow command line at the terminal prompt:"
	# echo scp -r $MTK_MBOX_DIRECTORY adaptlogin.nccs.nasa.gov:$EXPLORE_MMX_TOOLKIT_DIRECTORY
	SRC=$MTK_MBOX_DIRECTORY
	DST=adaptlogin.nccs.nasa.gov:$EXPLORE_MMX_TOOLKIT_DIRECTORY
	scp -r $SRC $DST
	echo ">>> done ..."
	
return 0; }


# main -------------------------------------------------------------------------


echo " "; echo "Starting 04a_select_vars_remote01.sh ..."; echo " "

set_up_local_mbox

send_local_mbox

echo " "; echo "Done ..."; echo " "



# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase, NASA
# Revision Date: 2023.04.02
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
