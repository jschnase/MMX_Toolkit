# ==============================================================================
#
# ws_builder.R
#
# Ssubsets mmx base_collection MERRA-2 nc files to create a working_set
# collection of cropped, resampled, downscaled, and masked MaxEnt-ready
# asc files following the method of R.J. Hijmans as described here:
# https://stat.ethz.ch/pipermail/r-sig-geo/2010-February/007544.html
#
# (NB default settings throughout are set up for 05YrAg processing)
#
# ==============================================================================


# set up the RStudio environment -----------------------------------------------

# rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
# show.config()

# install.packages("raster", dependencies = TRUE)
# install.packages("stringi", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)
library(raster)
library(stringi)
library(sf)


# initializations --------------------------------------------------------------

sp_key   <- GBIF_TAXON_KEY
sp_name  <- SPECIES_NAME

start_yr <- as.numeric(TEMPORAL_EXTENT_START_YR)
stop_yr  <- as.numeric(TEMPORAL_EXTENT_STOP_YR)
step_yr  <- as.numeric(TEMPORAL_EXTENT_INTERVAL)

# the working_set collection created here is stored in what will be the source
# working_set directory used in downstream processing; by default, the directory
# is named for the species being processed ...
ws_dir  <- WS_DST_DIRECTORY
out_dir <- paste0(ws_dir, "/", GBIF_TAXON_KEY,"-", SPECIES_NAME)
if (!dir.exists(out_dir)){
    dir.create(out_dir)
}else{
    print(">>> 02b_m2_ws_builder.R: ws directory exists")
}

# set path to the toolkit predictor base_collection
bc_dir  <- paste0(MTK_DATA_DIRECTORY, "/base_collections", "/", BASE_COLLECTION)

# set study area extent
ymax <- as.numeric(SPATIAL_EXTENT_UL_LAT)  # upper left,  upper right latitude
xmin <- as.numeric(SPATIAL_EXTENT_UL_LON)  # upper left,  lower left  longitude
ymin <- as.numeric(SPATIAL_EXTENT_LR_LAT)  # lower left,  lower right latitude
xmax <- as.numeric(SPATIAL_EXTENT_LR_LON)  # upper right, lower right longitude
ext  <- extent(xmin, xmax, ymin, ymax)

# build study area HI-RES mask from world map and 5 arc-min worldclim data layer
# note: working_set predictor grid cells will be squared and "downscaled" against
# the worldclim layer used here (default is 5 arc-min or ~ 0.08333333 degrees)
# (not really downscaling: resolution is increased to smooth data representation)
# ------
# these steps only need to be performed once to create '_world.tif' in the out_dir
# world          <- st_as_sf(maps::map('world', fill=TRUE, plot=FALSE))
# tmax_data      <- getData(name='worldclim', var='tmax', res=5)
# tmax_jan       <- stack(tmax_data)[[1]]
# tmax_jan_world <- raster::crop(raster::mask(tmax_jan, as_Spatial(world)), as_Spatial(world))
# tmax_jan_world[tmax_jan_world != 0] <- 0
# writeRaster(tmax_jan_world, filename=paste0(out_dir, '/_world.tif'), format='GTiff', overwrite=TRUE)
# file.remove(paste0(out_dir, '/_world.tif.aux.xml'))
# ------
# these steps only need to be performed once to create '_mask.asc' in the out_dir
# tmax_mean_world <- raster(paste0(out_dir, '/_world.tif'))
tmax_mean_world <- raster(paste0(MTK_RESOURCES_DIRECTORY, '/world.tif'))
cropped_world   <- crop(tmax_mean_world, ext)
mask            <- raster(cropped_world)
mask            <- resample(cropped_world, mask, method='bilinear')
writeRaster(mask, filename=paste0(out_dir, '/_mask.asc'), format='ascii', overwrite=TRUE)
# file.remove(paste0(out_dir, '/_mask.asc.aux.xml'))
# ------


# main processing loop ---------------------------------------------------------

print("Starting 02b_m2_ws_builder.R ...")

for (year in seq(start_yr, stop_yr, step_yr)) {
    dir.create(paste0(out_dir, "/", year))
    files <- list.files(path = bc_dir, pattern = paste0(year, ".nc"))
    for (var in files) {
        r <- raster(paste0(bc_dir, "/", var ))

        # lores option (ie native merra-2)
        # lores_s      <- raster(r)
        # res(lores_s) <- 0.5  # ie, min(res(r))
        # lores_s      <- resample(r, lores_s, method='bilinear')
        # lores_c      <- crop(lores_s, ext)
        # lores_m      <- raster::mask(lores_c, resample(mask, lores_c, method='bilinear'))
        # writeRaster(lores_m, filename=paste0(out_dir, "/", year, "/", gsub(".nc", ".lores.asc", var)), format="ascii", overwrite=TRUE)
        # plot(lores_m, main=paste0("lores - ", var))

        # hires option (the default)
        hires_s      <- raster(r)
        res(hires_s) <- min(res(mask)) # resolution of original WorldClim var
        hires_s      <- resample(r, hires_s, method='bilinear')
        hires_c      <- crop(hires_s, ext)
        hires_m      <- raster::mask(hires_c, resample(mask, hires_c, method='bilinear'))
        str <- stri_replace_last_fixed(var, paste0("_", year, ".nc"), '.asc')
        writeRaster(hires_m, filename=paste0(out_dir, "/", year, "/", str), format="ascii", overwrite=TRUE)
        plot(hires_m, main=paste0("hires - ", var))
    }

    # pause for input control
    # invisible(readline(prompt='Press [enter] to continue'))

}

print("Done ...")


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase
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
