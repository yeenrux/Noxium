#!/bin/bash

PORT=57319

PIDS=$(sudo lsof -ti :$PORT)

if [ -z "$PIDS" ]; then
    echo "try using the launcher again"
else
    echo "found process"
    echo "$PIDS" | xargs sudo kill -9
    echo "process terminated"
    echo "try using the launcher again"
fi
