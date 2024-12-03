#!/bin/bash
file_name=$1 #YYMMDD-HHMM_camX_fruit_sessionY
scratch_input=$2 #src_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/input
scratch_output=$3 #dest_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/output
models_path=$4 #${SCRATCH_HOME}/${PROJECT_NAME}/data/models

sleap-track \
-m "${models_path}/28112024_160236.centered_instance" \
-m "${models_path}/28112024_160236.centroid" \
-o "${scratch_output}/${file_name}.predictions.slp" \
--no-empty-frames \
--verbosity rich \
--batch_size 16 \
--tracking.tracker simple \
"${scratch_input}/${file_name}.mp4"