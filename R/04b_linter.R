# ==============================================================================
#
# 04b_linter.R
#
# - script to remove NA-rich variables from the selection_set
#   (optional, used before mmx_reducer.R, repeat as needed until clean)
#
# ==============================================================================


# set up the RStudio environment -----------------------------------------------

# rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
# show.config()

# install.packages("raster", dependencies = TRUE)
# install.packages("ncdf4", dependencies = TRUE)

library(raster)
library(ncdf4)


# initializations --------------------------------------------------------------

wd       <- MMX_EXPERIMENT_DIRECTORY
run      <- RUN_NAME
run_dir  <- paste0(wd, "/", run, "/TimeSeries")

start_yr <- as.numeric(TEMPORAL_EXTENT_START_YR)
stop_yr  <- as.numeric(TEMPORAL_EXTENT_STOP_YR)
step     <- as.numeric(TEMPORAL_EXTENT_INTERVAL)


# main -------------------------------------------------------------------------

print(" "); print("Startimg 04b_linter.R ..."); print(" ")

for (year in seq(start_yr, stop_yr, step)) {

# set run paths
of_file <- paste0(run_dir, "/", year, "/occurrence_file/OF-", year, ".csv")
ss_dir  <- paste0(run_dir, "/", year, "/selection_set")
ms_dir  <- paste0(run_dir, "/", year, "/model_set")

src     <- ss_dir
dst     <- ss_dir

# load and count occurrence points
occ <- read.csv(of_file)[,-1]
obs <- nrow(occ)

# load environmental layers
src_vars <- list.files(src, pattern = "*.asc")
stack_list <- list()

# initialize variables
max_na  <- 0
max_var <- ""
tot_na  <- 0
n       <- length(src_vars)

# show linting scan
print(paste0("--- ", year, " -----------------------"))

for (i in 1:n){
    s <- raster(paste0(src, "/", src_vars[i]))
    na <- sum(is.na(extract(s,occ)))
    print(paste0(src_vars[[i]], " - NA = ", na))
    if (na > max_na) {
        max_na <- na
        max_var <- src_vars[i]
        }
    tot_na <- tot_na + na
}
print("---")
avg_na1 <- round((tot_na / n), digits = 1)
avg_na2 <- round(((tot_na - max_na) / (n - 1)), digits = 1)
print(paste0("max = ", max_var, " na = ", max_na))
print(paste0("avg1 = ", avg_na1))
print(paste0("avg2 = ", avg_na2))

# lint as needed
msg <- paste0("original selection set ( n = ", length(list.files(src, pattern = "*.asc")), " ):")
print("---"); print(msg)
print(list.files(src, pattern = "*.asc"))
if ( (avg_na1-avg_na2) > 0.2 ) {
    old_list <- list.files(src, pattern = "*.asc")
    print(" "); print(paste0("bad var: ", src, "/", max_var))

    # rename in place ...
    src_var <- paste0(src, "/", max_var)
    dst_var <- paste0(dst, "/", gsub(".asc", ".xxx", max_var))
    file.rename(src_var, dst_var)

}

msg <- paste0("linted selection set ( n = ", length(list.files(src, pattern = "*.asc")), " ):")
print("---"); print(msg)
print(list.files(src, pattern = "*.asc")); print(" ")

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
