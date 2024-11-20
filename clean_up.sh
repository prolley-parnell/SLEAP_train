#!/bin/sh
PROJECT_NAME=sleap
afs_src=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/input #s20 is the first two digits of the student number given in $USER

echo "You are cleaning up, this will delete any files left in the disk scratch spaces after running rsync"
echo "Do you wish to continue? [y/n]"

read response < /dev/tty
if [ ! "$response" = "y" ] ; then
  exit
fi

dfs_src="${project_path}/data/output"
afs_dst="/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/output"


#Make the data output path if it is not present
if [ ! -d ${afs_dst} ]; then
  mkdir -p ${afs_dst}
fi

#Synchronise the folders and move the AFS input to DFS input
rsync --archive --update --compress --progress ${dfs_src}/ ${afs_dst}
echo "${dfs_src}/ up to date with ${afs_dst}"

rm -rf ${dfs_src}
