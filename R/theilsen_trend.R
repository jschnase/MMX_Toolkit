# ==============================================================================
#
# theilsen_trend.R
# - finds Theil-Sen median slope estimator for times series predictions
#
# ==============================================================================


# set up the RStudio environment -----------------------------------------------

# rm(list = ls())
source("~/MMX_Toolkit/R/_config_functions.R")
read.config()
# show.config()

# install.packages("raster", dependencies = TRUE)
# install.packages("spatialEco", dependencies = TRUE)
# install.packages("terra", dependencies = TRUE)
# install.packages("paletteer", dependencies = TRUE)
# install.packages("colorRamps", dependencies = TRUE)
# install.packages("pals", dependencies = TRUE)
# install.packages("Hmisc", dependencies = TRUE)
# install.packages("plyr", dependencies = TRUE)
# install.packages("scales", dependencies = TRUE)

library(raster)
library(spatialEco)
library(terra)
library(paletteer)
library(colorRamps)
library(pals)
library(Hmisc)
library(plyr)
library(scales)


# initializations --------------------------------------------------------------

wd   <- MMX_EXPERIMENT_DIRECTORY
run  <- RUN_NAME
src  <- paste0(wd, "/", run, "/Trends/HSM/_Predictions")
dst  <- paste0(wd, "/", run, "/Trends/HSM/TheilSen")
lbl  <- paste0(SPECIES_NAME, "-HSM-TheilSen")
# dst <-"/Users/jschnase/Desktop"

sp_name     <- SPECIES_NAME
state_lines <- vect(STATE_LINES_RDS)

start_yr <- as.numeric(TEMPORAL_EXTENT_START_YR)
stop_yr  <- as.numeric(TEMPORAL_EXTENT_STOP_YR)
step     <- as.numeric(TEMPORAL_EXTENT_INTERVAL)

fn0  <- paste0(lbl, "-Results") # all results from raster.kendall call
fn1  <- paste0(lbl, "-Maps") # habitat suitability time series
fn2  <- paste0(lbl, "-Slope") # theil-sen median slope estimate
fn3  <- paste0(lbl, "-P-Values") # theil-sen p values
fn4  <- paste0(lbl, "-Z-Scores") # mann-kendall z score
fn5  <- paste0(lbl, "-Tau") # kendal tau statistic
fn6  <- paste0(lbl, "-Plots") # theil-sen summary plots
fn7  <- paste0(lbl, "-Stats") # theil-sen summary stats
fn8  <- paste0(lbl, "-RStudio-Image") # r image for the session


# main processing --------------------------------------------------------------

print(" "); print("Starting 06c_hsm_theilsen_trend.R ..."); print(" ")

# build hsm predictions raster stack
stack <- raster(); vars <- list()
vars   <- list.files(src, pattern = "*.asc")
for (i in 1:length(vars)){
    s <- raster(paste0(src, "/", vars[i]))
    plot(s, main=vars[i], zlim = c(0,1))
    crs(s) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    stack <- addLayer(stack,s)
}

# compute theil-sen slope
k <- raster.kendall(rast(stack),
                    tau = TRUE,
                    # intercept = TRUE,
                    p.value = TRUE,
                    z.value = TRUE,
                    confidence = TRUE
)

# view/save results from raster.kendall function call
plot(k)

png(paste0(dst, "/", fn0, ".png"),
    width     = 1000,
    height    = 750,
    units     = "px",
    res       = 72,
    pointsize = 15)
plot(k)
dev.off()


# HSM Time Series --------------------------------------------------------------
pal <- blue2green2red(400)
plot(stack,
     col  = pal,
     zlim = c(0,1))

png(paste0(dst, "/", fn1, ".png"),
    width     = 1000,
    height    = 750,
    units     = "px",
    res       = 72,
    pointsize = 15)
plot(stack,
     col  = pal,
     zlim = c(0,1))
dev.off()


# Theil-Sen median slope estimate ----------------------------------------------
b_min <- format(cellStats(raster(k$slope), stat="min",  rm.na=TRUE),digits=3, nsmall=1)
b_max <- format(cellStats(raster(k$slope), stat="max",  rm.na=TRUE),digits=3, nsmall=1)
b_avg <- format(cellStats(raster(k$slope), stat="mean", rm.na=TRUE),digits=3, nsmall=1)
lim   <- max(abs(as.numeric(b_min)), abs(as.numeric(b_max)))

tsb   <- raster(k$slope)

# reproject for use with our layers
state_lines <- project(state_lines, rast(tsb))

