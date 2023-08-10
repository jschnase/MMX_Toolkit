# ==============================================================================
#
# 04c_mmx_timeseries_builder.R
#
# - script performs ENMeval-based model calibration and final model construction:
#     . creates a bias file using 2d kernel density estimation
#     . determines optimal model parameters using enmeval
#     . creates an optimally tuned model
#     . saves model info and predictions
#     . operates in a batch mode going from yr_start to yr_stop
#     . operates in a yearly mode when yr_start and yr_stop are the same year
#
# ==============================================================================


# set up the RStudio environment -----------------------------------------------

# rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
# show.config()

# install.packages("sys", dependencies = TRUE)
# install.packages("rJava", dependencies = TRUE)
# install.packages("ENMeval", dependencies = TRUE)
# install.packages("raster", dependencies = TRUE)
# install.packages("MASS", dependencies = TRUE)
# install.packages("dismo", dependencies = TRUE)
# install.packages("Hmisc", dependencies = TRUE)
# install.packages("paletteer", dependencies = TRUE)
# install.packages("colorRamps", dependencies = TRUE)

library(sys)
library(rJava)
library(ENMeval)
library(raster)
library(MASS)
library(dismo)
library(Hmisc)
library(paletteer)
library(colorRamps)


# initializations --------------------------------------------------------------

wd       <- MMX_EXPERIMENT_DIRECTORY
run      <- RUN_NAME
run_dir  <- paste0(wd, "/", run, "/TimeSeries")

sp_name  <- SPECIES_NAME

start_yr <- as.numeric(TEMPORAL_EXTENT_START_YR)
stop_yr  <- as.numeric(TEMPORAL_EXTENT_STOP_YR)
step     <- as.numeric(TEMPORAL_EXTENT_INTERVAL)


# main -------------------------------------------------------------------------

print(" "); print("Starting 04d_timeseries_builder.R ..."); print(" ")

