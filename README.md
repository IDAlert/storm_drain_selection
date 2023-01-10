# Storm Drain Selection
Code for selecting a sample of storm drains in Barcelona for the IDAlert intervention study

## Usage

The code in `sampling.R` generates a simple random sample of the Barcelona storm drains that were detected as active in 2022, with the constraint that no sampled drains can be 200 meters or less from each other and the final sample must have an even number of drains (so that half can be assigned to the control group and half to the treatment group).

We have written the `buffered_sample` function for selecting drains, which works as follows:

1. Start with the pool of drains from which we can select the sample. This is defined as all drains in which mosquito activity was detected in 2022. 

2. Choose one of these drains at random, assign it to the treatment or control group (treatment is assigned on the first draw and the we switch between treatment and control for each subsequent draw), and add it to the set of drains that will be the final sample.

3. Calculate the distances between the selected drain and the pool of drains and remove from the pool any drains that are 200 meters or less from the selected drain.

4. Repeat this process until there are no more drains in the pool.

5. If the final sample contains an odd number of drains, eliminate the last one from the sample.

6. Create a `group` variable in the sample and assign it either `A` or `B` depending on whether the drain is in the treatment or control group (with the choice of which letter corresponds to treatment being chosen at random)

The script is written so that it can be run by one member of the research team and shared with city authorities and contractors responsible for the drain modifications, keeping others on the research team blind to the locations of the treatment and control drains until the end of the study.

The code uses a randomly generated seed value to select a simple random sample of storm drains according to the constraints described above using the `buffered_sample` function. It saves the seed value and two sets of shape files: (a) `storm_drains_selected.shp` (and associated files with the same name) is the file that contains the information on selected drains, and whether each of these is in the treatment or control group; (b) `storm_drains_selected_masked.shp` (and associated files with the same name) is the same file, but it is missing the `treatment` variable. Each of these files has a `group` variable in which the treatment and control groups have been randomly assigned either `A` of `B`. Thus, `storm_drains_selected_masked.shp` should be the file shared with the data analysis team after sampling has been completed, so that analysis can be done without knowing which is the treatment group and which is the control group.

## About

The code in this repository has been developed as part of the [IDAlert](http://idalertproject.eu) Project, which has received funding from the European Union’s Horizon Europe programme (Grant Agreement 101057554).

Copyright 2023 IDAlert Consortium

The code in this repository is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses.