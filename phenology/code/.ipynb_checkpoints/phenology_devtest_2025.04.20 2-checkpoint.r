# ===============================================================================================
# Phenology and Association paper devtest analysis code ...
# ===============================================================================================

rm(list = ls())

# load libraries
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rstanarm))
suppressPackageStartupMessages(library(bayestestR))
suppressPackageStartupMessages(library(paletteer))

# these libraries are needed only for the 3.0 Animations
suppressPackageStartupMessages(library(av))
suppressPackageStartupMessages(library(maps))
suppressPackageStartupMessages(library(gridExtra))

# these packages needed for bcr analyses
library(sf)
library(dplyr)
library(paletteer)

# set directory paths
ifn  <- "ebd_casspa_relApr-2024.csv"
# ifn  <- "ebd_casspa_smp_relMar-2025.csv"
idir <- "/Users/jschnase/Library/CloudStorage/Dropbox/MMX-Project/MMX-Papers/Paper\ 05\ -\ Phenology\ paper/_Version\ 05\ -\ Revised\ submission/_Notebooks"
odir <- "/Users/jschnase/Desktop/out"


get_records <- function() {

    # function reads a native ebird .csv download file, removes 
    # duplicate records, and converts the input into a dataframe ...
    
    f <- read.csv(paste0(idir, '/', ifn))
    f <- data.frame(f)
    f <- distinct(f, STATE, OBSERVATION.DATE, OBSERVATION.COUNT, 
                  LONGITUDE, LATITUDE, .keep_all=FALSE)
    f$OBSERVATION.COUNT[f$OBSERVATION.COUNT=="X"] <- 1
    
    return(f)
}

filter_range <- function(df, yr1, yr2) {

    # function to extract a range of records based on start year and end year
    # input: dataframe, start year, end year
    
    df <- df %>% filter(YEAR >= yr1 & YEAR <= yr2)
    
    return(df)
}

filter_span <- function(df, year, span) {

    # function to extract a span of records based on start year and interval span
    # input: dataframe, year, span length in years
    
    df <- df %>% filter(YEAR >= year & YEAR < year + span)
    
    return(df)
}

filter_state <- function(df, state) {

    # function to extract records based on state name
    # input: dataframe plus name of the state to extract

    df <- df %>% filter(STATE==state)
    
    return(df)
}

filter_lon <- function(df, lon) {                                               # <===== NEW
  df <- df %>% filter(LON==lon)
  return(df)
}

filter_bcr <- function(df, bcr) {                                               # <===== NEW
  df <- df %>% filter(BCR==bcr)
  return(df)
}

extract_dates <- function(df) { # 1985-2024 <== this is the default year range

    # function to parse the OBSERVATION.DATE field into months, years,
    # and day-of-year (yday) (NB we'll use get_records() followed by
    # extract_dates(x) to get a dataframe to use throughout the analysis.
    # in the rest of this notebook I refer to this as the "master df")
    
    df <- df %>% mutate(OBSERVATION.DATE=parse_date_time(df$OBSERVATION.DATE, 
                                                         orders="mdy"))
    df <- df %>% mutate(
        year=year(OBSERVATION.DATE),
        yday=yday(OBSERVATION.DATE),
        month=month(OBSERVATION.DATE, label=TRUE)
    )
    df <- select(df, STATE, DATE=OBSERVATION.DATE, MONTH=month, YEAR=year, YDAY=yday, 
                  COUNT=OBSERVATION.COUNT, LONGITUDE, LATITUDE)

    df <- filter_range(df, 1985, 2024)
    
    return(df)
}

extract_phenology <- function(df) { 

    # extracts phenological phases based on quantiles
    # as described in Lehikoinen et al. 2019
    
    q <- quantile(df$YDAY, probs=c(0.05, 0.50, 0.95))
    
    # extract start, median, end, and duration
    p <- c(q[1], q[2], q[3], q[3]-q[1])
    
    return(p)
}

plot_phenology <- function(df, start, median, end, title) {

    # function to create an occurrence density plot that
    # provides a visual display of breeding season phenology
    # input: a dataframe, start and end dates for the input df, 
    # and title for the plot ...
    #
    # this version DOES NOT lay down a yellow bar showing bbs survey days <==

    p <- ggplot(df, aes(x=YDAY, after_stat(scaled))) +
            geom_density(linewidth=0.50, color="black") +
            geom_vline(aes(xintercept=start),
                       color="blue", linetype="dashed", linewidth=0.50) +
            geom_vline(aes(xintercept=median),
                       color="blue", linetype="solid", linewidth=0.50) +
            geom_vline(aes(xintercept=end),
                       color="blue", linetype="dashed", linewidth=0.50) +
            ggtitle(title) + xlab("Day of Year") + ylab("Occurrence Density") +
            theme(text=element_text(size=15))

    return(p)
}

plot_phenology_bbs <- function(df, start, median, end, title) {

    # function to create an occurrence density plot that
    # provides a visual display of breeding season phenology
    # input: a dataframe, start, median, and end dates for the 
    # input df, and title for the plot ...
    #
    # this version lays down a yellow bar showing bbs survey days 152-166 <==

    p <- ggplot(df, aes(x=YDAY, after_stat(scaled))) +
            # this version lays down a yellow bar showing bbs survey days 152-166
            geom_vline(aes(xintercept=159), 
                        color="lightyellow", linetype="solid", linewidth=7) +
            geom_vline(aes(xintercept=start),
                       color="blue", linetype="dashed", linewidth=0.50) +
            geom_vline(aes(xintercept=median),
                       color="blue", linetype="solid", linewidth=0.50) +
            geom_vline(aes(xintercept=end),
                       color="blue", linetype="dashed", linewidth=0.50) +
            ggtitle(title) + xlab("Day of Year") + ylab("Occurrence Density") +
            geom_density(linewidth=0.50, color="black") + 
            theme(text=element_text(size=15))

    return(p)
}

plot_combined_phenology <- function() {

    p <- ggplot() +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=7) +
            geom_density(aes(YDAY, fill = "TX", after_stat(scaled)), alpha = .1, data = dftx) +
            geom_density(aes(YDAY, fill = "NM", after_stat(scaled)), alpha = .1, data = dfnm) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(scaled)), alpha = .1, data = dfaz) + 
            ggtitle("Southwestern Occurrence Densities 1900-2024") + xlab("Day of Year") + ylab("Occurrence Density") +
            scale_fill_manual(name = "States", values = c(TX = "red", NM = "blue", AZ = "green")) +
            theme(text=element_text(size=15))
    
    # save_ggp(p, "/Users/jschnase/Desktop/out", "phen_combo")

    return(p)
}

plot_combined_phenology_count_full_range <- function() {

    # all years -----
    p0 <- ggplot() + theme(text=element_text(size=20)) +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=7) +
            geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = .2, data = df) +
            geom_density(aes(YDAY, fill = "TX", after_stat(count)), alpha = .2, data = dftx) +
            geom_density(aes(YDAY, fill = "NM", after_stat(count)), alpha = .2, data = dfnm) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(count)), alpha = .2, data = dfaz) + 
            ggtitle("Occurrence Record Densities 1900-2024") + xlab("Day of Year") + ylab("Record Count") +
            # scale_fill_manual(name = "Region", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green")) +
            #
            geom_density(aes(YDAY, fill = "OK", after_stat(count)), alpha = .2, linetype="dashed", data = dfok) +
            geom_density(aes(YDAY, fill = "CO", after_stat(count)), alpha = .2, linetype="dashed", data = dfco) +
            geom_density(aes(YDAY, fill = "KS", after_stat(count)), alpha = .2, linetype="dashed", data = dfks) +
            geom_density(aes(YDAY, fill = "NE", after_stat(count)), alpha = .2, linetype="dashed", data = dfne) +
            scale_fill_manual(name = "CONUS", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green",
                                                         OK = "pink", CO = "lightblue", KS = "lightgreen", 
                                                         NE = "orange"))

    # 1900-1994 -----
    df1   <- filter_range(df, 1900, 1994)
    dftx1 <- filter_range(dftx, 1900, 1994)
    dfnm1 <- filter_range(dfnm, 1900, 1994)
    dfaz1 <- filter_range(dfaz, 1900, 1994)
    #
    dfok1 <- filter_range(dfok, 1900, 1994)
    dfco1 <- filter_range(dfco, 1900, 1994)
    dfks1 <- filter_range(dfks, 1900, 1994)
    dfne1 <- filter_range(dfne, 1900, 1994)

    p1 <- ggplot() + theme(text=element_text(size=20)) +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=7) +
            geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = .2, data = df1) +
            geom_density(aes(YDAY, fill = "TX", after_stat(count)), alpha = .2, data = dftx1) +
            geom_density(aes(YDAY, fill = "NM", after_stat(count)), alpha = .2, data = dfnm1) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(count)), alpha = .2, data = dfaz1) + 
            ggtitle("Occurrence Record Densities 1900-1994") + xlab("Day of Year") + ylab("Record Count") +
            # scale_fill_manual(name = "Region", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green"))
            #
            geom_density(aes(YDAY, fill = "OK", after_stat(count)), alpha = .2, linetype="dashed", data = dfok1) +
            geom_density(aes(YDAY, fill = "CO", after_stat(count)), alpha = .2, linetype="dashed", data = dfco1) +
            geom_density(aes(YDAY, fill = "KS", after_stat(count)), alpha = .2, linetype="dashed", data = dfks1) +
            geom_density(aes(YDAY, fill = "NE", after_stat(count)), alpha = .2, linetype="dashed", data = dfne1) +
            scale_fill_manual(name = "CONUS", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green",
                                                         OK = "pink", CO = "lightblue", KS = "lightgreen", 
                                                         NE = "orange"))
    
    # 2000-2020 -----
    df1   <- filter_range(df, 2000, 2024)
    dftx1 <- filter_range(dftx, 2000, 2024)
    dfnm1 <- filter_range(dfnm, 2000, 2024)
    dfaz1 <- filter_range(dfaz, 2000, 2024)
    #
    dfok1 <- filter_range(dfok, 2000, 2024)
    dfco1 <- filter_range(dfco, 2000, 2024)
    dfks1 <- filter_range(dfks, 2000, 2024)
    dfne1 <- filter_range(dfne, 2000, 2024)
    
    p2 <- ggplot() + theme(text=element_text(size=20)) +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=7) +
            geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = .2, data = df1) +
            geom_density(aes(YDAY, fill = "TX", after_stat(count)), alpha = .2, data = dftx1) +
            geom_density(aes(YDAY, fill = "NM", after_stat(count)), alpha = .2, data = dfnm1) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(count)), alpha = .2, data = dfaz1) + 
            ggtitle("Occurrence Record Densities 2020-2024") + xlab("Day of Year") + ylab("Record Count") +
            # scale_fill_manual(name = "Region", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green"))
            #
            geom_density(aes(YDAY, fill = "OK", after_stat(count)), alpha = .2, linetype="dashed", data = dfok1) +
            geom_density(aes(YDAY, fill = "CO", after_stat(count)), alpha = .2, linetype="dashed", data = dfco1) +
            geom_density(aes(YDAY, fill = "KS", after_stat(count)), alpha = .2, linetype="dashed", data = dfks1) +
            geom_density(aes(YDAY, fill = "NE", after_stat(count)), alpha = .2, linetype="dashed", data = dfne1) +
            scale_fill_manual(name = "CONUS", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green",
                                                         OK = "pink", CO = "lightblue", KS = "lightgreen", 
                                                         NE = "orange"))

    print(p0); print(p1); print(p2)
    
    # save_ggp(p0, "/Users/jschnase/Desktop/out", "phen_combo_count_1900-2024")
    # save_ggp(p1, "/Users/jschnase/Desktop/out", "phen_combo_count_1900-1984")
    # save_ggp(p2, "/Users/jschnase/Desktop/out", "phen_combo_count_2000-2024")

    return()
}

