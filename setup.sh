#!/bin/bash
#USER=$1 #sXXXXXXXX
PROJECT_NAME=sleap

echo "You are on branch scratch so are setting up the DFS for use with scratch."
echo "This unzips an input tar but this is not necessary for some scripts. It is for training."
echo "Press Ctrl+C if this is not correct and switch to the correct branch."

project_path=/home/${USER}/${PROJECT_NAME}
dfs_dst="${project_path}/data/input"

#Make the data input path if it is not present
if [ ! -d ${dfs_dst} ]; then
  mkdir -p ${dfs_dst}
fi


#Ensure that you can use the "run_experiments" wrapper
#echo 'export PATH=/home/$USER/cluster-scripts/experiments:$PATH' >> ~/.bashrc
if [ -f "${dfs_dst}/input.tar.bz2" ]; then
  tar --exclude="._*" -xjvf "${dfs_dst}/input.tar.bz2" -C "${dfs_dst}"
else
  echo "Could not find '${dfs_dst}/input.tar.bz2'"
fi
