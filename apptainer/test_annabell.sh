#!/bin/bash

#./test_annabell.sh test_logfile.txt test_weights.dat test_testing_file.txt

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <logfile> <pre-training_weights> <testing_file>"
    exit 1
fi

LOGFILE=$1
PRETRAINED_WEIGHTS=$2
TESTING_FILE=$3

# The time command's output (stderr) is appended to the log file.
{ time (
    #turn on logging
    echo .logfile "$LOGFILE"
    #record the stats
    echo .stat
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
) | annabell -pf annabell_startup_config/annabell_startup_config.txt; } 2>> "$LOGFILE"