find_peak_doy <- function(df) {                                                 # <<<<<<<<< NEW
  
  # Count doy occurrences, find the top days
  top_categories <- df %>%
    count(YDAY, name = "count") %>%  # Count occurrences
    arrange(desc(count)) %>%  # Sort by count
    slice(1:3)  # Keep top 3
  
  peak <- round(mean(top_categories$YDAY))
  
  # print(top_categories)
  # print(peak)
  
  return(peak)
}

state_density_graphs <- function() {                                                # <<<<<<<<< NEW (Fig 1a)
  
  # creates state observation density graphs (fig 1a)

    # 1985-2024 -----
    df1   <- filter_range(df, 1985, 2024)
    dftx1 <- filter_range(dftx, 1985, 2024)
    dfnm1 <- filter_range(dfnm, 1985, 2024)
    dfco1 <- filter_range(dfco, 1985, 2024)
    dfaz1 <- filter_range(dfaz, 1985, 2024)
    dfne1 <- filter_range(dfne, 1985, 2024)
    dfks1 <- filter_range(dfks, 1985, 2024)
    dfok1 <- filter_range(dfok, 1985, 2024)
    dfwy1 <- filter_range(dfwy, 1985, 2024)
    minyr <- min(df1$YEAR); maxyr <- max(df1$YEAR)

    phen_all <- extract_phenology(df)
    start    <- round(phen_all[1], 0)
    median   <- round(phen_all[2], 0)
    end      <- round(phen_all[3], 0)
    duration <- round(phen_all[4], 0)

    p1 <- ggplot() + theme(text=element_text(size=20)) +
            theme_classic() +
            # color="darkorange" lines demarcate june bbs survey window
            # linewidth=25 is set for correct saved image, displayed image looks wacky ...
            # geom_vline(aes(xintercept=170), color="lightyellow", linetype="solid", alpha=0.75, linewidth=20) +
            # geom_vline(aes(xintercept=152), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
            # geom_vline(aes(xintercept=181), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
            #
            geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = 0.25, linewidth = 0.1, data = df1) +
            # geom_density(aes(YDAY, fill = "TX", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dftx1) +
            # geom_density(aes(YDAY, fill = "NM", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dfnm1) +
            # geom_density(aes(YDAY, fill = "AZ", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dfaz1) + 
            # geom_density(aes(YDAY, fill = "CO", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dfco1) +
            # geom_density(aes(YDAY, fill = "NE", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dfne1) +
            # geom_density(aes(YDAY, fill = "KS", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dfks1) +
            # geom_density(aes(YDAY, fill = "OK", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dfok1) +
            # geom_density(aes(YDAY, fill = "WY", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = dfwy1) +
            #
            geom_vline(aes(xintercept=152), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
            geom_vline(aes(xintercept=181), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
      
            # geom_vline(aes(xintercept=start),
            #            color="blue", linetype="dashed", linewidth=0.50) +
            # geom_vline(aes(xintercept=median),
            #            color="blue", linetype="solid", linewidth=0.50) +
            # geom_vline(aes(xintercept=end),
            #            color="blue", linetype="dashed", linewidth=0.50) +
            ggtitle("Occurrence Record Densities 1985-2024") + xlab("Day of Year") + ylab("Record Count") +
            scale_fill_manual(name = "  ", values = c(All = "lightgray", TX = "red", NM = "blue", CO = "yellow",
                                                      AZ = "green", NE = "orange", KS = "purple", OK = "darkred", 
                                                      WY = "pink"))

    # phen_all_plot <- plot_phenology_bbs(df, start, median, end,  
    #                                paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))

    print(p1)
    
    # save_ggp(p1, "/Users/jschnase/Desktop/out", "phen_combo_count_1985-2024")

    return()
}

state_density_plots <- fu
nction() {                                                # <<<<<<<<< NEW (Fig 1b)
  
  # plots state observations (fig 1b)
  
  # col <- colorRampPalette(c("lightgray", "gray", "black"))(400)
  col <- rev(paletteer_c("grDevices::Grays", 300))
  
  us_states <- map_data("state")
  selected_states <- c("texas", "new mexico", "arizona", "colorado", 
                       "oklahoma", "kansas", "nebraska", "wyoming",
                       "utah", "south dakota")
  
  us_states_filtered <- us_states[us_states$region %in% selected_states, ]
  tx <- us_states[us_states$region=="texas", ]
  nm <- us_states[us_states$region=="new mexico", ]
  co <- us_states[us_states$region=="colorado", ]
  az <- us_states[us_states$region=="arizona", ]
  
  Longitude <- df$LONGITUDE
  Latitude  <- df$LATITUDE
  DOY       <- df$YDAY
  
  # # median doy
  # tx_doy <- data.frame(lon = mean(df$LONGITUDE[df$YDAY==129]),
  #                      lat = mean(df$LATITUDE[df$YDAY==129]))
  # nm_doy <- data.frame(lon = mean(df$LONGITUDE[df$YDAY==165]),
  #                      lat = mean(df$LATITUDE[df$YDAY==165]))
  # co_doy <- data.frame(lon = mean(df$LONGITUDE[df$YDAY==160]),
  #                      lat = mean(df$LATITUDE[df$YDAY==160]))
  # az_doy <- data.frame(lon = mean(df$LONGITUDE[df$YDAY==214]),
  #                      lat = mean(df$LATITUDE[df$YDAY==214]))
  
  # peak doy
  tx_doy <- data.frame(lon = mean(dftx$LONGITUDE[dftx$YDAY==find_peak_doy(dftx)]),
                       lat = mean(dftx$LATITUDE[dftx$YDAY==find_peak_doy(dftx)]))
  nm_doy <- data.frame(lon = mean(dfnm$LONGITUDE[dfnm$YDAY==find_peak_doy(dfnm)]),
                       lat = mean(dfnm$LATITUDE[dfnm$YDAY==find_peak_doy(dfnm)]))
  co_doy <- data.frame(lon = mean(dfco$LONGITUDE[dfco$YDAY==find_peak_doy(dfco)]),
                       lat = mean(dfco$LATITUDE[dfco$YDAY==find_peak_doy(dfco)]))
  az_doy <- data.frame(lon = mean(dfaz$LONGITUDE[dfaz$YDAY==find_peak_doy(dfaz)]),
                       lat = mean(dfaz$LATITUDE[dfaz$YDAY==find_peak_doy(dfaz)]))
  
  mult <- 75  # multiplier to increase size/visibility of colored circles
  tx_cnt <- round(mult*(nrow(dftx)/nrow(df)))
  nm_cnt <- round(mult*(nrow(dfnm)/nrow(df)))
  co_cnt <- round(mult*(nrow(dfco)/nrow(df)))
  az_cnt <- round(mult*(nrow(dfaz)/nrow(df)))
  
  
  # create the map
  ggplot(df, aes(x = Longitude, y = Latitude, color = DOY)) +
    geom_point(alpha = 0.5, size = 0.01) +
    # ggplot(df, aes(x = Longitude, y = Latitude)) +
    #   geom_point(color = "gray", alpha = 0.5, size = 0.1) +
    scale_color_gradientn(colors = col) +
    geom_polygon(data = us_states_filtered, aes(x = long, y = lat, group = group),
                 fill = NA, color = "darkgray", linewidth = 0.25) +  
    
    # # states with different colors
    # geom_polygon(data = tx, aes(x = long, y = lat, group = group),
    #              fill = NA, alpha = 0.25, color = "red", linewidth = 0.25) + 
    # geom_polygon(data = nm, aes(x = long, y = lat, group = group),
    #              fill = NA, alpha = 0.25, color = "blue", linewidth = 0.25) + 
    # geom_polygon(data = co, aes(x = long, y = lat, group = group),
    #              fill = NA, alpha = 0.25, color = "yellow", linewidth = 0.25) +
    # geom_polygon(data = az, aes(x = long, y = lat, group = group),
    #            fill = NA, alpha = 0.25, color = "green", linewidth = 0.25) +
    
    # tx ---
    geom_point(data = tx_doy, aes(x = lon, y = lat),  # tx center point
               pch = 21, color = "darkred", fill = "darkred", size = 1.50, alpha = 0.75) +
    geom_point(data = tx_doy, aes(x = lon, y = lat),  # tx circle                             
               pch = 21, color = "darkgray", fill = "red", size = tx_cnt, alpha = 0.30) +
    # nm ---
    geom_point(data = nm_doy, aes(x = lon, y = lat),  # nm center point
               pch = 21, color = "darkblue", fill = "darkblue", size = 1.50, alpha = 0.75) +
    geom_point(data = nm_doy, aes(x = lon, y = lat),  # nm circle
               pch = 21, color = "darkgray", fill = "blue", size = nm_cnt, alpha = 0.30) +
    # co ---
    geom_point(data = co_doy, aes(x = lon, y = lat),  # co center point
               pch = 21, color = "orange", fill = "orange", size = 1.50, alpha = 0.75) +
    geom_point(data = co_doy, aes(x = lon, y = lat),  # co circle
               pch = 21, color = "darkgray", fill = "yellow", size = co_cnt, alpha = 0.40) +
    # az ---
    geom_point(data = az_doy, aes(x = lon, y = lat),  # az center point
               pch = 21, color = "darkgreen", fill = "darkgreen", size = 1.50, alpha = 0.75) +
    geom_point(data = az_doy, aes(x = lon, y = lat),  # az circle
               pch = 21, color = "darkgray", fill = "green", size = az_cnt, alpha = 0.30) +
    
    xlim(-119, -88) + ylim(25, 47) +
    coord_fixed(1.3) +  # Maintain aspect ratio
    theme_classic()
}

longitude_density_graphs <- function() {                                        # <<<<<<<<< NEW (Fig 2a)
  
  # creates observation density graphs based on longitude ranges (fig 2a)
  
  df100 <- filter_lon(dfx, -100)
  df105 <- filter_lon(dfx, -105)
  df110 <- filter_lon(dfx, -110)
  df115 <- filter_lon(dfx, -115)
  
  df1   <- filter_range(df, 1985, 2024)
  df1001 <- filter_range(df100, 1985, 2024)
  df1051 <- filter_range(df105, 1985, 2024)
  df1101 <- filter_range(df110, 1985, 2024)
  df1151 <- filter_range(df115, 1985, 2024)
  minyr <- min(df1$YEAR); maxyr <- max(df1$YEAR)
  
  phen_all <- extract_phenology(df)
  start    <- round(phen_all[1], 0)
  median   <- round(phen_all[2], 0)
  end      <- round(phen_all[3], 0)
  duration <- round(phen_all[4], 0)
  
  p1 <- ggplot() + theme(text=element_text(size=20)) +
    theme_classic() +
    # color="darkorange" lines demarcate june bbs survey window
    # linewidth=25 is set for correct saved image, displayed image looks wacky ...
    # geom_vline(aes(xintercept=170), color="lightyellow", linetype="solid", alpha=0.75, linewidth=20) +
    # geom_vline(aes(xintercept=152), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    # geom_vline(aes(xintercept=181), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    #
    geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = 0.25, linewidth = 0.1, data = df1) +
    # geom_density(aes(YDAY, fill = "LON-115", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df1151) +
    # geom_density(aes(YDAY, fill = "LON-110", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df1101) +
    # geom_density(aes(YDAY, fill = "LON-105", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df1051) + 
    # geom_density(aes(YDAY, fill = "LON-100", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df1001) +
    #
    geom_vline(aes(xintercept=152), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    geom_vline(aes(xintercept=181), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    
    # geom_vline(aes(xintercept=start),
    #            color="blue", linetype="dashed", linewidth=0.50) +
    # geom_vline(aes(xintercept=median),
    #            color="blue", linetype="solid", linewidth=0.50) +
    # geom_vline(aes(xintercept=end),
    #            color="blue", linetype="dashed", linewidth=0.50) +
    ggtitle("Occurrence Record Densities 1985-2024") + xlab("Day of Year") + ylab("Record Count") +
    scale_fill_manual(name = "  ", values = c(All = "lightgray", "LON-100" = "red", "LON-105" = "blue", 
                                              "LON-115" = "green", "LON-110" = "yellow"))
  
  # phen_all_plot <- plot_phenology_bbs(df, start, median, end,  
  #                                     paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))
  
  print(p1)
  
  # save_ggp(p1, "/Users/jschnase/Desktop/out", "phen_combo_count_1985-2024")
  
  return()
}

bcr_density_graphs <- function() {                                                # <<<<<<<<< NEW (Fig 3a)
  
  # creates observation density graphs based on bird 
  # conservation regions (fig 3a)
  
  df16 <- filter_bcr(dfx, "BCR16")
  df18 <- filter_bcr(dfx, "BCR18")
  df19 <- filter_bcr(dfx, "BCR19")
  df20 <- filter_bcr(dfx, "BCR20")
  df21 <- filter_bcr(dfx, "BCR21")
  df34 <- filter_bcr(dfx, "BCR34")
  df35 <- filter_bcr(dfx, "BCR35")
  df37 <- filter_bcr(dfx, "BCR37")
  
  df1   <- filter_range(df, 1985, 2024)
  df161 <- filter_range(df16, 1985, 2024)
  df181 <- filter_range(df18, 1985, 2024)
  df191 <- filter_range(df19, 1985, 2024)
  df201 <- filter_range(df20, 1985, 2024)
  df211 <- filter_range(df21, 1985, 2024)
  df341 <- filter_range(df34, 1985, 2024)
  df351 <- filter_range(df35, 1985, 2024)
  df371 <- filter_range(df37, 1985, 2024)
  minyr <- min(df1$YEAR); maxyr <- max(df1$YEAR)
  
  phen_all <- extract_phenology(df)
  start    <- round(phen_all[1], 0)
  median   <- round(phen_all[2], 0)
  end      <- round(phen_all[3], 0)
  duration <- round(phen_all[4], 0)
  
  p1 <- ggplot() + theme(text=element_text(size=20)) +
    theme_classic() +
    # color="darkorange" lines demarcate june bbs survey window
    # linewidth=25 is set for correct saved image, displayed image looks wacky ...
    # geom_vline(aes(xintercept=170), color="lightyellow", linetype="solid", alpha=0.75, linewidth=20) +
    # geom_vline(aes(xintercept=152), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    # geom_vline(aes(xintercept=181), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    #
    geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = 0.25, linewidth = 0.1, data = df1) +
    # geom_density(aes(YDAY, fill = "BCR16", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df161) +
    # geom_density(aes(YDAY, fill = "BCR18", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df181) +
    # geom_density(aes(YDAY, fill = "BCR19", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df191) + 
    # geom_density(aes(YDAY, fill = "BCR20", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df201) +
    # geom_density(aes(YDAY, fill = "BCR21", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df211) +
    # geom_density(aes(YDAY, fill = "BCR34", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df341) +
    # geom_density(aes(YDAY, fill = "BCR35", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df351) +
    # geom_density(aes(YDAY, fill = "BCR37", after_stat(count)),  alpha = 0.30, linewidth = 0.1, data = df371) +
    #
    geom_vline(aes(xintercept=152), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    geom_vline(aes(xintercept=181), color="darkgray", linetype="dashed", alpha = 1.0, linewidth=0.6) +
    
    # geom_vline(aes(xintercept=start),
    #            color="blue", linetype="dashed", linewidth=0.50) +
    # geom_vline(aes(xintercept=median),
    #            color="blue", linetype="solid", linewidth=0.50) +
    # geom_vline(aes(xintercept=end),
    #            color="blue", linetype="dashed", linewidth=0.50) +
    ggtitle("Occurrence Record Densities 1985-2024") + xlab("Day of Year") + ylab("Record Count") +
    scale_fill_manual(name = "  ", values = c(All = "lightgray", "BCR16" = "red", "BCR18" = "blue", 
                                              "BCR19" = "green", "BCR20" = "yellow", "BCR21" = "orange",
                                              "BCR34" = "purple", "BCR35" = "darkred", "BCR37" = "pink"))
  
  # phen_all_plot <- plot_phenology_bbs(df, start, median, end,  
  #                                     paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))
  
  print(p1)
  
  # save_ggp(p1, "/Users/jschnase/Desktop/out", "phen_combo_count_1985-2024")
  
  return()
}

plot_combined_phenology_scaled <- function() {

    # all years -----
    p0 <- ggplot() +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=7) +
            geom_density(aes(YDAY, fill = "All", after_stat(scaled)), alpha = .2, data = df) +
            geom_density(aes(YDAY, fill = "TX", after_stat(scaled)), alpha = .2, data = dftx) +
            geom_density(aes(YDAY, fill = "NM", after_stat(scaled)), alpha = .2, data = dfnm) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(scaled)), alpha = .2, data = dfaz) + 
            ggtitle("Occurrence Record Densities 1900-2024") + xlab("Day of Year") + ylab("Record Count Proportion") +
            scale_fill_manual(name = "Region", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green")) +
            theme(text=element_text(size=20))

    # 1900-1994 -----
    df1   <- filter_range(df, 1900, 1994)
    dftx1 <- filter_range(dftx, 1900, 1994)
    dfnm1 <- filter_range(dfnm, 1900, 1994)
    dfaz1 <- filter_range(dfaz, 1900, 1994)

    p1 <- ggplot() +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=7) +
            geom_density(aes(YDAY, fill = "All", after_stat(scaled)), alpha = .2, data = df1) +
            geom_density(aes(YDAY, fill = "TX", after_stat(scaled)), alpha = .2, data = dftx1) +
            geom_density(aes(YDAY, fill = "NM", after_stat(scaled)), alpha = .2, data = dfnm1) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(scaled)), alpha = .2, data = dfaz1) + 
            ggtitle("Occurrence Record Densities 1900-1994") + xlab("Day of Year") + ylab("Record Count Proportion") +
            scale_fill_manual(name = "Region", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green")) +
            theme(text=element_text(size=20))
    
    # 2000-2020 -----
    df1   <- filter_range(dftx, 2000, 2024)
    dftx1 <- filter_range(dftx, 2000, 2024)
    dfnm1 <- filter_range(dfnm, 2000, 2024)
    dfaz1 <- filter_range(dfaz, 2000, 2024)
    
    p2 <- ggplot() +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=7) +
            geom_density(aes(YDAY, fill = "All", after_stat(scaled)), alpha = .2, data = df1) +
            geom_density(aes(YDAY, fill = "TX", after_stat(scaled)), alpha = .2, data = dftx1) +
            geom_density(aes(YDAY, fill = "NM", after_stat(scaled)), alpha = .2, data = dfnm1) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(scaled)), alpha = .2, data = dfaz1) + 
            ggtitle("Occurrence Record Densities 2020-2024") + xlab("Day of Year") + ylab("Record Count Proportion") +
            scale_fill_manual(name = "Region", values = c(All = "gray", TX = "red", NM = "blue", AZ = "green")) +
            theme(text=element_text(size=20))

    print(p0); print(p1); print(p2)
    
    # save_ggp(p0, "/Users/jschnase/Desktop/out", "phen_combo_scaled_1900-2024")
    # save_ggp(p1, "/Users/jschnase/Desktop/out", "phen_combo_scaled_1900-1984")
    # save_ggp(p2, "/Users/jschnase/Desktop/out", "phen_combo_scaled_2000-2024")

    return()
}