pal   <- paletteer_c("ggthemes::Classic Area Red-Green", 400)
plot(tsb,
     main = fn2,
     sub = paste0("Theil-Sen Slope Min / Avg / Max = ", b_min, " / ", b_avg, " / ", b_max),
     col  = pal,
     zlim = c(-lim, lim))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)

png(paste0(dst, "/", fn2, ".png"),
    width     = 1000,
    height    = 750,
    units     = "px",
    res       = 72,
    pointsize = 15)
plot(tsb,
     main = fn2,
     sub = paste0("TS Slope Min / Avg / Max = ", b_min, " / ", b_avg, " / ", b_max),
     col  = pal,
     zlim = c(-lim, lim))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)
dev.off()

# save .asc and .tif versions too
writeRaster(tsb,
            filename = paste0(dst, "/", fn2, ".asc"),
            format    = "ascii",
            overwrite = TRUE)

writeRaster(tsb,
            filename = paste0(dst, "/", fn2, ".tif"),
            format   = "GTiff",
            overwrite = TRUE)


# # Theil-Sen p values -----------------------------------------------------------
# p_min <- format(cellStats(raster(k$p.value), stat="min",  rm.na=TRUE),digits=3, nsmall=1)
# p_max <- format(cellStats(raster(k$p.value), stat="max",  rm.na=TRUE),digits=3, nsmall=1)
# p_avg <- format(cellStats(raster(k$p.value), stat="mean", rm.na=TRUE),digits=3, nsmall=1)
#
# tsp   <- raster(k$p.value)
#
# pal   <- paletteer::paletteer_c("ggthemes::Orange Light", n = 400, -1)
# breakpoints <- c(0.001, 0.05)
# colors <- c("white", "orange")
# plot(tsp,
#      main = fn3,
#      sub = paste0("Theil-Sen P Values Min / Avg / Max = ", p_min, " / ", p_avg, " / ", p_max),
#      col  = pal,
#      zlim = c(0.0, 1.0))
# minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
# plot(state_lines, add = TRUE)
# plot(k$p.value,breaks=breakpoints,col=colors, add = TRUE)
#
# png(paste0(dst, "/", fn3, ".png"),
#     width     = 1000,
#     height    = 750,
#     units     = "px",
#     res       = 72,
#     pointsize = 15)
# plot(tsp,
#      main = fn3,
#      sub = paste0("Theil-Sen P Values Min / Avg / Max = ", p_min, " / ", p_avg, " / ", p_max),
#      col  = pal,
#      zlim = c(0.0, 1.0))
# minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
# plot(state_lines, add = TRUE)
# plot(k$p.value,breaks=breakpoints,col=colors, add = TRUE)
# dev.off()
#
# # save .asc and .tif versions too
# writeRaster(tsp,
#             filename = paste0(dst, "/", fn3, ".asc"),
#             format    = "ascii",
#             overwrite = TRUE)
#
# writeRaster(tsp,
#             filename = paste0(dst, "/", fn3, ".tif"),
#             format   = "GTiff",
#             overwrite = TRUE)


# Mann-Kendall Z scores --------------------------------------------------------
z_min <- format(cellStats(raster(k$z.value), stat="min",  rm.na=TRUE),digits=3, nsmall=1)
z_max <- format(cellStats(raster(k$z.value), stat="max",  rm.na=TRUE),digits=3, nsmall=1)
z_avg <- format(cellStats(raster(k$z.value), stat="mean", rm.na=TRUE),digits=3, nsmall=1)

mkz   <- raster(k$z.value)

pal   <- paletteer_c("ggthemes::Classic Area Red-Green", 400)
plot(mkz,
     main = fn4,
     sub = paste0("Mann-Kendall Z Min / Avg / Max = ", z_min, " / ", z_avg, " / ", z_max),
     col  = pal,
     zlim = c(-3.0, 3.0))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)

png(paste0(dst, "/", fn4, ".png"),
    width     = 1000,
    height    = 750,
    units     = "px",
    res       = 72,
    pointsize = 15)
plot(mkz,
     main = fn4,
     sub = paste0("Mann-Kendall Z Min / Avg / Max = ", z_min, " / ", z_avg, " / ", z_max),
     col  = pal,
     zlim = c(-3.0, 3.0))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)
dev.off()

# save .asc and .tif versions too
writeRaster(mkz,
            filename = paste0(dst, "/", fn4, ".asc"),
            format    = "ascii",
            overwrite = TRUE)

