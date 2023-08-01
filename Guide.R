# ==============================================================================
#
# Guide.R - MMX Toolkit V0.1.0 Interactive Users Guide
#
# ==============================================================================


rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
show.config()


# SYSTEM CONFIGURATION ---------------------------------------------------------
#
# MacBook Pro (Mac14,7) Apple M2
# maxOS Monterey Version 12.6.3
# Cores 8 (4 performance and 4 efficiency)
# Memory 24 GB
#
# R version 4.1.3 (2022-03-10) -- "One Push-Up"
# Copyright (C) 2022 The R Foundation for Statistical Computing
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Libraries: sys, rJava, ENMeval, raster, MASS, dismo, Hmisc, paletteer,
#            colorRamps, usdm, ncdf4, rgdal,, gganimate, gifski, png, animation,
#            tidyverse, rtsVis, spatialEco, terra, pals, plyr, scales, stringi
#
# RStudio 2022.07.1+554 "Spotted Wakerobin" Release
# (7872775ebddc40635780ca1ed238934c3345c5de, 2022-07-22) for macOS
# Mozilla/5.0 (Macintosh; Intel Mac OS X 12_6_3) AppleWebKit/537.36
# (KHTML, like Gecko) QtWebEngine/5.12.10 Chrome/69.0.3497.128 Safari/537.36
#
# Java OpenJDK Version "20.0.2" 2023-07-18
# OpenJDK Runtime Environment (build 20.0.2+9-78)
# OpenJDK 64-Bit Server VM (build 20.0.2+9-78, mixed mode, sharing)
#
#
# Python 3.9.12 (main, Apr  5 2022, 01:53:17)
# [Clang 12.0.0 ] :: Anaconda, Inc. on darwin
# Libraries: os, sys, subprocess, time, shutil, random, csv, datetime, time,
# numpy as np
#
# MaxEnt Maximum Entropy Species Distribution Modeling
# Version 3.4.1

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
#
# These scripts can be run step-by-step in the RStudio environment by entering 
# CMD + Return while the cursor is positioned over the R statement. The entire 
# workflow can be carried out "automatically" by selecting all the lines in the 
# guide and pressing "Run" at the top right of the RStudio script window.
#
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

print(" "); print("Starting MMX_Tk_GTO.R ..."); print(" ")

guide_start0 <- system("date +%s", intern=TRUE)
guide_start1 <- system("date +%Y.%m.%d-%H.%M.%S", intern=TRUE)


# (01) SET UP SYSTEM DIRECTORIES -----------------------------------------------

# >>> (a) Symbolic links -- This is a manual step. Install the MMX_Toolkit  
# and create an MMX_Experiment directory in locations of your choosing,  
# then create symbolic links from your home directory to these two locations. 
# For example, from my home directory ~/ I see: 
# ~/MMX_Experiment -> /Users/myname/Dropbox/MMX-Project/MMX-Experiments/Exp000
# ~/MMX_Toolkit -> /Users/myname/Dropbox/MMX-Project/MMX-Development/MMX_Toolkit

# >>> (b) Configuration file -- Copy the _mmx_config file from the ~/MMX_Toolkit
# /resources directory to the new ~/MMX_Experiment directory and edit the file
# as needed to configure for the current run


# (02) PREPARE DATA ------------------------------------------------------------

# >>> (a) Occurrence files -- Run ~/MMX_Toolkit/R/02a_get_occurrences.R to
# assemble a collection of GBIF observations for each five-year interval of the
# time series. Results are delivered to the directory specified in _mmx_config's
# OF_DST_DIRECTORY field. The default name of the output directory is the GBIF
# species taxon key + species name. See .pdf version of the Guide for additional 
# notes on this step (it may require manual intervention).
step_02a <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/02a_get_occurrences.R")
source(step_02a)

# >>> (b) MERRA-2 Predictors -- Run ~/MMX_Toolkit/R/02b_m2_ws_builder.R to build
# a working_set collection of MERRA-2 predictors for each five-year interval of
# the time series. The script draws from a base_collection of .nc files as
# specified in the _mmx_config file's BASE_COLLECTION field. Results are
# delivered to the directory specified in _mmx_config's WS_DST_DIRECTORY field.
# The default name of the output directory is the GBIF species taxon key + 
# species name.
step_02b <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/02b_m2_ws_builder.R")
source(step_02b)

# >>> (c) MERRAclim-2 Predictors -- Run ~/MMX_Toolkit/R/02c_mc_ws_builder.R to 
# build a working_set collection of MERRAclim-2 predictors for each five-year 
# interval of the time series. The script draws from a base_collection of .tif 
# files as specified in the _mmx_config file's BASE_COLLECTION field. Results 
# are delivered to the directory specified in _mmx_config's WS_DST_DIRECTORY
# field. The default name of the output directory is the GBIF species taxon key 
# + species name.
step_02c <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/02c_mc_ws_builder.R")
source(step_02c)


# (03) SET UP ENM TIME SERIES RUN ----------------------------------------------