save_ggp <- function(ggp, dst, fn) {

    # function saves a ggplot object using using an input
    # path and file name ...
    
    out <- paste0(dst, "/", fn, ".png")
    png(out,
        width     = 1000,
        height    = 750,
        units     = "px",
        res       = 72,
        pointsize = 15)
    print(ggp)
    dev.off()
    
}

phen_summary <- function() {

    # function to create a summary of phenological metrics over the
    # entire eBird occurrence record collection (all); just the southwestern
    # states of sw, nm, and az (sw); and for each state (sw, nm, az)
    
    # NB function operates on the global dataframe, default is to bin results
    # into 5-year spans ...

    states <- c("Texas", "New Mexico", "Colorado", "Arizona")
    
    # choose one of the following sets ...
    
    # ---
    # years <- c(1980, 1982, 1984, 1986, 1988, 
    #            1990, 1992, 1994, 1996, 1998,
    #            2000, 2002, 2004, 2006, 2008, 
    #            2010, 2012, 2014, 2016, 2018,
    #            2020, 2022)
    # span <- 2

    # ---
    # years <- c(1980, 1983, 1986, 1989, 1992, 1995, 1998, 
    #            2001, 2004, 2007, 2010, 2013, 2016, 2019, 
    #            2021)
    # span <- 3
    
    # ---
    # years <- c(1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020)
    years <- c(1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020)
    span <- 5

    # ---
    # years <- c(1900, 1905, 1910, 1915, 1920, 1925, 1930, 1935, 1940, 1945,
    #            1950, 1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 
    #            2000, 2005, 2010, 2015, 2020)
    # span <- 5
    
    # ---
    # years <- c(1980, 1990, 2000, 2010, 2020)
    # span <- 10

    # ---
    # years <- c(1900, 1910, 1920, 1930, 1940, 1950, 1960, 
    #            1970, 1980, 1990, 2000, 2010, 2020)
    # years <- c(1960, 1970, 1980, 1990, 2000, 2010, 2020)
    # span <- 10

    phen_summary <- data.frame()
    
    # do for all
    for (y in years){
        f <- filter_span(df, y, span)
        n <- nrow(f)
        phen_stats <- round(extract_phenology(f), 0)
        phen_stats <- c(phen_stats, y, "All", n)
        phen_summary <- rbind(phen_summary, phen_stats)
    }
    
    # do for sw = sw, nm, co, az
    for (y in years){
        sp <- filter_span(df, y, span)
        sw <- filter_state(sp, "Texas")
        nm <- filter_state(sp, "New Mexico")
        co <- filter_state(sp, "Colorado")
        az <- filter_state(sp, "Arizona")
        f  <- rbind(sw, nm, co, az)
        n  <- nrow(f)
        phen_stats   <- round(extract_phenology(f), 0)
        phen_stats   <- c(phen_stats, y, "Southwest", n)
        phen_summary <- rbind(phen_summary, phen_stats)
    }

    # do for nmco = nm + co
    for (y in years){
        sp <- filter_span(df, y, span)
        nm <- filter_state(sp, "New Mexico")
        co <- filter_state(sp, "Colorado")
        f  <- rbind(nm, co)
        n  <- nrow(f)
        phen_stats   <- round(extract_phenology(f), 0)
        phen_stats   <- c(phen_stats, y, "NMCO", n)
        phen_summary <- rbind(phen_summary, phen_stats)
    }
    
    # do for each state
    for (s in states) {
        # print(s)
        for (y in years) {
            f <- filter_span(filter_state(df, s), y, span)
            n <- nrow(f)
            phen_stats   <- round(extract_phenology(f), 0)
            phen_stats   <- c(phen_stats, y, s, n)
            phen_summary <- rbind(phen_summary, phen_stats)
        }
    }
    
    colnames(phen_summary) <- c("start", "median", "end", "duration", "year", "state", "count")
    
    return(phen_summary)
}

