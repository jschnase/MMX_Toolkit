#!/Applications/miniconda3/bin/python3
# #!/usrbin/python3


# ==============================================================================
#
# mmx_select1.py (for remote server, doesn't copy variables ...)
# - selects top ten most contributory variables from the RBVMax ensemble runs
#   (requires positional arguments, see below ...)
#
# ==============================================================================


# import libraries
import shutil, random, os, sys, csv, datetime, numpy as np


# positional arguments
mmx_home                = sys.argv[1]   # <== mmx system working directory
working_set_directory   = sys.argv[2]   # <== mmx working set directory
selection_set_directory = sys.argv[3]   # <== mmx selection set directory


# create unique datetime-pid identifier for mmx objects
pid                       = os.getpid()
current_time              = datetime.datetime.now()
time_stamp                = current_time.strftime('%Y.%m.%d-%H.%M.%S')
mmx_uid                   = str(time_stamp) + '-' + str(pid)


# set remaining directory paths and variables
mmx_tmp                         = os.path.join(mmx_home, '_system/_tmp')
mmx_tmp_list                    = os.listdir(mmx_tmp)

working_set_list                = os.listdir(working_set_directory)
working_set_count               = len(working_set_list)


# beginn processing
print(">>> mmx_select2.py")


# clean up Mac's .DS_Store files if they exists
if os.path.exists(os.path.join(mmx_tmp, '.DS_Store')) :
    os.system('rm ' + mmx_tmp + '/.DS_Store')

if os.path.exists(os.path.join(working_set_directory, '.DS_Store')) :
    os.system('rm ' + working_set_directory + '/.DS_Store')


# initialize global tally_table, set predictor names index
tally_table = np.zeros((0,4))
for i in range(0, working_set_count) :
    working_set_list[i] = working_set_list[i].replace('.asc', '')
    new_line = np.array([i, 0.0, 0.0, 0.0])
    tally_table    = np.vstack([tally_table, new_line])


# assemble ensemble run selection_set in the global tally table
for file_name in mmx_tmp_list :

    file = os.path.join(mmx_tmp, file_name)

    with open(file) as csvfile :

        # read run result file
        data = list(csv.reader(csvfile, delimiter = ','))
        
        if data[1][7] != data [1][8]:  # check for presence of two variables

            # extract first variable name and permutation importance, update tally table
            var1_name = data[0][9].replace(' ', '_').replace('_permutation_importance', '')
            var1_pi = data[1][9]

            row1 = working_set_list.index(var1_name)
            tally_table[int(row1)][1] = tally_table[int(row1)][1] + 1
            tally_table[int(row1)][2] = tally_table[int(row1)][2] + float(var1_pi)
            tally_table[int(row1)][3] = tally_table[int(row1)][2] / tally_table[int(row1)][1]

            # extract second variable name and permutation importance, update tally table
            var2_name = data[0][10].replace(' ', '_').replace('_permutation_importance', '')
            var2_pi = data[1][10]

            row2 = working_set_list.index(var2_name)
            tally_table[int(row2)][1] = tally_table[int(row2)][1] + 1
            tally_table[int(row2)][2] = tally_table[int(row2)][2] + float(var2_pi)
            tally_table[int(row2)][3] = tally_table[int(row2)][2] / tally_table[int(row2)][1]


# sort the tally table by ascending average permutation importance
avg_sorted_tally_table = tally_table[tally_table[:, 3].argsort()]


# write out top ten list
# top_ten_file = os.path.join(selection_set_directory, mmx_uid + '-top_ten.csv')
top_ten_file = os.path.join(selection_set_directory, '_ss_top_ten.csv')
count        = working_set_count - 1
limit        = count - 10

with open(top_ten_file, 'w') as txt_file :
    header   = 'var' + ',' + 'cnt' + ',' 'sum' + ',' + 'avg' + ',' + '\n'
    txt_file.write(header)
    while count > limit :
        line =        working_set_list[int(avg_sorted_tally_table[count][0])] + ','
        line = line + str('{0:0.0f}'.format(avg_sorted_tally_table[count][1])) + ','
        line = line + str('{0:0.1f}'.format(avg_sorted_tally_table[count][2])) + ','
        line = line + str('{0:0.1f}'.format(avg_sorted_tally_table[count][3])) + '\n'
        txt_file.write(line)
        
        # # copy selected variables to selection_set directory
        # src = working_set_directory + '/' + working_set_list[int(avg_sorted_tally_table[count][0])] + '.asc'
        # dst = selection_set_directory + '/' + working_set_list[int(avg_sorted_tally_table[count][0])] + '.asc'
        # shutil.copy(src,dst)
        
        count = count - 1


# end processing
print(">>> mmx_select2.py done")


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


