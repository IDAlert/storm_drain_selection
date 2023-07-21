# Overview ####

# This script plots the locations of the
# drains from which the sample was drawn
# and those that were sampled.

# This is part of IDAlert Task 5.2. More 
# information is in the README.md file 
# of this repository and at 
# http://idalertproject.eu

rm(list=ls())

# setting seed for RNG ####

# setting directories ####

data_directory_eligible_drains_2023 = "data/raw/ASPB/drains_available_2023/" # new directory with the storm drain excel file sent to JP by AV (ASPB) on 12 May 2023.

data_directory_eligible_drains_2022 = "data/raw/ASPB/available_drains_2023_04_21/" # new directory with the storm drain shape file sent to JP by AV (ASPB) on 20 April.

data_directory_first_sample_output = "output/IDAlert_storm_drain_sample_2023_04_21"
  
data_directory_second_sample_output = "output/IDAlert_storm_drain_sample_2023_05_16" # directory in which the two output files will be saved.

data_directory_final_drain_selection = "output/IDAlert_storm_drain_sample_final/"

# Dependencies ####
library(tidyverse)
library(sf)
library(units)
library(readxl)

# active storm drains
  
active_embornals_2022 <- read_sf(file.path(data_directory_eligible_drains_2022, "items_sorrencs_bcasa_amb_act.shp")) %>% st_drop_geometry() %>% select(codi_svipla = codi_svipl, x, y)

active_embornals_2023 <- read_excel(file.path(data_directory_eligible_drains_2023, "seleccio_items_sorrenc_2022_2023.xlsx"), sheet = "Full1") %>% filter(year == 2023) %>% select(codi_svipla, x, y) %>% mutate(x = as.double(x), y = as.double(y)) %>% filter(!codi_svipla %in% active_embornals_2022$codi_svipla)


pool = bind_rows(active_embornals_2022, active_embornals_2023) %>% st_as_sf(coords = c("x", "y"), crs = 25831)

selected_drains = st_read(file.path(data_directory_final_drain_selection, "Storm_drains.shp")) 

base_map = read_sf("~/Downloads/BCN_UsosSÃ²l_ETRS89_SHP/BCN_UsosSïl_ETRS89_SHP.shp")

ggplot(base_map) + geom_sf(color="#777777") + geom_sf(data = pool, color="red", size = .3) + geom_sf(data = selected_drains, color="#ffff00", pch = 1, size = 2)
ggsave("plots/drain_map.png", width=6, height=6, dpi=600)
