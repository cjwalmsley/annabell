#!/bin/bash

#./train_annabell.sh train_logfile.txt test_training_file.txt test_weights.dat

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <logfile> <training_file> <pre-trained_weights> [--cuda]"
    exit 1
fi

LOGFILE=$1
TRAINING_FILE=$2
PRETRAINED_WEIGHTS=$3
USE_CUDA=${4:-}

if command -v annabell_rocm >/dev/null 2>&1; then
    EXEC_CMD="annabell_rocm"
elif command -v annabell_cuda >/dev/null 2>&1; then
    EXEC_CMD="annabell_cuda"
else
    EXEC_CMD="annabell"
fi

# The time command's output (stderr) is appended to the log file.
{ time (
#turn on logging
echo .logfile "$LOGFILE"
#record the stats
echo .stat
#activate gpu mode if requested
if [ "$USE_CUDA" = "--cuda" ]; then
    echo .cuda
fi
#train using the commands provided in the file
echo .f "$TRAINING_FILE"
#save the weights
echo .save "$PRETRAINED_WEIGHTS"
#record the stats
echo .stat
# output timing data
echo .t
#turn off logging
echo .logfile off
#shut down ANNABELL
echo .q
) | "$EXEC_CMD" -pf annabell_startup_config/annabell_startup_config.txt; } 2>> "$LOGFILE"
