#!/bin/bash

# This script should run in a shst docker
# To build the docker image using the Dockerfile in this directory use:
# docker build -t shst .
#
# see it:
# docker image list
#
# Run a command (/bin/bash) in a new container layer over the specified image:
# docker run -it --rm -v [path to this directory]:/usr/node/ shst:latest /bin/bash
# e.g. on a Mac machine:
#     docker run -it --rm -v /Users/yuqiwang/Documents/5_work/active_transportation:/usr/node/ shst:latest /bin/bash
# e.g. on a Windows machine:
#     docker run -it --rm -v /c/Users/ywang/Documents/GitHub/Spatial-Analysis-Mapping-Projects/Project-Documentation/Active-Transportation-Plan-Data-Development:/usr/node/ shst:latest /bin/bash
# 
# First, create a folder to store match results using bike rules
# cd /usr/node/Data/shst_match
# mkdir "1_bike_rules"
# cd /.
# 
# Then you can cd to this directory, make this script executable, and run this script:
# cd /usr/node/conflation_scripts
# chmod u+x step1_batch_match_bike_rule.sh (skip this line if running on a Windows machine)
# ./step1_batch_match_bike_rule.sh (if getting "/bin/bash^M: bad interpreter: No such file or directory" error, 
#   it means this file has Windows line endings, remove them by running "sed -i -e 's/\r$//' step1_batch_match_bike_rule.sh" before this step)

for filename in ../Data/geojson/*.geojson
do
    name=$(basename "$filename" .geojson)
    echo ${name}

    echo "Matching ${name} to shst using bike routing rules"
    shst match ../Data/geojson/$name.geojson --out=../Data/shst_match/1_bike_rules/$name.out.geojson --tile-hierarchy=8 --match-bike
done