# >>> (a) Create the top-level experiment directories
step_03a  <- paste0(MMX_TOOLKIT_DIRECTORY, "/bash/03a_create_exp_directories.sh")
system(step_03a, intern=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE)

# >>> (b) Create second-level time series directories, populate occurrence_file
# and working_set directories.
step_03b <- paste0(MMX_TOOLKIT_DIRECTORY, "/bash/03b_populate_ts_directories.sh")
system(step_03b, intern=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE)


# (04) BUILD ENM TIME SERIES ---------------------------------------------------

# >>> (a) Variable selection -- This step uses MMX (MERRA/Max) to screen for
# the top ten most contributory variables in each of the time series five-year
# interval's working_set of predictors. It can take a lot of time depending on
# the number of available cores and the size of the working sets.
# Run ~/MMX_Toolkit/bash/04a_mmx_select_vars_local.sh to process the entire
# time series on the local host; run with a year parameter from the command line
# to process a single five-year interval. Results are placed in each interval's
# selection_set directory. (The current version of the MMX Toolkit performs 
# selection on the local host only.)
step_04a <- paste0(MMX_TOOLKIT_DIRECTORY, "/bash/04a_select_vars_local.sh")
system(step_04a, intern=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE)

# >>> (b) Linting -- Remove NA-rich variables from the selection_set. This step
# is optional. If used, repeat as needed until a "clean" selection_set is
# obtained. Results reside in the selection-set folder with deleted variables
# indicated by a .xxx file name extension.
step_04b <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/04b_linter.R")
source(step_04b)

# >>> (c) Covariance reduction -- Remove colinear variables in the selection_set.
# Results are deposited in the model_set directory.
step_04c <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/04c_reducer.R")
source(step_04c)

# >>> (d) Time series build -- Find optimal MaxEnt turning parameters and
# generate a final model for each time interval in the ENM time series. Results
# are deposited in the model directory.
step_04d <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/04d_timeseries_builder.R")
source(step_04d)


# (05) SET UP TREND ANALYSIS RUN -----------------------------------------------

# >>> (a) Create the ENM and VAR trend analysis directories and populate the ENM
# directory with predictors. (This version of the MMX Toolkit performs trend 
# analysis on the suitability time series only.)
step_05a <- paste0(MMX_TOOLKIT_DIRECTORY, "/bash/05a_setup_ta_directories.sh")
system(step_05a, intern=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE)


# (06) RUN ENM TREND ANALYSIS --------------------------------------------------

# >>> (a) Theil-Sen trend -- Find the Theil-Sen trend in predicted environmental
# suitability over the enm time series.
step_06a <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/06a_enm_theilsen_trend.R")
source(step_06a)


# (07) SET UP VELOCITY ANALYSIS RUN --------------------------------------------

# >>> (a) Create and populate the ENM and VAR velocity analysis directories. 
# (This version of the MMX Toolkit performs trend analysis on the suitability 
# time series only.)
step_07a <- paste0(MMX_TOOLKIT_DIRECTORY, "/bash/07a_setup_va_directories.sh")
system(step_07a, intern=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE)


# (08) RUN ENM VELOCITY ANALYSIS -----------------------------------------------

# >>> (a) ENM (biotic) velocity -- Find the bioclimatic velocity over the ENM
# time series.
step_08a <- paste0(MMX_TOOLKIT_DIRECTORY, "/R/08a_enm_velocity.R")
source(step_08a)


# (09) COLLECT RESULTS ---------------------------------------------------------

# >>> (a) Gather run results and place them in the Summaries directory.
step_09a <- paste0(MMX_TOOLKIT_DIRECTORY, "/bash/09a_collect_results.sh")
system(step_09a, intern=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE)


# record run times
guide_stop0 <- system("date +%s", intern=TRUE)
guide_stop1 <- system("date +%Y.%m.%d-%H.%M.%S", intern=TRUE)

elap_sec <- round(as.numeric(guide_stop0) - as.numeric(guide_start0), digits=2)
elap_min <- round((elap_sec / 60), digits=2)
elap_hrs <- round((elap_min / 60), digits=2)

print(paste0(">>> Start time = ", guide_start1))
print(paste0(">>> Stop time  = ", guide_stop1))

system(paste0("touch ", MMX_EXPERIMENT_DIRECTORY, "/", RUN_NAME,
              "/_Start_Time-", guide_start1))
system(paste0("touch ", MMX_EXPERIMENT_DIRECTORY, "/", RUN_NAME,
              "/_Stop_Time-", guide_stop1))

# system(paste0("touch ", MMX_EXPERIMENT_DIRECTORY, "/", RUN_NAME,
#               "/_Total_Elapsed_Time-", elap_min, "_minutes"))
system(paste0("touch ", MMX_EXPERIMENT_DIRECTORY, "/", RUN_NAME,
              "/_Total_Elapsed_Time-", elap_hrs, "_hours"))

print(" "); print("Done ..."); print(" ")


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase
# Revision Date: 2023.04.24
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