writeRaster(mkz,
            filename = paste0(dst, "/", fn4, ".tif"),
            format   = "GTiff",
            overwrite = TRUE)


# # Kendal tau statistic ---------------------------------------------------------
# t_min <- format(cellStats(raster(k$tau), stat="min",  rm.na=TRUE),digits=3, nsmall=1)
# t_max <- format(cellStats(raster(k$tau), stat="max",  rm.na=TRUE),digits=3, nsmall=1)
# t_avg <- format(cellStats(raster(k$tau), stat="mean", rm.na=TRUE),digits=3, nsmall=1)
#
# mkt   <- raster(k$tau)
# 
# pal   <- paletteer_c("ggthemes::Classic Area Red-Green", 400)
# plot(mkt,
#      main = fn5,
#      sub = paste0("Kendall Tau Statistic Min / Avg / Max = ", t_min, " / ", t_avg, " / ", t_max),
#      col  = pal)
# minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
# plot(state_lines, add = TRUE)
#
# png(paste0(dst, "/", fn5, ".png"),
#     width     = 1000,
#     height    = 750,
#     units     = "px",
#     res       = 72,
#     pointsize = 15)
# plot(mkt,
#      main = fn5,
#      sub = paste0("Kendall Tau Statistic Min / Avg / Max = ", t_min, " / ", t_avg, " / ", t_max),
#      col  = pal)
# minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
# plot(state_lines, add = TRUE)
# dev.off()
#
# # save .asc and .tif versions too
# writeRaster(mkt,
#             filename = paste0(dst, "/", fn5, ".asc"),
#             format    = "ascii",
#             overwrite = TRUE)
#
# writeRaster(mkt,
#             filename  = paste0(dst, "/", fn5, ".tif"),
#             format    = "GTiff",
#             overwrite = TRUE)


# add Mann-Kendall Z score overlay to Theil-Sen slope estimate -----------------

# statistically-significant POSITIVE trends                      <==== (+) =====

# set z score thresholds, save pos/neg raster masks for future overlays ...
pos      <- (mkz >=  1.96)  # 95% confidence levels
pos_mask <- pos; pos_mask[pos_mask < 1] <- NA

neg      <- (mkz <= -1.96)  # 95% confidence levels
neg_mask <- neg; neg_mask[neg_mask < 1] <- NA

# save .asc and tif versions of Z pos/neg mask layers
writeRaster(pos, paste0(dst, "/", fn2, "-Z-Overlay-pos"), format="ascii", overwrite=TRUE)
writeRaster(neg, paste0(dst, "/", fn2, "-Z-Overlay-neg"), format="ascii", overwrite=TRUE)
writeRaster(pos, paste0(dst, "/", fn2, "-Z-Overlay-pos"), format="GTiff", overwrite=TRUE)
writeRaster(neg, paste0(dst, "/", fn2, "-Z-Overlay-neg"), format="GTiff", overwrite=TRUE)

# plot and write w/ states boundaries
pal     <- paletteer_c("ggthemes::Classic Area Red-Green", 400)
pal_pos <- c(rgb(0, 0, 0, max = 255, alpha = 0), rgb(74, 139, 27, max = 255, alpha = 100))
pal_neg <- c(rgb(0, 0, 0, max = 255, alpha = 0), rgb(209, 56, 32, max = 255, alpha = 100))

plot(tsb,
     main = paste0(fn2, " w/ Z Overlay"),
     col  = pal,
     zlim = c(-lim, lim))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)
plot(pos, col=pal_pos, add=TRUE, legend = FALSE)
plot(neg, col=pal_neg, add=TRUE, legend = FALSE)

png(paste0(dst, "/", fn2, "-Z-Overlay.png"),
    width     = 1000,
    height    = 750,
    units     = "px",
    res       = 72,
    pointsize = 15)
plot(tsb,
     main = paste0(fn2, " w/ Z Overlay"),
     col  = pal,
     zlim = c(-lim, lim))
minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
plot(state_lines, add = TRUE)
plot(pos, col=pal_pos, add=TRUE, legend = FALSE)
plot(neg, col=pal_neg, add=TRUE, legend = FALSE)
dev.off()

# prep results for stats file
stats_file <- paste0(dst, "/", fn7, ".txt")

