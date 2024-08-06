#!/bin/bash

# 检查脚本是否在运行
if pgrep -f dnspod.sh > /dev/null; then
    exit 0
else
    exit 1
fi