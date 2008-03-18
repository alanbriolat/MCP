#!/bin/bash
#
# Simple script for converting a sound sample to assembly
#
sox $1 -t dat -r 8000 -c 1 -u -1 - | grep -v "^;" | sed "s/ \+[\.0-9]* \+//g" | `dirname $0`/dat2unsigned.py
