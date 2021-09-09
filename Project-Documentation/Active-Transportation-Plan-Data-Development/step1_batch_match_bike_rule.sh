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
#     docker run -it --rm -v /c/Users/yuqiwang/Documents/5_work/active_transportation:/usr/node/ shst:latest /bin/bash

# Then you can cd to this directory, make this script executable, and run this script:
# cd /usr/node/scripts
# chmod u+x batch_match_bike_rule.sh (skip this line if running on a Windows machine)
# ./step1_batch_match_bike_rule.sh (if getting "/bin/bash^M: bad interpreter: No such file or directory" error, 
#   it means this file has Windows line endings, remove them by running "sed -i -e 's/\r$//' step1_batch_match_bike_rule.sh" before this step)

for filename in ../geojson/*.geojson
do
    name=$(basename "$filename" .geojson)
    # echo ${name}

    echo "Matching ${name} to shst using bike routing rules"
    shst match ../geojson/$name.geojson --out=../shst_match/$name.out1.geojson --tile-hierarchy=8 --match-bike
done
