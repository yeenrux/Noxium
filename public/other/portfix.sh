#!/bin/bash

PORT=57319

PID=$(sudo lsof -ti tcp:$PORT -sTCP:LISTEN)

if [ -z "$PID" ]; then
    echo "try using the launcher again"
else
    echo "found process"
    sudo kill -9 $PID
    echo "process terminated"
    echo "try using the launcher again"
fi
