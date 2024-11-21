#!/bin/sh
#Run this from device connected to drive with data
USER=$1 #sXXXXXXX
data_folder=$2 #Path to the /Code part of the project
PROJECT_NAME=sleap
afs_project_path=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME} #The s20 is the first two numbers of the user student number
output_dst="${data_folder}/${PROJECT_NAME}/data/output"
output_src="${afs_project_path}/data/output"

#Make the project path locally if it does not exist already
if [ ! -d "${output_dst}" ]; then
  mkdir -p ${output_dst}
fi

rsync --archive --update --compress --progress ${output_src}/ ${output_dst}

output_model_dst="${data_folder}/${PROJECT_NAME}/data/models"
output_model_src="${afs_project_path}/data/models"

#Make the project path locally if it does not exist already
if [ ! -d "${output_model_dst}" ]; then
  mkdir -p ${output_model_dst}
fi

rsync --archive --update --compress --progress ${output_model_src}/ ${output_model_dst}
