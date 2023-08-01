#!/bin/bash

# ==============================================================================
#
# mmx_launcher0.sh
# - starts the MMX selection process by launchiing an ensemble run
#
# ==============================================================================


clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
# show_config


# initializations --------------------------------------------------------------


MMX_DIR=$MTK_MMX_DIRECTORY
MMX_OF_DIR=$MTK_MMX_DIRECTORY/occurrence_file
MMX_WS_DIR=$MTK_MMX_DIRECTORY/working_set
MMX_SS_DIR=$MTK_MMX_DIRECTORY/selection_set



# functions --------------------------------------------------------------------


function run_ensemble () {
    echo ">>> MMX ensemble run starting"
    ENSEMBLE_START_TIME=`date +%s`
	
	# # to launch across multiple multi-core nodes (eg ADAPT/EXPLORE clusters)
	#     CORE_COUNTER=1
	#     while [ $CORE_COUNTER -le $CORE_COUNT ]
	#     do
	#         # run on nodes ilab102 - ilab111 ...
	#         NODE_NAME=ilab$(expr 101 + $CORE_COUNTER)
	#         echo ">>> mmx_launcher.sh - node" $NODE_NAME
	#         pdsh -w $NODE_NAME $MMX_WORKING_DIRECTORY/_system/mmx_ensemble.py $SAMPLE_SIZE $NODE_COUNT $CORE_COUNT $MMX_WORKING_DIRECTORY $WORKING_SET_DIRECTORY $OCCURRENCE_FILE_DIRECTORY &
	#         ((CORE_COUNTER++))
	#     done
	
	# to launch across multiple cores on a single node (eg MacBook Pro ...)
	$MTK_MMX_DIRECTORY/_system/mmx_ensemble.py $VARIABLE_SAMPLE_SIZE $NODE_COUNT $CORE_COUNT $MMX_DIR $MMX_WS_DIR $MMX_OF_DIR

    # echo ">>> ensemble run in progress ..."
    wait

    ENSEMBLE_STOP_TIME=`date +%s`
return 0; }


function report_ensemble_runtime () {
	TOTAL_ENSEMBLE_RUNTIME=$((ENSEMBLE_STOP_TIME-ENSEMBLE_START_TIME))
    echo "TOTAL_ENSEMBLE_RUNTIME"
    echo "scale=2; $TOTAL_ENSEMBLE_RUNTIME / 60" | bc | awk '{ printf("%.2f",$1) '}
    echo " minutes "
return 0; }


function select_top_ten () {
    $MTK_MMX_DIRECTORY/_system/mmx_select1.py $MMX_DIR $MMX_WS_DIR $MMX_SS_DIR
return 0; }


function report_total_runtime () {
	TOTAL_RUNTIME=$((STOP_TIME-START_TIME))
    echo "TOTAL_RUNTIME"
    echo "scale=2; $TOTAL_RUNTIME / 60" | bc | awk '{ printf("%.2f",$1) '}
    echo " minutes "
return 0; }


# MAIN -------------------------------------------------------------------------

START_TIME=`date +%s`
echo " "; echo ">>> starting mmx_launcher.sh ..."; echo " "

run_ensemble
select_top_ten

STOP_TIME=`date +%s`
echo " "
report_ensemble_runtime
report_total_runtime
echo " "; echo ">>> mmx_launcher.sh done"; echo " "

exit 0


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# Date: 2023.02.24
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