plot_trend_lr <- function(summary, region, metric) {

    # function to regress the start, median, and end metrics
    # over time for a given region using simple linear regression
    # input: summary df for entire study [created by phen-summary()],
    # and region and metric for the plot ...
    
    title  <- paste0("CASP Breeding season *", metric, "* trend across ", region)
    f      <- select(filter(summary, state==region), year, all_of(metric))
    fit   <<- lm(as.numeric(f[,2]) ~ as.numeric(f[,1]), f)
    x      <- round(fit$coefficients[2], 2)
    c      <- round(fit$coefficients[1], 0)
    r       <- round(summary(fit)$r.squared, 2)
    formula <- paste0("y = ", x,"x + ", c, "  (R^2 = ", r, ")      ")

    yr0 <- as.numeric(min(summary$year))
    yr1 <- as.numeric(max(summary$year)) + 4
    
    yintyr0 <- round((yr0 * fit$coefficients[2] + fit$coefficients[1]), 0)
    yintyr1 <- round((yr1 * fit$coefficients[2] + fit$coefficients[1]), 0)
    diff    <- yintyr0 - yintyr1
    lbl_e   <- paste0(yr0, " = d", yintyr0, " / ", yr1, " = d", yintyr1, " / Diff = ", abs(diff), "d earlier    ")
    lbl_l   <- paste0(yr0, " = d", yintyr0, " / ", yr1, " = d", yintyr1, " / Diff = ", abs(diff), "d later    ")
    if (diff >= 0) {
        lbl <- lbl_e
        } else {
        lbl <- lbl_l
        }
    
    p <- ggplot(f, aes(x=as.numeric(f[,1]), y=as.numeric(f[,2]))) +
         geom_point(size=2.0) +
         annotate("text", x=Inf, y=Inf, vjust=2, hjust=1, label=lbl, size=6) +
         annotate("text", x=Inf, y=Inf, vjust=5, hjust=1, label=formula, size=5, col="blue", fontface="italic") +
         geom_smooth(method='lm', se=TRUE, color='blue', linewidth=0.3, formula=y~x) +
         theme(text=element_text(size=15)) +
         labs(title=title, 
              y="Day of Year",
              x="5-Year Interval")
    p
    return(p)
}

plot_trend_lr_duration <- function(summary, region, metric) {

    # function to regress the trend of breeding season duration
    # over time for a given region using classig linear regression
    # input: summary df for entire study [created by phen-summary()],
    # and region and metric for the plot ...
    
    title   <- paste0("CASP Breeding season *", metric, "* trend across ", region)
    f       <- select(filter(summary, state==region), year, all_of(metric))
    fit    <<- lm(as.numeric(f[,2]) ~ as.numeric(f[,1]), f)
    x       <- round(fit$coefficients[2], 2)
    c       <- round(fit$coefficients[1], 0)
    r       <- round(summary(fit)$r.squared, 2)
    formula <- paste0("y = ", x,"x + ", c, "  (R^2 = ", r, ")      ")
    
    yint1980 <- round((1980 * fit$coefficients[2] + fit$coefficients[1]), 0)
    yint2020 <- round((2020 * fit$coefficients[2] + fit$coefficients[1]), 0)
    diff <- yint1980 - yint2020
    lbl_l <- paste0("1980 = d", yint1980, " / 2020 = d", yint2020, " / Diff = ", abs(diff), "d longer    ")
    lbl_s <- paste0("1980 = d", yint1980, " / 2020 = d", yint2020, " / Diff = ", abs(diff), "d shorter    ")
    if (diff <= 0) {
        lbl <- lbl_l
        } else {
        lbl <- lbl_s
        }
    
    p <- ggplot(f, aes(x=as.numeric(f[,1]), y=as.numeric(f[,2]))) +
         geom_point(size=2.0) +
         annotate("text", x=Inf, y=Inf, vjust=2, hjust=1, label=lbl, size=6) +
         annotate("text", x=Inf, y=Inf, vjust=5, hjust=1, label=formula, size=5, col="blue", fontface="italic") +
         geom_smooth(method='lm', se=TRUE, color='blue', linewidth=0.3, formula=y~x) +
         theme(text=element_text(size=15)) +
         labs(title=title, 
              y="Breeding Season Length (days)",
              x="5-Year Interval")
    p 
    return(p)
}

plot_trend_br <- function(summary, region, metric) {

    # function to regress the start, median, and end metrics
    # over time for a given region using baysean linear regression
    # input: summary df for entire study [created by phen-summary()],
    # and region and metric for the plot ...
    # - https://easystats.github.io/bayestestR/)\
    # - https://mc-stan.org/rstanarm/reference/stan_glm.html

    # ==========
    # internal function to compute Bayes R^2 
    # Gelman, Andrew, Ben Goodrich, Jonah Gabry, and Aki Vehtari. 2019. “R-Squared 
    # for Bayesian Regression Models.” The American Statistician 73 (3): 307–9.
    # https://doi.org/10.1080/00031305.2018.1549100.
    
    bayes_R2 <- function(fit) {
        y_pred  <- rstanarm::posterior_linpred(fit)
        var_fit <- apply(y_pred, 1, var)
        var_res <- as.matrix(fit, pars = c('sigma'))^2
        var_fit / (var_fit + var_res)
    }
    # ==========

    
    title <- paste0("CASP Breeding season *", metric, "* trend across ", region)
    f  <- select(filter(summary, state==region), year, all_of(metric))
    
    m <<- stan_glm(as.numeric(f[,2]) ~ as.numeric(f[,1]), data=f, seed=111, keep_every=2,
                   # prior=NULL, prior_intercept=NULL,
                   refresh=0, chains=3, iter=100000, warmup=10000)
    p <<- describe_posterior(m)
    r <<- round(mean(bayes_R2(m), 2), 2)
    g  <- ggplot(f, aes(x=as.numeric(f[,1]), y=as.numeric(f[,2]))) + 
                 geom_point(size=2.0) +
                 geom_smooth(method='lm', se=TRUE, color='blue', linewidth=0.3, formula=y~x) +
                 theme(text=element_text(size=15)) +
                 labs(title=title, y="Day of Year", x="5-Year Interval")

    print(" "); print("---------------------------------------------------------------------------------------------------------")
    print(paste0("Breeding season ", metric, " trend for ", region))
    print(p); print(paste0("Bayes R^2 = ", r))

    return(g)


}

