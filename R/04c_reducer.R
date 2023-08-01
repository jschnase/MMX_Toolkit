# ==============================================================================
#
# 04c_reducer.R
# - removes collinear variables from the selection_set to create a model_set
#   of non-collinear variables for use in final model construction
#   (generally used after mmx_linter.R)
#
# ==============================================================================


# set up the RStudio environment -----------------------------------------------

# rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
# show.config()

# install.packages("usdm", dependencies = TRUE)
library(usdm)


# initializations --------------------------------------------------------------

wd      <- MMX_EXPERIMENT_DIRECTORY
run     <- RUN_NAME
run_dir <- paste0(wd, "/", run, "/TimeSeries")

start_yr <- as.numeric(TEMPORAL_EXTENT_START_YR)
stop_yr  <- as.numeric(TEMPORAL_EXTENT_STOP_YR)
step     <- as.numeric(TEMPORAL_EXTENT_INTERVAL)


# main processing loop ---------------------------------------------------------

print(" "); print("Starting 04c_reducer.R ..."); print(" ")

for (year in seq(start_yr, stop_yr, step)) {

# set run paths
ss_dir  <- paste0(run_dir, "/", year, "/selection_set")
ws_dir  <- paste0(run_dir, "/", year, "/working_set")
ms_dir  <- paste0(run_dir, "/", year, "/model_set")

src <- ss_dir
dst <- ms_dir

# load environmental layers
files <- dir(src, recursive=TRUE, full.names=TRUE, pattern="*.asc")
src_vars_stack <- raster::stack(files)

# src_vars <- list.files(src, pattern = "*.asc")
# stack_list <- list()
# for (i in 1:length(src_vars)){
#     s <- rast(paste0(src, "/", src_vars[i]))
#     plot(s, main=paste0(src_vars[i], " - ", year))
#     stack_list[[i]] <- stack(s)
# }
# src_vars_stack <- stack(stack_list)

# reduce src collinearities
var_vifs <- vif(as.data.frame(src_vars_stack))
cor_vars <- vifstep(as.data.frame(src_vars_stack), th = 10)
ms_vars  <- exclude(src_vars_stack, cor_vars)

write.csv(var_vifs, file = paste0(ms_dir, "/_variable_vifs.csv"))
write.csv(cor_vars@variables, file = paste0(ms_dir, "/_source_variables.csv"))
write.csv(cor_vars@results, file = paste0(ms_dir, "/_correlation_results.csv"))
write.csv(cor_vars@corMatrix, file = paste0(ms_dir, "/_correlation_matrix.csv"))
write.csv(cor_vars@excluded, file = paste0(ms_dir, "/_excluded_variables.csv"))
write.csv(cor_vars@results$Variables, file = paste0(ms_dir, "/_retained_variables.csv"))

print(" "); print(paste0("--- ", year, " -----------------------------")); print(" ")
print(">>> variable inflation factors"); print(var_vifs); print(" ")
# print(">>> correlated variables"); print(cor_vars); print(" ")

# create model_set with non-collinear variables
for (i in 1:length(names(ms_vars))) {
    system(paste0("cp ", src, "/", names(ms_vars)[i], ".asc", " ", ms_dir, "/."))
}

# invisible(readline(prompt="Press [enter] to continue"))

} # end of processing

print(" "); print("Done ..."); print(" ")


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# Date: 2023.02.08
#
# -------------------------------------------------------------------------
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
