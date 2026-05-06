#!/bin/bash

PORT=57319

PID=$(lsof -ti :$PORT)

if [ -z "$PID" ]; then
    echo "try using the launcher again"
else
    echo "found process"
    kill -9 $PID
    echo "process terminated"
    echo "try using the launcher again"
fi
