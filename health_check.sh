#!/bin/bash

if pgrep -f dnspod.sh > /dev/null; then
    exit 0
else
    exit 1
fi