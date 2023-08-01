#!/Applications/miniconda3/bin/python3
# #!/usrbin/python3

# ==============================================================================
#
# rbvmax.py
# - performs a random bivariate maxent (rbvmax) selection run
#   (requires positional arguments, see below ...)
#
# ==============================================================================


# import libraries
import os, sys, subprocess, time, shutil, random, csv, datetime, numpy as np


# positional arguments
mmx_home                  = sys.argv[1]   # <== mmx system working directory
working_set_directory     = sys.argv[2]   # <== mmx working set directory
occurrence_file_directory = sys.argv[3]   # <== mmx occurrence file directory


# create unique datetime-pid identifier for mmx objects
pid                       = os.getpid()
current_time              = datetime.datetime.now()
time_stamp                = current_time.strftime('%Y.%m.%d-%H.%M.%S')
mmx_uid                   = str(time_stamp) + '-' + str(pid)


# set remaining directory paths and file names
occurrence_file_name      = os.listdir(occurrence_file_directory)
occurrence_file           = os.path.join(occurrence_file_directory, occurrence_file_name[0])

working_set_list          = os.listdir(working_set_directory)
working_set_count         = len(working_set_list)

mmx_tmp                   = os.path.join(mmx_home, '_system/_tmp')
mmx_maxent_results        = os.path.join(mmx_tmp, mmx_uid + '-' + 'maxentResults.csv')

rbv_home                  = os.path.join(mmx_home, '_system/_RBVMax')
rbv_input_directory       = os.path.join(rbv_home, 'input')
rbv_output_directory      = os.path.join(rbv_home, 'output')
rbv_occurrence_file       = os.path.join(rbv_input_directory, mmx_uid + '-' + occurrence_file_name[0])
rbv_predictors            = os.path.join(rbv_input_directory, mmx_uid + '-predictors')
rbv_maxent_output         = os.path.join(rbv_output_directory, mmx_uid + '-output')
rbv_maxent_results        = os.path.join(rbv_maxent_output, 'maxentResults.csv')
rbv_maxent_jarfile        = os.path.join(rbv_home, '_system/maxent.jar')

# # show configuration
# print(" ")
# print("RBVMax starting ----- ")
# print("pid:                  ", pid)
# print("time_stamp:           ", time_stamp)
# print("mmx_uid:              ", mmx_uid)
# print("occurrence_file_name: ", occurrence_file_name)
# print("occurrence_file:      ", occurrence_file)
# print("working_set_list:     ", working_set_list)
# print("working_set_count:    ", working_set_count)
# print("mmx_tmp:              ", mmx_tmp)
# print("mmx_maxent_results:   ", mmx_maxent_results)
# print("rbv_home:             ", rbv_home)
# print("rbv_input_directory:  ", rbv_input_directory)
# print("rbv_output_directory: ", rbv_output_directory)
# print("rbv_occurrence_file:  ", rbv_occurrence_file)
# print("rbv_predictors:       ", rbv_predictors)
# print("rbv_maxent_output:    ", rbv_maxent_output)
# print("rbv_maxent_results:   ", rbv_maxent_results)
# print("rbv_maxent_jarfile:   ", rbv_maxent_jarfile)

# sys.exit(0)  # devtest stop


# create unique input/output files/directories for this MaxEnt run
if os.path.exists(rbv_occurrence_file) :
    sys.exit('MaxEnt occurrence file already exists.')
# move a copy of the mmx input occurrence file to RBVMax
shutil.copyfile(occurrence_file, rbv_occurrence_file)

if os.path.exists(rbv_predictors) :
    sys.exit('MaxEnt predictors directory already exists.')
mk_dir = 'mkdir ' + rbv_predictors
os.system(mk_dir)

if os.path.exists(rbv_maxent_output) :
    sys.exit('MaxEnt output directory already exists.')
mk_dir = 'mkdir ' + rbv_maxent_output
os.system(mk_dir)

# sys.exit(0)  # devtest stop


# move two random variables from base collection to RBVMax,
random_variables = random.sample(working_set_list, 2)
for file_name in random_variables:
    # punt if only one random variable was selected
    if len(random_variables) < 2 :
        sys.exit('Quiting - Only one variable selected.')
    # otherwise, do a run ...
    src_path = os.path.join(working_set_directory, file_name)
    dst_path = os.path.join(rbv_predictors, file_name)
    shutil.copyfile(src_path, dst_path)

# sys.exit(0)  # devtest stop


# clean up Mac's .DS_Store file if it exists
if os.path.exists(os.path.join(rbv_predictors, '.DS_Store')) :
    os.system('rm ' + rbv_predictors + '/.DS_Store')


# build arguments for MaxEnt run
maxent_args = ' visible=false'
maxent_args = maxent_args + ' environmentallayers=' + rbv_predictors
maxent_args = maxent_args + ' samplesfile='         + rbv_occurrence_file
maxent_args = maxent_args + ' outputdirectory='     + rbv_maxent_output
maxent_args = maxent_args + ' betamultiplier='      + '1.0 '
maxent_args = maxent_args + ' outputformat='        + 'raw'
maxent_args = maxent_args + ' fadebyclamping='      + 'true'
maxent_args = maxent_args + ' redoifexists'
maxent_args = maxent_args + ' autorun'

# sys.exit(0)  # devtest stop

# launch random bivariate MaxEnt run
# print('>>> rbvmax.py - pid', pid)
# maxent = 'singularity exec -B $NOBACKUP/MMX/_system my_ilab java -Xmx1500m -jar ' + rbv_maxent_jarfile + maxent_args
maxent = 'java -Xmx1500m -jar ' + rbv_maxent_jarfile + maxent_args + ' 2> /dev/null'
os.system(maxent)

# sys.exit(0)  # devtest stop

# copy MaxEnt run results to the shared mmx tmp directory
if os.path.exists(rbv_maxent_results) :
    shutil.copyfile(rbv_maxent_results, mmx_maxent_results)


# clean up miscellaneous files and directories
if os.path.exists(os.path.join(mmx_tmp, '.DS_Store')) :
    os.system('rm ' + mmx_tmp + '/.DS_Store')
os.system('rm -r ' + rbv_maxent_output)
os.system('rm -r ' + rbv_predictors)
os.system('rm ' + rbv_occurrence_file)


# normal exit
sys.exit(0)


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase, NASA
# Revision Date: 2023.02.25
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
