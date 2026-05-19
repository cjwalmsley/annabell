#!/bin/bash

#./test_annabell.sh test_logfile.txt test_weights.dat test_testing_file.txt

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <logfile> <pre-training_weights> <testing_file> [--cuda]"
    exit 1
fi

LOGFILE=$1
PRETRAINED_WEIGHTS=$2
TESTING_FILE=$3
USE_CUDA=${4:-}

if command -v annabell_rocm >/dev/null 2>&1; then
    EXEC_CMD="annabell_rocm"
elif command -v annabell_cuda >/dev/null 2>&1; then
    EXEC_CMD="annabell_cuda"
else
    EXEC_CMD="annabell"
fi

if [ "$GPU_FLAG" ]; then
    echo "GPU flag is active (.cuda)"
else
    echo "GPU flag is inactive (CPU mode)"
fi

# The time command's output (stderr) is appended to the log file.
{ time (
    #turn on logging
    echo .logfile "$LOGFILE"
    #record the stats
    echo .stat
    #activate gpu mode if requested
    if [ "$USE_CUDA" ]; then
        echo .cuda
    fi
    #load the weights
    echo .load "$PRETRAINED_WEIGHTS"
    #test using the questions and answers
    echo .f "$TESTING_FILE"
    #record the stats
    echo .stat
    # output timing data
    echo .t
    #turn off logging
    echo .logfile off
    #shut down ANNABELL
    echo .q
) | "$EXEC_CMD" -pf annabell_startup_config/annabell_startup_config.txt; } 2>> "$LOGFILE"