for (year in seq(start_yr, stop_yr, step)) {

# set run paths
of_file <- paste0(run_dir, "/", year, "/occurrence_file/OF-", year, ".csv")
ss_dir  <- paste0(run_dir, "/", year, "/selection_set")
ws_dir  <- paste0(run_dir, "/", year, "/working_set")
ms_dir  <- paste0(run_dir, "/", year, "/model_set")

src_dir <- ms_dir
dst_dir <- paste0(run_dir, "/", year, "/model")

# load and count occurrence points
# - occurrence file column headings need to be changed for enmeval
# - longitude -> x, latitude -> y
# - this bit of code does it ...
occ <- read.csv(of_file)[,-1]
names(occ) <- c("x", "y")
obs <- nrow(occ)

# load environmental layers, assemble them into a stack data structure
src_vars   <- list.files(src_dir, pattern = "*.asc")
stack_list <- list()
for (i in 1:length(src_vars)){
    s <- raster(paste0(src_dir, "/", src_vars[i]))
    plot(s, main=paste0(src_vars[i], " - ", year))
    crs(s) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    stack_list[[i]] <- stack(s)
}
env <- stack(stack_list)

# create a bias file using 2d kernel density estimation
occ_raster <- rasterize(occ, env, 1)
plot(occ_raster,
     main = paste0("Observations - ", year),
     sub  = paste0("( n = ", obs, " total observations )"),
     pch  = 16, col = "blue", legend = FALSE)
png(file = paste0(dst_dir, "/", year, "_observations.png"))
plot(occ_raster,
     main = paste0("Observations - ", year),
     sub  = paste0("( n = ", obs, " total observations )"),
     pch  = 16, col = "blue", legend = FALSE)
dev.off()

presence_list      <- which(values(occ_raster) == 1)
presence_locations <- coordinates(occ_raster)[presence_list, ]

density <- kde2d(presence_locations[,1], presence_locations[,2],
                 n = c(nrow(occ_raster), ncol(occ_raster)),
                 lims = c(extent(env)[1], extent(env)[2],
                 extent(env)[3], extent(env)[4]))

density_raster1 <- raster(density, env)
density_raster2 <- resample(density_raster1, env)

writeRaster(density_raster2, paste0(dst_dir, "/", year, "_biasfile.asc"), overwrite = TRUE)
writeRaster(density_raster2, paste0(dst_dir, "/", year, "_biasfile.asc"), overwrite = TRUE)

plot(density_raster2,
     main = paste0("Kernel Density Estimate - ", year),
     sub  = paste0("( n = ", obs, " total observations )"))
png(file = paste0(dst_dir, "/", year, "_observation_density_estimate.png"))
plot(density_raster2,
     main = paste0("Kernel Density Estimate - ", year),
     sub  = paste0("( n = ", obs, " total observations )"))
dev.off()

# check how many potential background points are available
# - If this number is in excess of 10,000, then use 10,000 background points.
# - If this number is comparable to, or smaller than 10,000, then use 5,000, 1,000, or 500
available_points <- length(which(!is.na(values(subset(env, 1)))))
# available_points2 <- length(which(!is.na(values(subset(density_raster2, 1)))))

if (available_points > 10000) {
    bck <- 10000
    } else {
    bck <- 5000
}


# convert bias file format and create random background samples
# bg <- xyFromCell(density_raster2, sample(which(!is.na(values(subset(env, 1)))),
#             10000, prob=values(density_raster2)[!is.na(values(subset(env, 1)))]))
# bg <- xyFromCell(density_raster2, sample(which(!is.na(values(subset(env, 1)))),
#             500, prob=values(density_raster2)[!is.na(values(subset(env, 1)))]))
bg <- xyFromCell(density_raster2, sample(which(!is.na(values(subset(env, 1)))),
            bck, prob=values(density_raster2)[!is.na(values(subset(env, 1)))]))
plot(bg,
     main = paste0("Biasfile Background Points - ", year),
     sub  = paste0("( based on n = ", obs, " total real observations )"),
     pch  = 1, col = "blue")
png(file = paste0(dst_dir, "/", year, "_biasfile_background_points.png"))
plot(bg,
     main = paste0("Biasfile Background Points - ", year),
     sub  = paste0("( based on n = ", obs, " total real observations )"),
     pch  = 1, col = "blue")
dev.off()

# run and time enmeval evaluation
run_time_sec <- system.time({  # start the clock
    if (FULL_ENMEVAL_SCAN == TRUE) {
        print(paste0(">>> performing full enmeval scan - ", year))
        enmeval_results <- ENMevaluate(occ, env,
                                       # bg.coords  = bg,
                                       bg         = NULL,
                                       n.bg       = bck,
                                       algorithm  ='maxent.jar',
                                       method     = 'randomkfold',
                                       RMvalues   = seq(0.5, 4, 0.5),
                                       fc         = c("L", "LQ", "H", "LQH", "LQHP", "LQHPT"),
                                       parallel   = TRUE,
                                       numCores   = NULL)
        
    } else {
        print(paste0(">>> performing simple enmeval scan - ", year))
        # enmeval_results <- ENMevaluate(occ, env,
        #                                # bg.coords  = bg,
        #                                bg         = NULL,
        #                                n.bg       = bck,
        #                                algorithm  ='maxent.jar',
        #                                method     = 'randomkfold',
        #                                RMvalues   = 1.0,
        #                                fc         = "LQ",
        #                                parallel   = TRUE,
        #                                numCores   = NULL)
        enmeval_results <- ENMevaluate(occ, env,
                                       # bg.coords  = bg,
                                       bg         = NULL,
                                       n.bg       = bck,
                                       algorithm  ='maxent.jar',
                                       method     = 'randomkfold',
                                       RMvalues   = seq(1.0, 3.0, 1.0),
                                       fc         = c("L", "Q", "LQ"),
                                       parallel   = TRUE,
                                       numCores   = NULL)
    }

})[3]                      # stop the clock

# record total run time
run_time_min <- run_time_sec / 60
run_time_hr  <- run_time_min / 60
run_time     <- format(run_time_min, digits = 4, nsmall = 1)
print(paste0("run time = ", run_time, " minutes"))
system(paste0("touch ", dst_dir, "/", year, "_runtime_", run_time, "_mins"))

# show results in the R console
enmeval_results@results

# report enmeval results
write.csv(enmeval_results@results, paste0(dst_dir, "/", year, "_enmeval_tuning_results.csv"))

# find the best model (delta AICc = 0, pick first if multiple ...)
best_model <- enmeval_results@models[[which(enmeval_results@results$delta.AICc == 0)[1]]]
write.csv(best_model@results, paste0(dst_dir, "/", year, "_model_results.csv"))
# system(paste0("cp ", best_model@html, " ", dst_dir, "/", year, "_model_results.html"))

# ==> report best model variable permutation importance
system(paste0("cat ", paste0(dst_dir, "/", year, "_model_results.csv"),
              " | grep permutation.importance > ", dst_dir, "/", year,
              "_model_permutation_importance.csv"))

# ==> report best model training AUC
system(paste0("cat ", paste0(dst_dir, "/", year, "_model_results.csv"),
              " | grep Training.AUC > ", dst_dir, "/", year,
              "_model_training_auc.csv"))

# ==> report best model max sum sensitivity/specificity threshold
system(paste0("cat ", paste0(dst_dir, "/", year, "_model_results.csv"),
              " | grep Maximum.training > ", dst_dir, "/", year,
              "_model_threshold_maxSSS.csv"))

# ==> report best model equal sensitivity/specificity threshold
system(paste0("cat ", paste0(dst_dir, "/", year, "_model_results.csv"),
              " | grep Equal.training > ", dst_dir, "/", year,
              "_model_threshold_eqSS.csv"))

# ==> report best model p10 threshold
system(paste0("cat ", paste0(dst_dir, "/", year, "_model_results.csv"),
              " | grep X10.percentile > ", dst_dir, "/", year,
              "_model_threshold_p10.csv"))

# report best model variable percent contributions
plot(best_model, main = paste0("Variable Contributions - ", c(year)), pch = 19)
minor.tick(nx = 10, ny = FALSE, tick.ratio = 0.5)
png(file = paste0(dst_dir, "/", year, "_model_contributions.png"))
    plot(best_model, main = paste0("Variable Contributions - ", c(year)), pch = 19)
    minor.tick(nx = 10, ny = FALSE, tick.ratio = 0.5)
dev.off()

# record best model predictions
prediction <- eval.predictions(enmeval_results)[[which(enmeval_results@results$delta.AICc == 0)[1]]]
writeRaster(prediction, filename =  paste0(dst_dir, "/", year, "_model_prediction.asc"),
            format = "ascii", overwrite = TRUE)

pal <- blue2green2red(400)
# - with observations
plot(prediction,
     main = paste0(sp_name, " Habitat Suitability - ", c(year)),
     sub  = paste0("( n = ", obs, " total observations )"),
     col  = pal,
     zlim = c(0,1))
points(eval.occs(enmeval_results), pch = 20, col = "white", bg = eval.occs.grp(enmeval_results))
png(file = paste0(dst_dir, "/", year, "_model_prediction_with_obs.png"))
plot(prediction,
     main = paste0(sp_name, " Habitat Suitability - ", c(year)),
     sub  = paste0("( n = ", obs, " total observations )"),
     col  = pal,
     zlim = c(0,1))
points(eval.occs(enmeval_results), pch = 20, col = "white", bg = eval.occs.grp(enmeval_results))
dev.off()

# - without observations
plot(prediction,
     main = paste0(sp_name, " Habitat Suitability - ", c(year)),
     sub  = paste0("( n = ", obs, " total observations )"),
     col  = pal,
     zlim = c(0,1))
png(file = paste0(dst_dir, "/", year, "_model_prediction_without_obs.png"))
plot(prediction,
     main = paste0(sp_name, " Habitat Suitability - ", c(year)),
     sub  = paste0("( n = ", obs, " total observations )"),
     col  = pal,
     zlim = c(0,1))
dev.off()

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
