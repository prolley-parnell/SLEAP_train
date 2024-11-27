#!/bin/sh
PROJECT_NAME=sleap
project_path=/home/${USER}/${PROJECT_NAME}

echo "You are cleaning up, this will delete any output files left in the disk scratch spaces after running rsync"
echo "Do you wish to continue? [y/n]"

read response < /dev/tty
if [ ! "$response" = "y" ] ; then
  exit
fi

dfs_output_path="${project_path}/data/output"
afs_output_path="/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/output"


#Make the data output path if it is not present
if [ ! -d ${afs_output_path} ]; then
  mkdir -p ${afs_output_path}
fi

#Synchronise the folders and move the AFS input to DFS input
rsync --archive --update --compress --progress ${dfs_output_path}/ ${afs_output_path}
echo "${dfs_output_path}/ up to date with ${afs_output_path}"

rm -rf ${dfs_output_path}

## ------ move model files across ------ ##
dfs_models_path="${project_path}/data/models"
afs_models_path="/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/models"


#Make the data output path if it is not present
if [ ! -d ${afs_models_path} ]; then
  mkdir -p ${afs_models_path}
fi

#Synchronise the folders and move the AFS input to DFS input
rsync --archive --update --compress --progress ${dfs_models_path}/ ${afs_models_path}
echo "${dfs_models_path}/ up to date with ${afs_models_path}"

rm -rf ${dfs_models_path}
