#!/bin/bash
file_name=$1 #YYMMDD-HHMM_camX_fruit_sessionY
scratch_input=$2 #src_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/input
scratch_output=$3 #dest_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/output

sleap-track \
-m "${scratch_input}/240915_163345.centroid.n=532" \
-m "${scratch_input}/240915_172626.centered_instance.n=532" \
-o "${scratch_output}/${file_name}.predictions.slp" \
--no-empty-frames \
--verbosity rich \
--batch_size 4 \
--peak_threshold 0.3 \
--tracking.tracker simple \
"${scratch_input}/${file_name}.mp4"