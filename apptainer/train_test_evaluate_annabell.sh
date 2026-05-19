#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${1:-ANNABELL_LATEST}"
GPU_FLAG="${2:-}"

if [[ ! "$IMAGE_NAME" == *.sif ]]; then
    IMAGE_NAME="${IMAGE_NAME}.sif"
fi

IMAGE_PATH="$SCRIPT_DIR/$IMAGE_NAME"

TRAIN_LOGFILE="train_logfile.txt"
TRAINING_FILE="test_training_file.txt"
WEIGHTS_FILE="test_weights.dat"
TEST_LOGFILE="test_logfile.txt"
TESTING_FILE="test_testing_file.txt"

if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "ERROR: Apptainer image not found: $IMAGE_PATH"
    exit 1
fi

case "$(uname -s)" in
    Darwin)
        if ! command -v limactl >/dev/null 2>&1; then
            echo "ERROR: limactl is required on macOS but was not found in PATH"
            exit 1
        fi
        # Depending on host requirements you can add --nv or --rocm logic into the limactl pipeline
        APPTAINER_CMD=(limactl shell apptainer -- apptainer)
        ;;
    Linux)
        APPTAINER_CMD=(apptainer)
        ;;
    *)
        echo "ERROR: unsupported platform: $(uname -s)"
        exit 1
        ;;
esac

# When using GPU we dynamically inject the run flag onto the container launcher

if [[ "$GPU_FLAG" == "--cuda" ]]; then
    APPTAINER_EXEC_FLAGS=("--nv")
elif [[ "$GPU_FLAG" == "--rocm" ]]; then
    APPTAINER_EXEC_FLAGS=("--rocm")
else
    APPTAINER_EXEC_FLAGS=()
fi

if [ "$GPU_FLAG" ]; then
    echo "GPU flag is active (.cuda)"
else
    echo "GPU flag is inactive (CPU mode)"
fi

# Run training and testing inside the container.
"${APPTAINER_CMD[@]}" exec "${APPTAINER_EXEC_FLAGS[@]}" --bind "$SCRIPT_DIR:/workspace" "$IMAGE_PATH" bash -lc "
set -euo pipefail
cd /workspace
chmod +x ./train_annabell.sh ./test_annabell.sh
./train_annabell.sh '$TRAIN_LOGFILE' '$TRAINING_FILE' '$WEIGHTS_FILE' '$GPU_FLAG'
./test_annabell.sh '$TEST_LOGFILE' '$WEIGHTS_FILE' '$TESTING_FILE' '$GPU_FLAG'
"

EXPECTED_BLOCK=$(cat <<'EOF'
#id: 5726a950dd62a815002e8c4b
? when was the Bronze Age
.x
 -> prehistoric period
.
prehistoric period
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