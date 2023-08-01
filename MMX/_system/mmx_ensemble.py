#!/Applications/miniconda3/bin/python3
# #!/usrbin/python3

# ==============================================================================
#
# mmx_ensemble.py
# - launches parallel random bivariate maxent (RBVMax) selection runs
#   (requires positional arguments, see below ...)
#
# ==============================================================================


# import libraries
import os, sys, subprocess, time, shutil


# positional arguments
sample_size               = int(sys.argv[1])   # <== number of samples per base collection variable
node_count                = int(sys.argv[2])   # <== number of nodes available
core_count                = int(sys.argv[3])   # <== number of cores per node available
mmx_home                  = sys.argv[4]        # <== mmx system directory
working_set_directory     = sys.argv[5]        # <== mmx system working_set directory
occurrence_file_directory = sys.argv[6]        # <== mmx system occurrence_file directory

# print("argv[1] sample_count:              ", sample_size)
# print("argv[2] node_count :               ", node_count )
# print("argv[3] core_count:                ", core_count)
# print("argv[4] mmx_home :                 ", mmx_home )
# print("argv[5] working_set_directory:     ", working_set_directory)
# print("argv[6] occurrence_file_directory: ", occurrence_file_directory)


# set remaining directory paths and file names
occurrence_file_name      = os.listdir(occurrence_file_directory)
occurrence_file           = os.path.join(occurrence_file_directory, occurrence_file_name[0])

working_set_list          = os.listdir(working_set_directory)
working_set_count         = len(working_set_list)

rbvmax                    = os.path.join(mmx_home, '_system/_RBVMax/_system/rbvmax.py')
rbvmax                    = rbvmax + ' ' + mmx_home + ' ' + working_set_directory + ' ' + occurrence_file_directory
# rbvmax_test               = os.path.join(mmx_home, '_system/_RBVMax/_system/rbvmax_test.py')


# determine the number of sprints needed given system node / core configuration
runs_needed               = (working_set_count * sample_size) / 2
sprints_needed            = runs_needed / (node_count * core_count)

# print("occurrence_file_name:              ", occurrence_file_name)
# print("occurrence_file:                   ", occurrence_file)
# print("working_set_list:                  ", working_set_list)
# print("working_set_count:                 ", working_set_count)
# print("rbvmax:                            ", rbvmax)
# print("runs_needed:                       ", runs_needed)
# print("sprints_needed:                    ", sprints_needed)


# RBVmax fanout ----------------------------------------------------------------

start_time = time.time()

for i in range(int(sprints_needed)) :

    print("------------------------------------------------")
    print(">>> mmx_ensemble.py - sprint ", i)
    sum = 0
    code = [[]] * core_count
    process = [[]] * core_count

    # launch bivariant maxent runs on available node cores
    for j in range(int(core_count)) :
        print(">>> mmx_ensemble.py - core ", j)
        process[j] = subprocess.Popen(rbvmax, shell=True, stderr=None)
        # process[j] = subprocess.Popen(rbvmax_test, shell=True, stderr=None)

    # wait for processes to finish
    for k in range(int(core_count)) :
        code[k] = process[k].wait()
        sum = sum + code[k]

stop_time = time.time()

# ------------------------------------------------------------------------------


print("------------------------------------------------")
print("Sprints complete / Node summary:")
print("working_set_count   = " + str(working_set_count))
print("sample_size         = " + str(sample_size))
print("node_count          = " + str(node_count))
print("core_count          = " + str(core_count))
print("runs_needed         = " + str(int(runs_needed)))
print("sprints_needed      = " + str(int(sprints_needed)))
print("node_elapsed_time   = %.2f seconds" % (stop_time - start_time))
print("-----------------------------------------------")


# normal exit
sys.exit(0)


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

