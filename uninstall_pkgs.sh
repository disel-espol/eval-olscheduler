#!/usr/bin/env bash

FOLDER=/usr/local/lib/python2.7/dist-packages

for f in $FOLDER; do
	echo $f
    if [ -d ${f} ]; then
        # Will not run if no directories are available
        echo $f
    fi
done