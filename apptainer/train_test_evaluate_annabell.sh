#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_PATH="${1:-$SCRIPT_DIR/ANNABELL_LATEST.sif}"

TRAIN_LOGFILE="train_logfile.txt"
TRAINING_FILE="test_training_file.txt"
WEIGHTS_FILE="test_weights.dat"
TEST_LOGFILE="test_logfile.txt"
TESTING_FILE="test_testing_file.txt"

if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "ERROR: Apptainer image not found: $IMAGE_PATH"
    exit 1
fi

# Run training and testing inside the container with the apptainer directory bound.
apptainer exec --bind "$SCRIPT_DIR:/workspace" "$IMAGE_PATH" bash -lc "
set -euo pipefail
cd /workspace
chmod +x ./train_annabell.sh ./test_annabell.sh
./train_annabell.sh '$TRAIN_LOGFILE' '$TRAINING_FILE' '$WEIGHTS_FILE'
./test_annabell.sh '$TEST_LOGFILE' '$WEIGHTS_FILE' '$TESTING_FILE'
"

EXPECTED_BLOCK=$(cat <<'EOF'
#id: 56bfc563a10cfb14005512ca
? what word is often used to describe Beyonce
.x
 -> Bootylicious
.
Bootylicious
#END OF TESTING SAMPLE
EOF
)

if [[ ! -f "$SCRIPT_DIR/$TEST_LOGFILE" ]]; then
    echo "Unsuccessful test: logfile not found at $SCRIPT_DIR/$TEST_LOGFILE"
    exit 1
fi

LOG_CONTENT="$(cat "$SCRIPT_DIR/$TEST_LOGFILE")"

if [[ "$LOG_CONTENT" == *"$EXPECTED_BLOCK"* ]]; then
    echo "Successful test: expected output found in $TEST_LOGFILE"
    exit 0
fi

echo "Unsuccessful test: expected output not found in $TEST_LOGFILE"
exit 1