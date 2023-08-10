# ==============================================================================
#
# 06a_enm_theilsen_trend.R
#
# - finds weighted centroids in enm time series 
#
# ==============================================================================


# set up the RStudio environment -----------------------------------------------

# rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
# show.config()

library(raster)
library(terra)
library(enmSdmX)


# initializations --------------------------------------------------------------

wd   <- MMX_EXPERIMENT_DIRECTORY
run  <- RUN_NAME
src  <- paste0(wd, "/", run, "/Trends/ENM/_Predictions")
dst  <- paste0(wd, "/", run, "/Velocities/ENM")
lbl  <- paste0(SPECIES_NAME, "-ENM-Weighted-Centroid")

sp_name     <- SPECIES_NAME
state_lines <- vect(STATE_LINES_RDS)


# main -------------------------------------------------------------------------

# build hsm predictions raster stack
stack <- raster(); vars <- list()
vars   <- list.files(src, pattern = "*.asc")
for (i in 1:length(vars)){
    s <- raster(paste0(src, "/", vars[i]))
    plot(s, main=vars[i], zlim = c(0,1))
    crs(s) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    stack <- addLayer(stack,s)
}


# plot change in suitability
delta <- stack[[8]] - stack[[1]]
plot(delta, main = 'Change in Suitability')

# reproject state lines for use with our layers
state_lines <- project(state_lines, rast(stack[[1]]))


# calculate biotic velocity
series <- c(
    rast(stack[[1]]),
    rast(stack[[2]]),
    rast(stack[[3]]),
    rast(stack[[4]]),
    rast(stack[[5]]),
    rast(stack[[6]]),
    rast(stack[[7]]),
    rast(stack[[8]])
)

setMinMax(series)

names(series) <- c('1980', '1985', '1990', '1995', '2000', '2005', '2010', '2015')
plot(series)

times <- c(1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015)
quants <- c(0.10, 0.90)

# compute centroid movements
bv <- bioticVelocity(
    x = series,
    times = times,
    # atTimes = c(2010, 2015),
    metrics = "centroid",
    quants = quants,
    cores = 1
)

# display and write results
bv
write.csv(bv, paste0(dst, "/", lbl, ".csv"))


# plot centroid velocities
plot(bv$timeMid, bv$centroidVelocity, type = 'l',
     xlab = 'Year', ylab = 'Speed (m / y)', main = 'Centroid Speed')

# map centroid location through time
pal   <- paletteer_c("ggthemes::Classic Area Red-Green", 400)
plot(delta, main = 'Change in Suitability and Weighted Centroid Locations',
     col  = pal)
points(bv$centroidLong[1], bv$centroidLat[1], pch = 1)
points(bv$centroidLong[7], bv$centroidLat[7], pch = 16)
legend(
    'bottomright',
    legend = c('1980', '2015'),
    pch = c(1, 16))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)

png(paste0(dst, "/", lbl, ".png"),
    width     = 1000,
    height    = 750,
    units     = "px",
    res       = 72,
    pointsize = 15)
pal   <- paletteer_c("ggthemes::Classic Area Red-Green", 400)
plot(delta, main = 'Change in Suitability and Weighted Centroid Locations',
     col  = pal)
points(bv$centroidLong[1], bv$centroidLat[1], pch = 1)
points(bv$centroidLong[7], bv$centroidLat[7], pch = 16)
legend(
    'bottomright',
    legend = c('1980', '2015'),
    pch = c(1, 16))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)
dev.off()


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: JLS
# Date: 2022.08.11
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


