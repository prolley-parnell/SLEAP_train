#!/bin/sh
#Run this from device connected to drive with data
USER=$1 #sXXXXXXX
input_folder=$2 #Path to the /data folder that contains an input directory that is not zipped
PROJECT_NAME=sleap
afs_project_path=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME} #The s20 is the first two numbers of the user student number

echo "You are on branch afs so are setting up the AFS."
echo "Press Ctrl+C if this is not correct and switch to the correct branch."
echo ${USER}


#Make the project path in AFS if it does not exist already
if [ ! -d "${afs_project_path}" ]; then
  mkdir -p ${afs_project_path}
fi

#If there is no data/input folder in the project folder, then make it.
afs_dst="${afs_project_path}/data/input"

if [ ! -d ${afs_dst} ]; then
  mkdir -p ${afs_dst}
fi

if [ ! -f "${afs_dst}/input.tar.bz2" ]; then
  cd ${input_folder}
  tar --no-xattrs --exclude="._*" -cjvf input.tar.bz2 input
  mv input.tar.bz2 ${afs_dst}
fi