min <- cellStats(raster::mask(tsb, pos_mask), stat="min",  rm.na=TRUE)
max <- cellStats(raster::mask(tsb, pos_mask), stat="max",  rm.na=TRUE)
avg <- cellStats(raster::mask(tsb, pos_mask), stat="mean",  rm.na=TRUE)
std <- cellStats(raster::mask(tsb, pos_mask), stat="sd",  rm.na=TRUE)
aoi <- expanse(rast(tsb), unit="km", transform=TRUE) # size of study area
km2 <- expanse(rast(pos_mask), unit="km", transform=TRUE) # area of ss pos change
pct <- (km2 / aoi) * 100 # percent study area w/ ss pos change

# statistically-insignificant positive trends
nss_pos      <- (mkz < 1.96) & (tsb > 0)
nss_pos_mask <- nss_pos; nss_pos_mask[nss_pos_mask < 1] <- NA

km2_nss_pos  <- expanse(rast(nss_pos_mask), unit="km", transform=TRUE) # area of nss neg change
pct_nss_pos  <- (km2_nss_pos / aoi) * 100

# format numbers for report
ul  <- paste0("(", SPATIAL_EXTENT_UL_LAT, ",", SPATIAL_EXTENT_UL_LON, ")")
lr  <- paste0("(", SPATIAL_EXTENT_LR_LAT, ",", SPATIAL_EXTENT_LR_LON, ")")
aoi <- format(round(as.numeric(aoi), 1), nsmall=1, big.mark=",")
km2 <- format(round(as.numeric(km2), 1), nsmall=1, big.mark=",")
pct <- format(round(as.numeric(pct), 1), nsmall=1, big.mark=",")
max <- format(round(as.numeric(max), 2), nsmall=2, big.mark=",")
min <- format(round(as.numeric(min), 2), nsmall=2, big.mark=",")
avg <- format(round(as.numeric(avg), 2), nsmall=2, big.mark=",")
std <- format(round(as.numeric(std), 2), nsmall=2, big.mark=",")
z_max <- format(round(as.numeric(z_max), 2), nsmall=2, big.mark=",")
km2_nss_pos <- format(round(as.numeric(km2_nss_pos), 1), nsmall=1, big.mark=",")
pct_nss_pos <- format(round(as.numeric(pct_nss_pos), 1), nsmall=1, big.mark=",")

write("------------------------------------------------------------", stats_file, append=TRUE, sep="\n")
write(paste0(sp_name, " - Study Area Theil-Sen Trend Analysis"), stats_file, append=TRUE, sep="\n")
write(paste0(EXPERIMENT_NAME, "/", RUN_NAME), stats_file, append=TRUE, sep="\n")
write("------------------------------------------------------------", stats_file, append=TRUE, sep="\n")
write(paste0("Study area coordinates UL = ", ul), stats_file, append=TRUE, sep="\n")
write(paste0("Study area coordinates LR = ", lr), stats_file, append=TRUE, sep="\n")
write(paste0("Study area = ", aoi, " km^2"), stats_file, append=TRUE, sep="\n")
write("------------------------------------------------------------", stats_file, append=TRUE, sep="\n")
write("Statistically-significant POSITIVE trend results:", stats_file, append=TRUE, sep="\n")
write(paste0("Positive trend area       = ", km2, " km^2"), stats_file, append=TRUE, sep="\n")
write(paste0("Positive trend percent    = ", pct, " % of the study area *"), stats_file, append=TRUE, sep="\n")
write(" ", stats_file, append=TRUE, sep="\n")

write("# Theil-Sen slope represents the rate of change in", stats_file, append=TRUE, sep="\n")
write("# projected probabilities of suitable habitat per", stats_file, append=TRUE, sep="\n")
write("# five-year interval of the time series:", stats_file, append=TRUE, sep="\n")

write(paste0("Theil-Sen slope avg  = ", avg, " %/5-yr interval *"), stats_file, append=TRUE, sep="\n")
write(paste0("Theil-Sen slope max  = ", max, " %/5-yr interval"), stats_file, append=TRUE, sep="\n")
write(paste0("Theil-Sen slope min  = ", min, " %/5-yr interval"), stats_file, append=TRUE, sep="\n")
write(paste0("Theil-Sen slope std  = ", std, " %/5-yr interval"), stats_file, append=TRUE, sep="\n")
write(paste0("Mann-Kendall Z score = ", z_max), stats_file, append=TRUE, sep="\n")
write(" ", stats_file, append=TRUE, sep="\n")

write("Statistically-insignificant positive trend results:", stats_file, append=TRUE, sep="\n")
write(paste0("Positive trend area       = ", km2_nss_pos, " km^2"), stats_file, append=TRUE, sep="\n")
write(paste0("Positive trend percent    = ", pct_nss_pos, " % of the study area"), stats_file, append=TRUE, sep="\n")


