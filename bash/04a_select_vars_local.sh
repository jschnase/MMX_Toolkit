#!/bin/bash

# ==============================================================================
#
# 04a_select_vars_local.sh
# - starts the MMX selection process by launchiing an ensemble run
#   (script will process all intervals in the time series, or a single interval
#    as indicated by a single positional parameter)
#
# ==============================================================================


# clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
# show_config

# functions --------------------------------------------------------------------

function link_directories () {
# sym link experiment's time series interval directories to mmx system

	echo ">>> linking for year $1"
	
	# occurrence_file directory
	if [ -L $MTK_MMX_DIRECTORY/occurrence_file ]
		then
			echo ">>> removing "$MTK_MMX_DIRECTORY/occurrence_file
			rm $MTK_MMX_DIRECTORY/occurrence_file
		fi
	echo ">>> sym linking "$MTK_MMX_DIRECTORY/occurrence_file
	ln -s $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/occurrence_file  $MTK_MMX_DIRECTORY/occurrence_file
	
	
	# selection_set directory
	if [ -L $MTK_MMX_DIRECTORY/selection_set ]
		then
			echo ">>> removing "$MTK_MMX_DIRECTORY/selection_set
			rm $MTK_MMX_DIRECTORY/selection_set
		fi
	echo ">>> sym linking "$MTK_MMX_DIRECTORY/selection_set
	ln -s $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/selection_set  $MTK_MMX_DIRECTORY/selection_set
	
	
	# working_set directory
	if [ -L $MTK_MMX_DIRECTORY/working_set ]
		then
			echo ">>> removing "$MTK_MMX_DIRECTORY/working_set
			rm $MTK_MMX_DIRECTORY/working_set
		fi
	echo ">>> sym linking "$MTK_MMX_DIRECTORY/working_set
	ln -s $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries/$YEAR/working_set  $MTK_MMX_DIRECTORY/working_set
	
	
return 0; }


# MAIN -------------------------------------------------------------------------

echo " "; echo "Starting 04a_selector.sh ..."; echo " "

# clear out temp directories, just in case ...
$MTK_MMX_DIRECTORY/_system/clear_all

# launch the mmx_launcher.sh
if [ $# -eq 0 ]
	then
		YEAR=$TEMPORAL_EXTENT_START_YR
		while [ $YEAR -le $TEMPORAL_EXTENT_STOP_YR ]
			do
				echo ">>> launching for several years - $YEAR"
				link_directories $YEAR
				$MTK_MMX_DIRECTORY/_system/mmx_launcher.sh
				YEAR=$(( $YEAR + $TEMPORAL_EXTENT_INTERVAL))
			done
	else
		YEAR=$1
		echo ">>> launching for a single year - $YEAR"
		link_directories $YEAR
		$MTK_MMX_DIRECTORY/_system/mmx_launcher.sh
	fi

# clear out temp directories
$MTK_MMX_DIRECTORY/_system/clear_all

echo " "; echo "Done ..."; echo " "

exit 0


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# 2023.02.25
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