plot_trend_br_duration <- function(summary, region, metric) {

    # function to regress the trend of breeding season duration
    # over time for a given region using baysean linear regression
    # input: summary df for entire study [created by phen-summary()],
    # and region and metric for the plot ...

    # ==========
    # internal function to compute Bayes R^2 
    # Gelman, Andrew, Ben Goodrich, Jonah Gabry, and Aki Vehtari. 2019. “R-Squared 
    # for Bayesian Regression Models.” The American Statistician 73 (3): 307–9.
    # https://doi.org/10.1080/00031305.2018.1549100.
    
    bayes_R2 <- function(fit) {
        y_pred <- rstanarm::posterior_linpred(fit)
        var_fit <- apply(y_pred, 1, var)
        var_res <- as.matrix(fit, pars = c('sigma'))^2
        var_fit / (var_fit + var_res)
    }
    # ==========

    
    title <- paste0("CASP Breeding season *", metric, "* trend across ", region)
    f  <- select(filter(summary, state==region), year, all_of(metric))
    
    m <<- stan_glm(as.numeric(f[,2]) ~ as.numeric(f[,1]), data=f, seed=111, keep_every=2,
                   # prior=NULL, prior_intercept=NULL,
                   refresh=0, chains=3, iter=100000, warmup=10000)
    p <<- describe_posterior(m)
    r <<- round(mean(bayes_R2(m), 2), 2)
    g <<- ggplot(f, aes(x=as.numeric(f[,1]), y=as.numeric(f[,2]))) +
                 geom_point(size=2.0) +
                 geom_smooth(method='lm', se=TRUE, color='blue', linewidth=0.3, formula=y~x) +
                 theme(text=element_text(size=15)) +
                 labs(title=title, y="Breeding Season Length (days)", x="5-Year Interval")

    print(" "); print("---------------------------------------------------------------------------------------------------------")
    print(paste0("Breeding season ", metric, " trend for ", region))
    print(p); print(paste0("Bayes R^2 = ", r))

    return(g)

}

extend_df <- function() {                                                       # <<<<<<<<< NEW
  
  # extends base df with longitudinal (lon) amd bird conservation
  # region (bcr) stratifications
  
  # add bird conservation regions
  bcrs <- c("BCR16", "BCR18", "BCR19", "BCR20", "BCR21", "BCR34", "BCR35", "BCR37")
  bcr_dir <- "/Users/jschnase/Library/CloudStorage/Dropbox/MMX-Project/MMX-Papers/Paper\ 05\ -\ Phenology\ paper/_Version\ 05\ -\ Revised\ submission/BCR/shapefiles/"
  df_sf <- st_as_sf(df, coords = c("LONGITUDE", "LATITUDE"), crs = 4326)  # WGS84
  
  dfx <- data.frame()
  # region <- "BCR16" # for testing
  for (region in bcrs) {
    bcr <- st_read(paste0(bcr_dir, region, ".shp"), quiet = TRUE)
    bcr <- st_transform(bcr, st_crs(df_sf))
    tmp <- df_sf[st_within(df_sf, bcr, sparse = FALSE), ]
    tmp$BCR <- region
    tmp <- tmp %>%
      mutate(
        LONGITUDE = st_coordinates(.)[, 1],
        LATITUDE = st_coordinates(.)[, 2]
      ) %>%
      st_drop_geometry()
    dfx <- rbind(dfx, tmp)
    
  }
  
  # add longitude categories
  dfx$LON
  dfx$LON[ dfx$LONGITUDE >= -100 ] <- -100
  dfx$LON[ dfx$LONGITUDE >= -105 & dfx$LONGITUDE < -100 ] <- -105
  dfx$LON[ dfx$LONGITUDE >= -110 & dfx$LONGITUDE < -105 ] <- -110
  dfx$LON[ dfx$LONGITUDE >= -115 & dfx$LONGITUDE < -110 ] <- -115
  
  dfx <- dfx[ , c("STATE", "DATE", "MONTH", "YEAR", "YDAY", "COUNT", 
                  "BCR", "LON", "LONGITUDE", "LATITUDE")]

  return(dfx)
  
}


# ============================================================================== MAIN <==========

# create state-based dfs 
recs <- get_records()
df   <- extract_dates(recs)
dfx  <- extend_df()

# save the df                                                                   # <===== NEW
# write.csv(df, "/Users/jschnase/Desktop/df.csv", row.names = FALSE)
# write.csv(dfx, "/Users/jschnase/Desktop/dfx.csv", row.names = FALSE)

# create dataframes for states and state groups ++++++++++++++++++++++++++++++++
# - these eight states are the only conus states for casp

dftx <- filter_state(df, "Texas")
dfnm <- filter_state(df, "New Mexico")
dfco <- filter_state(df, "Colorado")
dfaz <- filter_state(df, "Arizona")
#
dfok <- filter_state(df, "Oklahoma")
dfks <- filter_state(df, "Kansas")
dfne <- filter_state(df, "Nebraska")
dfwy <- filter_state(df, "Wyoming")
#
dfsw <- data.frame()  # southwest region consisting of tx, nm, co, az
dfsw <- rbind(dfsw, dftx, dfnm, dfco, dfaz)
dfxm <- data.frame()  # southwest region consisting of tx, nm
dfxm <- rbind(dfxm, dftx, dfnm)
#
dfus <- rbind(dftx, dfnm, dfco, dfaz, dfok, dfks, dfne, dfwy)

# show the record counts for each of the above
nrow(df); nrow(dfus); nrow(dfsw); nrow(dftx); nrow(dfnm); nrow(dfco); nrow(dfaz); nrow(dfok); nrow(dfks); nrow(dfne); nrow(dfwy)


# create dataframes for bcrs +++++++++++++++++++++++++++++++++++++++++++++++++++
# - these eight regions are the only bbs regions for casp

df16 <- filter_bcr(dfx, "BCR16")
df18 <- filter_bcr(dfx, "BCR18")
df19 <- filter_bcr(dfx, "BCR19")
df20 <- filter_bcr(dfx, "BCR20")
df21 <- filter_bcr(dfx, "BCR21")
df34 <- filter_bcr(dfx, "BCR34")
df35 <- filter_bcr(dfx, "BCR35")
df37 <- filter_bcr(dfx, "BCR37")

nrow(dfx)
nrow(df16); nrow(df18); nrow(df19); nrow(df20); nrow(df21); nrow(df34); nrow(df35); nrow(df37)

print(paste0("BCR16: ", nrow(df16))); print(paste0("BCR18: ", nrow(df18)))
print(paste0("BCR19: ", nrow(df19))); print(paste0("BCR20: ", nrow(df20)))
print(paste0("BCR21: ", nrow(df21))); print(paste0("BCR34: ", nrow(df34)))
print(paste0("BCR35: ", nrow(df35))); print(paste0("BCR37: ", nrow(df37)))


# create dataframes for lons +++++++++++++++++++++++++++++++++++++++++++++++++++
# - these four longitude categories cover casp range ...

df100 <- filter_lon(dfx, -100)
df105 <- filter_lon(dfx, -105)
df110 <- filter_lon(dfx, -110)
df115 <- filter_lon(dfx, -115)

nrow(dfx)
nrow(df100); nrow(df105); nrow(df110); nrow(df115)

print(paste0("LON-100: ", nrow(df100))); print(paste0("LON-105: ", nrow(df105)))
print(paste0("LON-110: ", nrow(df110))); print(paste0("LON-115: ", nrow(df115)))


# phenology from ALL ebird records +++++++++++++++++++++++++++++++++++++++++++++

phen_all <- extract_phenology(df)
minyr    <- min(df$YEAR); maxyr <- max(df$YEAR)
start    <- round(phen_all[1], 0)
median   <- round(phen_all[2], 0)
end      <- round(phen_all[3], 0)
duration <- round(phen_all[4], 0)
phen     <- c(start, median, end, duration)

# choose to plot with or without the BBD survey date range overlayed on the plot
# phen_all_plot <- plot_phenology(df, start, median, end, paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))
phen_all_plot <- plot_phenology_bbs(df, start, median, end, paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))


print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(df)))
phen_all_plot

# save the plot
# save_ggp(phen_all_plot, "/Users/jschnase/Desktop/out"", "phen_all")

# phenology from SW records (TX, NM, CO, AZ) -++++++++++++++++++++++++++++++++++

phen_sw  <- extract_phenology(dfsw)
minyr    <- min(dfsw$YEAR); maxyr <- max(dfsw$YEAR)
start    <- round(phen_sw[1], 0)
median   <- round(phen_sw[2], 0)
end      <- round(phen_sw[3], 0)
duration <- round(phen_sw[4], 0)
phen     <- c(start, median, end, duration)

# choose to plot with or without the BBD survey date range overlayed on the plot
# phen_all_plot <- plot_phenology(df, start, median, end, paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))
phen_sw_plot <- plot_phenology_bbs(df, start, median, end, paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))

print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfsw)))
phen_sw_plot

# save the plot
# save_ggp(phen_sw_plot, "/Users/jschnase/Desktop/out", "phen_sw")

# phenology from TX records ++++++++++++++++++++++++++++++++++++++++++++++++++++

phen_tx <- extract_phenology(dftx)
minyr    <- min(dftx$YEAR); maxyr <- max(dftx$YEAR)
start    <- round(phen_tx[1], 0)
median   <- round(phen_tx[2], 0)
end      <- round(phen_tx[3], 0)
duration <- round(phen_tx[4], 0)
phen <- c(start, median, end, duration)

# choose to plot with or without the BBD survey date range overlayed on the plot
# phen_tx_plot <- plot_phenology(dftx, start, median, end, paste0("CASP TX Phenology (", minyr, "-", maxyr, ")"))
phen_tx_plot <- plot_phenology_bbs(dftx, start, median, end, paste0("CASP TX Phenology (", minyr, "-", maxyr, ")"))

print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dftx)))
phen_tx_plot

# save the plot
# save_ggp(phen_tx_plot, "/Users/jschnase/Desktop/out", "phen_tx")

# phenology from NM records ++++++++++++++++++++++++++++++++++++++++++++++++++++

phen_nm  <- extract_phenology(dfnm)
minyr    <- min(dfnm$YEAR); maxyr <- max(dfnm$YEAR)
start    <- round(phen_nm[1], 0)
median   <- round(phen_nm[2], 0)
end      <- round(phen_nm[3], 0)
duration <- round(phen_nm[4], 0)
phen <- c(start, median, end, duration)