# statistically-significant NEGATIVE trend stats                 <==== (-) =====
min <- cellStats(raster::mask(tsb, neg_mask), stat="min",  rm.na=TRUE)
max <- cellStats(raster::mask(tsb, neg_mask), stat="max",  rm.na=TRUE)
avg <- cellStats(raster::mask(tsb, neg_mask), stat="mean",  rm.na=TRUE)
std <- cellStats(raster::mask(tsb, neg_mask), stat="sd",  rm.na=TRUE)
aoi <- expanse(rast(tsb), unit="km", transform=TRUE) # size of study area (recomputed to remove formatting)
km2 <- expanse(rast(neg_mask), unit="km", transform=TRUE) # area of ss pos change
pct <- (km2 / aoi) * 100 # percent study area w/ ss pos change

# statistically-insignificant negative trends
nss_neg      <- (mkz > -1.96) & (tsb < 0)
nss_neg_mask <- nss_neg; nss_neg_mask[nss_neg_mask < 1] <- NA

km2_nss_neg  <- expanse(rast(nss_neg_mask), unit="km", transform=TRUE) # area of nss neg change
pct_nss_neg  <- (km2_nss_neg / aoi) * 100

# format numbers for report
aoi <- format(round(as.numeric(aoi), 1), nsmall=1, big.mark=",")
km2 <- format(round(as.numeric(km2), 1), nsmall=1, big.mark=",")
pct <- format(round(as.numeric(pct), 1), nsmall=1, big.mark=",")
max <- format(round(as.numeric(max), 2), nsmall=2, big.mark=",")
min <- format(round(as.numeric(min), 2), nsmall=2, big.mark=",")
avg <- format(round(as.numeric(avg), 2), nsmall=2, big.mark=",")
std <- format(round(as.numeric(std), 2), nsmall=2, big.mark=",")
z_min <- format(round(as.numeric(z_min), 2), nsmall=2, big.mark=",")
km2_nss_neg <- format(round(as.numeric(km2_nss_neg), 1), nsmall=1, big.mark=",")
pct_nss_neg <- format(round(as.numeric(pct_nss_neg), 1), nsmall=1, big.mark=",")

write(" ", stats_file, append=TRUE, sep="\n")
write("------------------------------------------------------------", stats_file, append=TRUE, sep="\n")
write("Statistically-significant NEGATIVE trend results:", stats_file, append=TRUE, sep="\n")
write(paste0("Negative trend area       = ", km2, " km^2"), stats_file, append=TRUE, sep="\n")
write(paste0("Negative trend percent    = ", pct, " % of the study area *"), stats_file, append=TRUE, sep="\n")
write(" ", stats_file, append=TRUE, sep="\n")

write("# Theil-Sen slope represents the rate of change in", stats_file, append=TRUE, sep="\n")
write("# projected probabilities of suitable habitat per", stats_file, append=TRUE, sep="\n")
write("# five-year interval of the time series:", stats_file, append=TRUE, sep="\n")

write(paste0("Theil-Sen slope avg  = ", avg, " %/5-yr interval *"), stats_file, append=TRUE, sep="\n")
write(paste0("Theil-Sen slope max  = ", max, " %/5-yr interval"), stats_file, append=TRUE, sep="\n")
write(paste0("Theil-Sen slope min  = ", min, " %/5-yr interval"), stats_file, append=TRUE, sep="\n")
write(paste0("Theil-Sen slope std  = ", std), stats_file, append=TRUE, sep="\n")
write(paste0("Mann-Kendall Z score = ", z_min), stats_file, append=TRUE, sep="\n")
write(" ", stats_file, append=TRUE, sep="\n")

write("Statistically-insignificant negative trend results:", stats_file, append=TRUE, sep="\n")
write(paste0("Negative trend area       = ", km2_nss_neg, " km^2"), stats_file, append=TRUE, sep="\n")
write(paste0("Negative trend percent    = ", pct_nss_neg, " % of the study area"), stats_file, append=TRUE, sep="\n")
write(" ", stats_file, append=TRUE, sep="\n")
write("------------------------------------------------------------", stats_file, append=TRUE, sep="\n")


# save R image
save.image(paste0(dst, "/", fn8, ".RData"))

print(" "); print("Done ..."); print(" ")


# ------------------------------------------------------------------------------
# Copyright (C) 2018-2023 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration (NASA).
# All Rights Reserved.
#
# Author: John L. Schnase
# Revision Date: 2023.04.26
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
