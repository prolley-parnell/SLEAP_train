#!/bin/bash
scratch_input=$1 #src_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/input
scratch_output=$2 #dest_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/output
models_path=$3 #${DFS_HOME}/${PROJECT_NAME}/data/models

sleap-track \
-m "${models_path}/21112024_1200_C" \
-m "${models_path}/21112024_1200_CI" \
--no-empty-frames \
--verbosity rich \
--batch_size 16 \
--peak_threshold 0.3 \
--tracking.tracker simple \
${scratch_input}