# choose to plot with or without the BBD survey date range overlayed on the plot
# phen_nm_plot <- plot_phenology(dfnm, start, median, end, paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))
phen_nm_plot <- plot_phenology_bbs(dfnm, start, median, end, paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))

print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfnm)))
phen_nm_plot

# save plot
# save_ggp(phen_nm_plot, "/Users/jschnase/Desktop/out", "phen_nm")

# phenology from CO records ++++++++++++++++++++++++++++++++++++++++++++++++++++

phen_co  <- extract_phenology(dfco)
minyr    <- min(dfco$YEAR); maxyr <- max(dfco$YEAR)
start    <- round(phen_co[1], 0)
median   <- round(phen_co[2], 0)
end      <- round(phen_co[3], 0)
duration <- round(phen_co[4], 0)
phen <- c(start, median, end, duration)

# choose to plot with or without the BBD survey date range overlayed on the plot
# phen_co_plot <- plot_phenology(dfco, start, median, end, paste0("CASP CO Phenology (", minyr, "-", maxyr, ")"))
phen_co_plot <- plot_phenology_bbs(dfco, start, median, end, paste0("CASP CO Phenology (", minyr, "-", maxyr, ")"))

print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfco)))
phen_co_plot

# save the plot
# save_ggp(phen_nm_plot, "/Users/jschnase/Desktop/out", "phen_nm")

# phenology from AZ records ++++++++++++++++++++++++++++++++++++++++++++++++++++

phen_az  <- extract_phenology(dfaz)
minyr    <- min(dfaz$YEAR); maxyr <- max(dfaz$YEAR)
start    <- round(phen_az[1], 0)
median   <- round(phen_az[2], 0)
end      <- round(phen_az[3], 0)
duration <- round(phen_az[4], 0)
phen <- c(start, median, end, duration)

# choose to plot with or without the BBD survey date range overlayed on the plot
# phen_az_plot <- plot_phenology(dfaz, start, median, end, paste0("CASP AZ Phenology (", minyr, "-", maxyr, ")"))
phen_az_plot <- plot_phenology_bbs(dfaz, start, median, end, paste0("CASP AZ Phenology (", minyr, "-", maxyr, ")"))

print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfaz)))
phen_az_plot

# save the plot
# save_ggp(phen_az_plot, "/Users/jschnase/Desktop/out", "phen_az")

# phenology from TX, NM records ++++++++++++++++++++++++++++++++++++++++++++++++

phen_xm  <- extract_phenology(dfxm)
minyr    <- min(dfxm$YEAR); maxyr <- max(dfxm$YEAR)
start    <- round(phen_xm[1], 0)
median   <- round(phen_xm[2], 0)
end      <- round(phen_xm[3], 0)
duration <- round(phen_xm[4], 0)
phen <- c(start, median, end, duration)

# choose to plot with or without the BBD survey date range overlayed on the plot
phen_xm_plot <- plot_phenology(dfxm, start, median, end, paste0("CASP XM Phenology (", minyr, "-", maxyr, ")"))
phen_xm_plot <- plot_phenology_bbs(dfxm, start, median, end, paste0("CASP XM Phenology (", minyr, "-", maxyr, ")"))

print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfxm)))
phen_xm_plot

# save plot
# save_ggp(phen_xm_plot, "/Users/jschnase/Desktop/out", "phen_xm")

# plot summary

# plot various summaries +++++++++++++++++++++++++++++++++++++++++++++++++++++++
phen_all_plot
phen_sw_plot
phen_tx_plot
phen_nm_plot
phen_co_plot
phen_az_plot

# state-by-state density comparisons +++++++++++++++++++++++++++++++++++++++++++
tx <- filter_state(df, "Texas")
nm <- filter_state(df, "New Mexico")
az <- filter_state(df, "Arizona")

txnm <- data.frame()
txaz <- data.frame()
nmaz <- data.frame()

txnm <- rbind(txnm, tx, nm)
txaz <- rbind(txaz, tx, az)
nmaz <- rbind(nmaz, nm, az)

txnmm <- plyr::ddply(txnm, "STATE", summarise, grp.mean=mean(YDAY))
txazm <- plyr::ddply(txaz, "STATE", summarise, grp.mean=mean(YDAY))
nmazm <- plyr::ddply(nmaz, "STATE", summarise, grp.mean=mean(YDAY))

title <- "Occurrence Density Comparisons"
txnmp <- ggplot(txnm, aes(x=YDAY, after_stat(scaled), color=STATE)) + geom_density() +
            # # bbs survey
            # geom_vline(aes(xintercept=159), 
            #             color="lightyellow", linetype="solid", linewidth=7) +
            geom_vline(data=txnmm, aes(xintercept=grp.mean, color=STATE), linetype="dashed") +
            ggtitle(title) + xlab("Day of Year") + ylab("Occurrence Density") +
            theme(text=element_text(size=15))
txazp <- ggplot(txaz, aes(x=YDAY, after_stat(scaled), color=STATE)) + geom_density() +
            # # bbs survey
            # geom_vline(aes(xintercept=159), 
            #             color="lightyellow", linetype="solid", linewidth=7) +
            geom_vline(data=txazm, aes(xintercept=grp.mean, color=STATE), linetype="dashed") +
            ggtitle(title) + xlab("Day of Year") + ylab("Occurrence Density") +
            theme(text=element_text(size=15))
nmazp <- ggplot(nmaz, aes(x=YDAY, after_stat(scaled), color=STATE)) + geom_density() +
            # # bbs survey
            # geom_vline(aes(xintercept=159), 
            #             color="lightyellow", linetype="solid", linewidth=7) +
            geom_vline(data=nmazm, aes(xintercept=grp.mean, color=STATE), linetype="dashed") +
            ggtitle(title) + xlab("Day of Year") + ylab("Occurrence Density") +
            theme(text=element_text(size=15))

txnmp; txazp; nmazp


# Count plot collection

# plot various combinations ...

# plot_combined_phenology_count()
# plot_combined_phenology_count_full_range()
plot_combined_phenology_count_TxNmCoAz()

# Scaled plot collection
plot_combined_phenology_scaled()

# comparative phenology from ALL records +++++++++++++++++++++++++++++++++++++++

# 1900 ---
dfall1    <- filter_range(df, 1900, 1990)
phen_all1 <- extract_phenology(dfall1)
minyr     <- min(dfall1$YEAR); maxyr <- max(dfall1$YEAR)
start     <- round(phen_all1[1], 0)
median    <- round(phen_all1[2], 0)
end       <- round(phen_all1[3], 0)
duration  <- round(phen_all1[4], 0)
phen      <- c(start, median, end, duration)

