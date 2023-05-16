# Overview ####

# This script starts with the storm drains 
# sampled (using sampling.R) from the set of 
# drains that were detected as active in 2022. # It then samples from the set
# of drains that have been detected as containing water and/or active during the 
# first months of 2023. It samples from
# these drains using the same approach: 
# with the constraint that no sampled 
# drains can be 200 meters or less from 
# each other.

# As with the other script, this script is 
# written so that it can
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

data_directory = "data/raw/ASPB/drains_available_2023/" # new directory with the storm drain excel file sent to JP by AV (ASPB) on 12 May 2023.

previous_output_directory = output_directory = "output/IDAlert_storm_drain_sample_2023_04_21"
  
output_directory = "output/IDAlert_storm_drain_sample_2023_05_16" # directory in which the two output files will be saved.

# Dependencies ####
library(tidyverse)
library(sf)
library(units)
library(readxl)

# sampling function ####

buffered_sample = function(data, sample_size, buffer_radius_m, existing_sample = NULL){
  
  min_distance = set_units(buffer_radius_m, m) # turn the integer value of the minimum distance into a units object in meters.

  D = data # create a new sf object that will be manipulated as samples are selected.
  
  is_treatment = TRUE # treatment dummy that will switch back and forth
  groups = sample(c("A", "B")) # groups vector that is set in random order, to be assigned at the end such that we can have a masked version of the final selection that uses "A" and "B" groups without indicating which is treatment.
  
  
  if(is.null(existing_sample)){
  this_sample  = NULL # if no existing sample is passed as an argument then we simply create a null object that will be used to store the final sample. This will be turned into an sf object as data is added to it.
  } else{
    this_sample = existing_sample # if an existing sample is passed, then we will start with this, and filter the remaining draints to remove any within the minimum distance.
    D = D[ apply(st_distance(D, this_sample) < min_distance, 1, sum) == 0, ] # Remove this drain from the pool and also remove any other drains less than or equal to the minimal distance
    
    existing_treatment_group = this_sample %>% filter(treatment == TRUE) %>% pull(group) %>% first() # if there is an existing sample, then we need to make sure the group mask is assigned to treatment the same way in the new sample
    
    groups = c(existing_treatment_group, groups[which(groups != existing_treatment_group)]) # here we assign the group order to match the existing sample
    
  }
  
  
  for(i in 1:sample_size){
    this_draw = D %>% sample_n(1) %>% mutate(treatment = is_treatment) # select one drain at random from the initial pool
    D = D[st_distance(D, this_draw) > min_distance,] # Remove this drain from the pool and also remove any other drains less than or equal to the minimal distance
    this_sample = bind_rows(this_sample, this_draw) # add the selected drain to the sf object in which the final sample is being stored
    is_treatment = !is_treatment # flip the treatment dummy
    if(nrow(D)==0) break # stop here if we no longer have any drains left in the pool
  }
  
  final_sample_size = nrow(this_sample) # check final sample size at the end of the loop
  if(final_sample_size %% 2 != 0){
    this_sample = this_sample[ -final_sample_size,]
  } # in case the final result has an odd number of rows, remove the last one.
  
  this_sample = this_sample %>% mutate(group = if_else(treatment, groups[1], groups[2])) # assign the group label vector to the final result
    
  return(this_sample) # return the final result
}


# Configuration  ####

# active storm drains
active_embornals_2023 <- read_excel(file.path(data_directory, "seleccio_items_sorrenc_2022_2023.xlsx"), sheet = "Full1") %>% filter(year == 2023) %>% mutate(codi_bcasa = as.character(codi_bcasa), privats = as.integer(privats)) %>% st_as_sf(coords = c("x", "y"), crs = 25831) # This file shows drains already selected from those in which albopictus activity was detected in 2022, as well as all drains in which standing water and/or albopictus activity has been detected so far in 2023. 

previous_selection = st_read(file.path(previous_output_directory, "storm_drains_selected.shp")) %>% mutate(treatment = as.logical(treatment), year = 2022) %>% rename(tipus_entitat = tipus_enti, num_revisions_total = num_revisi, num_revisions_activitat = num_revi_1, codi_svipla = codi_svipl)

# using sampling function ####

minimal_distance = 200 # we want sampled drains to be at least 200 m from each other.

target_sample_size = 80 # this is sample size we would like but we will not actually be able to come close to it given the constraint that drains must be at least 200 m from one another.

this_new_sample_embornals = buffered_sample(data = active_embornals_2023 %>% filter(tipus_entitat == "Embornal"), sample_size = target_sample_size, buffer_radius_m = minimal_distance, existing_sample = previous_selection) 

this_new_sample = buffered_sample(data = active_embornals_2023 %>% filter(tipus_entitat == "Reixa"), sample_size = target_sample_size, buffer_radius_m = minimal_distance, existing_sample = this_new_sample_embornals) 


# double checking that we have a sample with the same number of treatment and control embornals and reixas
table(this_new_sample$treatment, this_new_sample$tipus_enti)

this_new_sample %>% st_write(file.path(output_directory, "storm_drains_selected.shp"), append=FALSE) # writing the final selected drains to the output directory as a shape file.

this_new_sample %>% select(-treatment) %>% st_write(file.path(output_directory, "storm_drains_selected_masked.shp"), append=FALSE) # writing the masked final selected drains to the output directory as a shape file.

sink(file.path(output_directory, "storm_drains_seed.txt"))
cat(this_seed)
sink() # writing the random seed to the output directory as a text file.

# After running this script, the output directory was compressed as an encrypted zip file and sent to ASPB. 



