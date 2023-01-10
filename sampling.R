# Overview ####

# This script generates a simple random 
# sample of the Barcelona storm drains 
# that were detected as active in 2022, 
# with the constraint that no sampled 
# drains can be less than 200 meters 
# from each other.

# The script is written so that it can
# be run by one member of the research team,
# who will draw a random seed number used to
# select the drains, and keep this number, 
# along with the results, confidential until 
# the end of the study, apart from sharing 
# with the city authorities and contractors 
# responsible for the treatment drain 
# modifications.

# This is part of IDAlert Task 5.2. More 
# information is in the README.md file 
# of this repository and at 
# http://idalertproject.eu

rm(list=ls())

# setting seed for RNG ####

this_seed = sample(1:10000, 1) # this number will be stored at the end.
set.seed(this_seed) # for reproducing the sample, this_seed should be set manually to the stored seed.

# setting directories ####

data_directory = "data/raw/ASPB/items_act_2022_vs_modificats" # directory with the storm drain shape file (items_act_2022.shp).

output_directory = "output/IDAlert_storm_drain_sample_2023" # directory in which the two output files will be saved.

# Dependencies ####
library(tidyverse)
library(sf)
library(units)

# sampling function ####

buffered_sample = function(data, sample_size, buffer_radius_m){
  
  min_distance = set_units(buffer_radius_m, m)

  D = data 
  this_sample  = NULL
  is_treatment = TRUE
  groups = sample(c("A", "B"))
  
  for(i in 1:sample_size){
    this_draw = D %>% sample_n(1) %>% mutate(treatment = is_treatment)
    D = D[st_distance(D, this_draw) > min_distance,]
    this_sample = bind_rows(this_sample, this_draw)
    is_treatment = !is_treatment
    if(nrow(D)==0) break
  }
  
  # in case the final result has an odd number of rows, remove the last one.
  final_sample_size = nrow(this_sample)
  if(final_sample_size %% 2 != 0){
    this_sample = this_sample[ -final_sample_size,]
  }
  
  this_sample = this_sample %>% mutate(group = if_else(treatment, groups[1], groups[2]))
    
  return(this_sample)
}


# Configuration  ####

# active storm drains
active_embornals_2022 = read_sf(file.path(data_directory, "items_act_2022.shp")) %>% # This file shows drains in which albopictus activity was detected in 2022. 
  filter(tipus_enti == "Embornal") # We are filtering it to select only the "embornals", which are the the typical storm drains, and thus avoid additional variation from Reixas and Canals. There are 141 active embornals in the dataset.

# using sampling function ####

minimal_distance = 200 # we want sampled drains to be at least 200 m from each other.

target_sample_size = 80 # this is sample size we would like but we will not actually be able to come close to it given the constraint that drains must be at least 200 m from one another.

this_sample = buffered_sample(data = active_embornals_2022, sample_size = target_sample_size, buffer_radius_m = minimal_distance) 


this_sample %>% st_write(file.path(output_directory, "storm_drains_selected.shp"))

this_sample %>% select(-treatment) %>% st_write(file.path(output_directory, "storm_drains_selected_masked.shp"))

sink(file.path(output_directory, "storm_drains_seed.txt"))
cat(this_seed)
sink()