phen_all1_plot <- plot_phenology_bbs(dfall1, start, median, end, 
                                     paste0("CASP ALL ALLPhenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfall1)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))

# 2020 ---
dfall2    <- filter_range(df, 2020, 2024)
phen_all2 <- extract_phenology(dfall2)
minyr     <- min(dfall2$YEAR); maxyr <- max(dfall2$YEAR)
start     <- round(phen_all2[1], 0)
median    <- round(phen_all2[2], 0)
end       <- round(phen_all2[3], 0)
duration  <- round(phen_all2[4], 0)
phen      <- c(start, median, end, duration)

phen_all2_plot <- plot_phenology_bbs(dfall2, start, median, end, 
                                     paste0("CASP ALL Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfall2)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print("----------------------------------------------------------------")

phen_all1_plot
phen_all2_plot
# save_ggp(phen_all1_plot, "/Users/jschnase/Desktop/out", "phen_comp_all1")
# save_ggp(phen_all2_plot, "/Users/jschnase/Desktop/out", "phen_comp_all2")


# comparative phenology from SW records ++++++++++++++++++++++++++++++++++++++++

# 1900 ---
dfsw1    <- filter_range(dfsw, 1900, 1990)
phen_sw1 <- extract_phenology(dfsw1)
minyr    <- min(dfsw1$YEAR); maxyr <- max(dfsw1$YEAR)
start    <- round(phen_sw1[1], 0)
median   <- round(phen_sw1[2], 0)
end      <- round(phen_sw1[3], 0)
duration <- round(phen_sw1[4], 0)
phen     <- c(start, median, end, duration)

phen_sw1_plot <- plot_phenology_bbs(dfsw1, start, median, end, 
                                    paste0("CASP SW Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfsw1)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))

# 2020 ---
dfsw2    <- filter_range(dfsw, 2020, 2024)
phen_sw2 <- extract_phenology(dfsw2)
minyr    <- min(dfsw2$YEAR); maxyr <- max(dfsw2$YEAR)
start    <- round(phen_sw2[1], 0)
median   <- round(phen_sw2[2], 0)
end      <- round(phen_sw2[3], 0)
duration <- round(phen_sw2[4], 0)
phen     <- c(start, median, end, duration)

phen_sw2_plot <- plot_phenology_bbs(dfsw2, start, median, end, 
                                    paste0("CASP SW Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfsw2)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print("----------------------------------------------------------------")

phen_sw1_plot
phen_sw2_plot
# save_ggp(phen_sw1_plot, "/Users/jschnase/Desktop/out", "phen_comp_sw1")
# save_ggp(phen_sw2_plot, "/Users/jschnase/Desktop/out", "phen_comp_sw2")


# comparative phenology from TX records ++++++++++++++++++++++++++++++++++++++++

# 1900 ---
dftx1    <- filter_range(dftx, 1900, 1990)
phen_tx1 <- extract_phenology(dftx1)
minyr    <- min(dftx1$YEAR); maxyr <- max(dftx1$YEAR)
start    <- round(phen_tx1[1], 0)
median   <- round(phen_tx1[2], 0)
end      <- round(phen_tx1[3], 0)
duration <- round(phen_tx1[4], 0)
phen     <- c(start, median, end, duration)

phen_tx1_plot <- plot_phenology_bbs(dftx1, start, median, end, 
                                    paste0("CASP TX Phenology (", minyr, "-", maxyr, ")"))
print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dftx1)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))

# 2020 ---
dftx2    <- filter_range(dftx, 2020, 2024)
phen_tx2 <- extract_phenology(dftx2)
minyr    <- min(dftx2$YEAR); maxyr <- max(dftx2$YEAR)
start    <- round(phen_tx2[1], 0)
median   <- round(phen_tx2[2], 0)
end      <- round(phen_tx2[3], 0)
duration <- round(phen_tx2[4], 0)
phen     <- c(start, median, end, duration)

phen_tx2_plot <- plot_phenology_bbs(dftx2, start, median, end, 
                                    paste0("CASP TX Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dftx2)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print("----------------------------------------------------------------")

phen_tx1_plot
phen_tx2_plot
# save_ggp(phen_tx1_plot, "/Users/jschnase/Desktop/out", "phen_comp_tx1")
# save_ggp(phen_tx2_plot, "/Users/jschnase/Desktop/out", "phen_comp_tx2")


# comparative phenology from NM records ++++++++++++++++++++++++++++++++++++++++

# 1900 ---
dfnm1    <- filter_range(dfnm, 1900, 1994)
phen_nm1 <- extract_phenology(dfnm1)
minyr    <- min(dfnm1$YEAR); maxyr <- max(dfnm1$YEAR)
start    <- round(phen_nm1[1], 0)
median   <- round(phen_nm1[2], 0)
end      <- round(phen_nm1[3], 0)
duration <- round(phen_nm1[4], 0)
phen <- c(start, median, end, duration)

phen_nm1_plot <- plot_phenology_bbs(dfnm1, start, median, end, 
                                    paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfnm1)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))

# 2020 ---
dfnm2    <- filter_range(dfnm, 2020, 2024)
phen_nm2 <- extract_phenology(dfnm2)
minyr    <- min(dfnm2$YEAR); maxyr <- max(dfnm2$YEAR)
start    <- round(phen_nm2[1], 0)
median   <- round(phen_nm2[2], 0)
end      <- round(phen_nm2[3], 0)
duration <- round(phen_nm2[4], 0)
phen     <- c(start, median, end, duration)

phen_nm2_plot <- plot_phenology_bbs(dfnm2, start, median, end, 
                                    paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfnm2)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print("----------------------------------------------------------------")

phen_nm1_plot
phen_nm2_plot
# save_ggp(phen_nm1_plot, "/Users/jschnase/Desktop/out", "phen_comp_nm1")
# save_ggp(phen_nm2_plot, "/Users/jschnase/Desktop/out", "phen_comp_nm2")


# comparative phenology from NM records ++++++++++++++++++++++++++++++++++++++++

# 1900 ---
dfnm1    <- filter_range(dfnm, 1900, 1994)
phen_nm1 <- extract_phenology(dfnm1)
minyr    <- min(dfnm1$YEAR); maxyr <- max(dfnm1$YEAR)
start    <- round(phen_nm1[1], 0)
median   <- round(phen_nm1[2], 0)
end      <- round(phen_nm1[3], 0)
duration <- round(phen_nm1[4], 0)
phen <- c(start, median, end, duration)

phen_nm1_plot <- plot_phenology_bbs(dfnm1, start, median, end, 
                                    paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfnm1)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))

# 2020 ---
dfnm2    <- filter_range(dfnm, 2020, 2024)
phen_nm2 <- extract_phenology(dfnm2)
minyr    <- min(dfnm2$YEAR); maxyr <- max(dfnm2$YEAR)
start    <- round(phen_nm2[1], 0)
median   <- round(phen_nm2[2], 0)
end      <- round(phen_nm2[3], 0)
duration <- round(phen_nm2[4], 0)
phen     <- c(start, median, end, duration)

phen_nm2_plot <- plot_phenology_bbs(dfnm2, start, median, end, 
                                    paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfnm2)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print("----------------------------------------------------------------")

phen_nm1_plot
phen_nm2_plot
# save_ggp(phen_nm1_plot, "/Users/jschnase/Desktop/out", "phen_comp_nm1")
# save_ggp(phen_nm2_plot, "/Users/jschnase/Desktop/out", "phen_comp_nm2")


# comparative phenology from NM records ++++++++++++++++++++++++++++++++++++++++

# 1900 ---
dfnm1    <- filter_range(dfnm, 1900, 1994)
phen_nm1 <- extract_phenology(dfnm1)
minyr    <- min(dfnm1$YEAR); maxyr <- max(dfnm1$YEAR)
start    <- round(phen_nm1[1], 0)
median   <- round(phen_nm1[2], 0)
end      <- round(phen_nm1[3], 0)
duration <- round(phen_nm1[4], 0)
phen <- c(start, median, end, duration)

phen_nm1_plot <- plot_phenology_bbs(dfnm1, start, median, end, 
                                    paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfnm1)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))

# 2020 ---
dfnm2    <- filter_range(dfnm, 2020, 2024)
phen_nm2 <- extract_phenology(dfnm2)
minyr    <- min(dfnm2$YEAR); maxyr <- max(dfnm2$YEAR)
start    <- round(phen_nm2[1], 0)
median   <- round(phen_nm2[2], 0)
end      <- round(phen_nm2[3], 0)
duration <- round(phen_nm2[4], 0)
phen     <- c(start, median, end, duration)

phen_nm2_plot <- plot_phenology_bbs(dfnm2, start, median, end, 
                                    paste0("CASP NM Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfnm2)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print("----------------------------------------------------------------")

phen_nm1_plot
phen_nm2_plot
# save_ggp(phen_nm1_plot, "/Users/jschnase/Desktop/out", "phen_comp_nm1")
# save_ggp(phen_nm2_plot, "/Users/jschnase/Desktop/out", "phen_comp_nm2")


# comparative phenology from AZ records ++++++++++++++++++++++++++++++++++++++++

# 1900 ---
dfaz1    <- filter_range(dfaz, 1900, 1994)
phen_az1 <- extract_phenology(dfaz1)
minyr    <- min(dfaz1$YEAR); maxyr <- max(dfaz1$YEAR)
start    <- round(phen_az1[1], 0)
median   <- round(phen_az1[2], 0)
end      <- round(phen_az1[3], 0)
duration <- round(phen_az1[4], 0)
phen     <- c(start, median, end, duration)

phen_az1_plot <- plot_phenology_bbs(dfaz1, start, median, end, 
                                    paste0("CASP AZ Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfaz1)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))

# 2020 ---
dfaz2    <- filter_range(dfaz, 2020, 2024)
phen_az2 <- extract_phenology(dfaz2)
minyr    <- min(dfaz2$YEAR); maxyr <- max(dfaz2$YEAR)
start    <- round(phen_az2[1], 0)
median   <- round(phen_az2[2], 0)
end      <- round(phen_az2[3], 0)
duration <- round(phen_az2[4], 0)
phen     <- c(start, median, end, duration)

phen_az2_plot <- plot_phenology_bbs(dfaz2, start, median, end, 
                                    paste0("CASP AZ Phenology (", minyr, "-", maxyr, ")"))

print("----------------------------------------------------------------")
print(paste0("Years=", minyr, "-", maxyr))
print(paste0("Records=", nrow(dfaz2)))
print(paste0(c("Start=", "Median=", "End=", "Duration="), phen))
print("----------------------------------------------------------------")

phen_az1_plot
phen_az2_plot
# save_ggp(phen_az1_plot, "/Users/jschnase/Desktop/out", "phen_comp_az1")
# save_ggp(phen_az2_plot, "/Users/jschnase/Desktop/out", "phen_comp_az2")


# breeding season START day trends +++++++++++++++++++++++++++++++++++++++++++++ START TRENDS LR
summary <- phen_summary()
all <- plot_trend_lr(summary, "All", "start")
swp <- plot_trend_lr(summary, "Southwest", "start")
ncp <- plot_trend_lr(summary, "NMCO", "start")
txp <- plot_trend_lr(summary, "Texas", "start")
nmp <- plot_trend_lr(summary, "New Mexico", "start")
cop <- plot_trend_lr(summary, "Colorado", "start")
azp <- plot_trend_lr(summary, "Arizona", "start")

all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "lr_all_start")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "lr_swp_start")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "lr_ncp_start")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "lr_txp_start")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "lr_nmp_start")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "lr_cop_start")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "lr_azp_start")

# breeding season MEDIAN day trends ++++++++++++++++++++++++++++++++++++++++++++ MEDIAN TRENDS LR
summary <- phen_summary()
all <- plot_trend_lr(summary, "All", "median")
swp <- plot_trend_lr(summary, "Southwest", "median")
ncp <- plot_trend_lr(summary, "NMCO", "median")
txp <- plot_trend_lr(summary, "Texas", "median")
nmp <- plot_trend_lr(summary, "New Mexico", "median")
cop <- plot_trend_lr(summary, "Colorado", "median")
azp <- plot_trend_lr(summary, "Arizona", "median")

all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "lr_all_median")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "lr_swp_median")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "lr_ncp_median")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "lr_txp_median")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "lr_nmp_median")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "lr_cop_median")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "lr_azp_median")

# breeding season END day trends +++++++++++++++++++++++++++++++++++++++++++++++ END TRENDS LR
summary <- phen_summary()
all <- plot_trend_lr(summary, "All", "end")
swp <- plot_trend_lr(summary, "Southwest", "end")
ncp <- plot_trend_lr(summary, "NMCO", "end")
txp <- plot_trend_lr(summary, "Texas", "end")
nmp <- plot_trend_lr(summary, "New Mexico", "end")
cop <- plot_trend_lr(summary, "Colorado", "end")
azp <- plot_trend_lr(summary, "Arizona", "end")

all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "lr_all_end")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "lr_swp_end")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "lr_ncp_end")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "lr_txp_end")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "lr_nmp_end")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "lr_cop_end")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "lr_azp_end")

# breeding season DURATION trends ++++++++++++++++++++++++++++++++++++++++++++++ DURATIOIN TRENDS LR
summary <- phen_summary()
all <- plot_trend_lr_duration(summary, "All", "duration")
swp <- plot_trend_lr_duration(summary, "Southwest", "duration")
ncp <- plot_trend_lr_duration(summary, "NMCO", "duration")
txp <- plot_trend_lr_duration(summary, "Texas", "duration")
nmp <- plot_trend_lr_duration(summary, "New Mexico", "duration")
cop <- plot_trend_lr_duration(summary, "Colorado", "duration")
azp <- plot_trend_lr_duration(summary, "Arizona", "duration")

all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "lr_all_duration")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "lr_swp_duration")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "lr_ncp_duration")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "lr_txp_duration")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "lr_nmp_duration")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "lr_cop_duration")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "lr_azp_duration")

