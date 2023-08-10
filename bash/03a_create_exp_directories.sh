#!/bin/bash

# ==============================================================================
#
# 03a_create_exp_directories.sh  
#
# - script creates top-level experiment directories for trend analysis
#
# ==============================================================================


# clear
source ~/MMX_Toolkit/bash/_config_functions.sh 
read_config
# show_config


function setup_01 () {  # 03a_setup_exp_directories.sh

if [ -d $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME ]
	then
		echo ">>> $EXPERIMENT_NAME/$RUN_NAME directory exists"
		echo " "
		exit 1
	else
		mkdir $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME
		echo ">>> $EXPERIMENT_NAME/$RUN_NAME directory created"
fi

	if [ -d $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries ]
		then
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/TimeSeries directory exists"
			echo " "
			exit 1
		else
			mkdir $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/TimeSeries
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/TimeSeries directory created"
	fi

	if [ -d $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Trends ]
		then
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/Trends directory exists"
			echo " "
			exit 1
		else
			mkdir $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Trends
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/Trends directory created"
	fi

	if [ -d $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Velocities ]
		then
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/Velocities directory exists"
			echo " "
			exit 1
		else
			mkdir $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Velocities
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/Velocities directory created"
	fi
	
	if [ -d $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Summaries ]
		then
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/Summaries directory exists"
			echo " "
			exit 1
		else
			mkdir $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/Summaries
			echo ">>> $EXPERIMENT_NAME/$RUN_NAME/Summaries directory created"
	fi

return 0; }


# main -------------------------------------------------------------------------

echo " "; echo "Setting up experiment directories ..."; echo " "
setup_01
touch $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/__$SPECIES_NAME
date > $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/__$SPECIES_NAME
cp $MMX_EXPERIMENT_DIRECTORY/_mmx_config $MMX_EXPERIMENT_DIRECTORY/$RUN_NAME/_mmx_config

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