#!/usr/bin/env sh

# Very basic script for taking a screenshot and then
# copying it the clipboard

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <geometry> <path>"
    exit 1
fi

# create directory if doesn't already exist
mkdir -p ~/Pictures

# 1 - Geometry
# 2 - Path
grim -g "$1" $2
wl-copy <$2