# breeding season START trends (stats) +++++++++++++++++++++++++++++++++++++++++ START TRENDS BR STATS
summary <- phen_summary()
all <- plot_trend_br(summary, "All", "start")
swp <- plot_trend_br(summary, "Southwest", "start")
ncp <- plot_trend_br(summary, "NMCO", "start")
txp <- plot_trend_br(summary, "Texas", "start")
nmp <- plot_trend_br(summary, "New Mexico", "start")
cop <- plot_trend_br(summary, "Colorado", "start")
azp <- plot_trend_br(summary, "Arizona", "start")

# breeding season START trends (plots) +++++++++++++++++++++++++++++++++++++++++ START TRENDS BR PLOTS
all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "br_all_start")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "br_swp_start")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "br_ncp_start")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "br_txp_start")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "br_nmp_start")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "br_cop_start")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "br_azp_start")

# breeding season MEDIAN trends (stats) ++++++++++++++++++++++++++++++++++++++++ MEDIAN TRENDS BR STATS
summary <- phen_summary()
all <- plot_trend_br(summary, "All", "median")
swp <- plot_trend_br(summary, "Southwest", "median")
ncp <- plot_trend_br(summary, "NMCO", "median")
txp <- plot_trend_br(summary, "Texas", "median")
nmp <- plot_trend_br(summary, "New Mexico", "median")
cop <- plot_trend_br(summary, "Colorado", "median")
azp <- plot_trend_br(summary, "Arizona", "median")

# breeding season MEDIAN trends (plots) ++++++++++++++++++++++++++++++++++++++++ MEDIAN TRENDS BR PLOTS
all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "br_all_median")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "br_swp_median")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "br_ncp_median")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "br_txp_median")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "br_nmp_median")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "br_cop_median")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "br_azp_median")

# breeding season END trends (stats) +++++++++++++++++++++++++++++++++++++++++++ END TRENDS BR STATS
summary <- phen_summary()
all <- plot_trend_br(summary, "All", "end")
swp <- plot_trend_br(summary, "Southwest", "end")
ncp <- plot_trend_br(summary, "NMCO", "end")
txp <- plot_trend_br(summary, "Texas", "end")
nmp <- plot_trend_br(summary, "New Mexico", "end")
cop <- plot_trend_br(summary, "Colorado", "end")
azp <- plot_trend_br(summary, "Arizona", "end")

# breeding season END trends (plots) +++++++++++++++++++++++++++++++++++++++++++ END TRENDS BR PLOTS
all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "br_all_end")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "br_swp_end")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "br_ncp_end")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "br_txp_end")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "br_nmp_end")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "br_cop_end")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "br_azp_end")

# breeding season DURATION trends (stats) ++++++++++++++++++++++++++++++++++++++ DURATION TRENDS BR STATS
summary <- phen_summary()
all <- plot_trend_br(summary, "All", "duration")
swp <- plot_trend_br(summary, "Southwest", "duration")
ncp <- plot_trend_br(summary, "NMCO", "duration")
txp <- plot_trend_br(summary, "Texas", "duration")
nmp <- plot_trend_br(summary, "New Mexico", "duration")
cop <- plot_trend_br(summary, "Colorado", "duration")
azp <- plot_trend_br(summary, "Arizona", "duration")

# breeding season DURATION trends (plots) ++++++++++++++++++++++++++++++++++++++ DURATION TRENDS BR PLOTS
all; swp; ncp; txp; nmp; cop; azp
# save_ggp(all, "/Users/jschnase/Desktop/trends", "br_all_duration")
# save_ggp(swp, "/Users/jschnase/Desktop/trends", "br_swp_duration")
# save_ggp(ncp, "/Users/jschnase/Desktop/trends", "br_ncp_duration")
# save_ggp(txp, "/Users/jschnase/Desktop/trends", "br_txp_duration")
# save_ggp(nmp, "/Users/jschnase/Desktop/trends", "br_nmp_duration")
# save_ggp(cop, "/Users/jschnase/Desktop/trends", "br_cop_duration")
# save_ggp(azp, "/Users/jschnase/Desktop/trends", "br_azp_duration")


# create map animation (ggplot version) ++++++++++++++++++++++++++++++++++++++++
sw     <- map_data("state", region=c("texas", "new mexico", "arizona"))
casp   <- map_data("state", region=c("texas", "new mexico", "arizona",
                                  "oklahoma", "colorado", "kansas", "nebraska"))
conus  <- map_data("state")
mexico <- map_data("world", region="Mexico")

png("/Users/jschnase/Desktop/plot/f%03d.png")
for (i in seq(1:365)) {
    x <- df %>% filter(YDAY==i)
    title  <- paste("Day ", i, " / Record Count = ", nrow(x))
    p <- ggplot() + geom_sf() + 
            geom_polygon( data=conus, aes(x=long, y=lat, group=group), color="lightgrey", fill="white") +
            geom_polygon( data=mexico, aes(x=long, y=lat, group=group), color="lightgrey", fill="white") +
            coord_sf(xlim = c(-95, -120), ylim = c(20, 45)) + 
            geom_point(data=x, aes(x=LONGITUDE, y=LATITUDE), shape=21, size=1, fill="blue") + 
            labs(title=title, y="Latitude", x="Longitude")
    print(p)
    }
dev.off()

png_files <- sprintf("/Users/jschnase/Desktop/plot/f%03d.png", 1:365)
av_encode_video(png_files, '/Users/jschnase/Desktop/plot.mp4', framerate = 30)
browseURL('/Users/jschnase/Desktop/plot.mp4')

# create graph animation +++++++++++++++++++++++++++++++++++++++++++++++++++++++
png("/Users/jschnase/Desktop/graph/f%03d.png")
for (i in seq(1:365)) {
    x <- df %>% filter(YDAY==i)
    n <- nrow(x)
    title  <- paste("Day ", i, " / Record Count = ", n)
    p <- ggplot() + 
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=5) +
            geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = .2, data = df) +
            geom_density(aes(YDAY, fill = "TX", after_stat(count)), alpha = .2, data = dftx) +
            geom_density(aes(YDAY, fill = "NM", after_stat(count)), alpha = .2, data = dfnm) +
            geom_density(aes(YDAY, fill = "CO", after_stat(count)), alpha = .2, data = dfco) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(count)), alpha = .2, data = dfaz) + 
            geom_point(aes(x=i, y=n), shape=20, size=5) +
            labs(title=title, x="Day of Year", y="Record Count") +
            scale_fill_manual(na="Region", values=c(All="gray", TX="red", NM="blue", CO="yellow", AZ="green")) +
            theme(text=element_text(size=20)) + xlim(1,366) + ylim(0,550)
    print(p)
    }
dev.off()

png_files <- sprintf("/Users/jschnase/Desktop/graph/f%03d.png", 1:365)
av_encode_video(png_files, '/Users/jschnase/Desktop/graph.mp4', framerate=30)
browseURL('/Users/jschnase/Desktop/graph.mp4')

# create map + graph animation (1980-2024) +++++++++++++++++++++++++++++++++++++

sw     <- map_data("state", region=c("texas", "new mexico", "arizona"))
conus  <- map_data("state")
mexico <- map_data("world", region="Mexico")
casp   <- map_data("state", region=c("texas", "new mexico", "arizona",
                                  "oklahoma", "colorado", "kansas", "nebraska"))
label1 <- "Daily Cassin's Sparrow eBird Occurrence Record Densities (1980-2024)  "
label2 <- "Estimated Breeding Phenology: Start = day 65 / Median = day 156 / End = day 276 / Duration = 211 days   "

png("/Users/jschnase/Desktop/casp_1980-2024/f%03d.png",
    width     = 2000,
    height    = 1000,
    units     = "px",
    res       = 72,
    pointsize = 15)
for (i in seq(1:365)) {
    x <- df %>% filter(YDAY==i)
    n <- nrow(x)
    title  <- paste("Day ", i, " / Record Count = ", n)

    # map
    p0 <- ggplot() + geom_sf() + 
            geom_polygon(data=conus, aes(x=long, y=lat, group=group), color="darkgrey", fill="white") +
            geom_polygon(data=mexico, aes(x=long, y=lat, group=group), color="darkgrey", fill="white") +
            coord_sf(xlim = c(-95,-120), ylim = c(20,45)) + 
            geom_point(data=x, aes(x=LONGITUDE, y=LATITUDE), shape=21, fill="red", color="blue", size=4) + 
            labs(title=title, y="Latitude", x="Longitude") +
            theme(text=element_text(size=20))
    
    # graph
    p1 <- ggplot() + 
            # geom_vline(aes(xintercept=153), color="lightyellow", linetype="solid", linewidth=1) +
            # geom_vline(aes(xintercept=166), color="lightyellow", linetype="solid", linewidth=1) +
            geom_vline(aes(xintercept=159), color="lightyellow", linetype="solid", linewidth=12) +
            geom_vline(aes(xintercept=65), color="darkgrey", linetype="dashed", linewidth=1) +
            geom_vline(aes(xintercept=156), color="darkgrey", linetype="solid", linewidth=1) +
            geom_vline(aes(xintercept=276), color="darkgrey", linetype="dashed", linewidth=1) +
            geom_density(aes(YDAY, fill = "All", after_stat(count)), alpha = .2, data = df) +
            geom_density(aes(YDAY, fill = "TX", after_stat(count)), alpha = .2, data = dftx) +
            geom_density(aes(YDAY, fill = "NM", after_stat(count)), alpha = .2, data = dfnm) +
            geom_density(aes(YDAY, fill = "CO", after_stat(count)), alpha = .2, data = dfco) +
            geom_density(aes(YDAY, fill = "AZ", after_stat(count)), alpha = .2, data = dfaz) + 
            geom_point(aes(x=i, y=n), shape=23, size=8, fill="red", color="blue") +
            labs(x="Day of Year", y="Record Count") +
            annotate("text", x=Inf, y=Inf, vjust=1, hjust=1, label=label1, size=9) +
            annotate("text", x=Inf, y=Inf, vjust=5, hjust=1, label=label2, size=6, col="black", fontface="italic") +
            scale_fill_manual(na="Region", values=c(All="gray", TX="red", NM="blue", CO="yellow", AZ="green")) +
            theme(text=element_text(size=20)) + xlim(1,366) + ylim(0,600)

    grid.arrange(p0, p1, ncol=2)
    }   
dev.off()

png_files <- sprintf("/Users/jschnase/Desktop/casp_1980-2024/f%03d.png", 1:365)
av_encode_video(png_files, "/Users/jschnase/Desktop/casp_1980-2024.mp4", framerate=30)
browseURL("/Users/jschnase/Desktop/casp_1980-2024.mp4")


