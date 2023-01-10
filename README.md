# Storm Drain Selection
Code for selecting a sample of storm drains in Barcelona for the IDAlert intervention study

## Usage

The code in `sampling.R` generates a simple random sample of the Barcelona storm drains that were detected as active in 2022, with the constraint that no sampled drains can be less than 200 meters from each other.

The script is written so that it can be run directly by the Barcelona Public Health Agency, which will select a random seed and then keep this and the sampled drain locations confidential until the end of the study, apart from sharing the locations with other city authorities and contractors responsible for the drain modifications involved in this study.

To use the script, you should to do the following:

1. Clone the repository or simply download `sampling.R`.
2. Fill in a random seed value, save your local copy of the script and keep it someplace safe and confidential, so that the seed you used can be later shared for replicability purposes but is not known by other researchers until the sampling and analysis have been completed. 
3. Fill in the path to the directory in which you have the shape file containing the active storm drains from which the selection is being made (`items_act_2022.shp`).
4. Fill in the path to the directory in which you would like the output saved.
5. Run the code. It will save two sets of shape files in the output directory: (a) `storm_drains_selected.shp` (and associated files with the same name) is the file that contains the information on selected drains, and whether each of these is in the treatment or control group; (b) `storm_drains_selected_masked.shp` (and associated files with the same name) is the same file, but it is missing the `treatment` variable. Each of these files has a `group` variable in which the treatment and control groups have been randomly assigned either `A` of `B`. Thus, `storm_drains_selected_masked.csv` will be the file that should be shared with the data analysis team after sampling has been completed, so that analysis can be done without knowing which is the treatment group and which is the control group.

## About

The code in this repository has been developed as part of the [IDAlert](http://idalertproject.eu) Project, which has received funding from the European Union’s Horizon Europe programme (Grant Agreement 101057554).

Copyright 2023 IDAlert Consortium

The code in this repository is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses.