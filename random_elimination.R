# Overview ####

# This script is used to select 4 storm drain IDs at random from the list of IDs for the control drains provided by ASPB. After providing the initial list of treatment and control drains, a number needed to be eliminated because of various unforeseen constraints making modification (for treatments) or access (for both impossible). This has left 22 treatment drains (2 reixes and 20 embornals) and 26 control drains (5 reixas and 21 embornals). The 4 selected control drains (3 reixes and 1 embornal) will be eliminated from the study, leaving 22 in each arm. 

library(tidyverse)
library(readxl)

# setting seed for RNG ####

this_seed = sample(1:10000, 1) # this number will be stored at the end.
set.seed(this_seed) # for reproducing the sample, this_seed should be set manually to the stored seed.

# setting directories ####

data_directory = "data/raw/ASPB" # directory with the list sent by ASPB

output_directory = "output/IDAlert_storm_drain_elimination_2023_07_15" # directory in which the two output files will be saved.


# reading list from ASPB ####
items_entrada = read_excel(file.path(data_directory, "items_entrada.xlsx"))

reixes = items_entrada %>% filter(tipus_entitat == "Reixa")

embornals = items_entrada %>% filter(tipus_entitat == "Embornal")

# random selection ####
eliminated_reixes = sample_n(reixes, 3)
eliminated_embornals = sample_n(embornals, 1)
eliminated = bind_rows(eliminated_reixes, eliminated_embornals)

# writing output ####
write_csv(eliminated, file.path(output_directory, "eliminated_control_drains.csv"))


sink(file.path(output_directory, "storm_drains_seed.txt"))
cat(this_seed)
sink() # writing the random seed to the output directory as a text file.
