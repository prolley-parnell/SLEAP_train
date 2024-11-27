#USER=$1 #sXXXXXXXX
PROJECT_NAME=sleap
afs_input_path=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/input #s20 is the first two digits of the student number given in $USER
afs_model_path=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/models #s20 is the first two digits of the student number given in $USER

echo "You are on branch dfs so are setting up the DFS."
echo "Press Ctrl+C if this is not correct and switch to the correct branch."

#Install miniconda if it is not already installed
conda_path=/home/${USER}/miniconda3
if [ ! -d "${conda_path}" ]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "${conda_path}"/miniconda.sh
  bash "${conda_path}"/miniconda.sh -b -u
  rm "${conda_path}"/miniconda.sh
  source "${conda_path}"/bin/activate
  conda init --all
  conda config --set auto_activate_base false
fi

dfs_project_path=/home/${USER}/${PROJECT_NAME}

#Make the project path if it is not present
if [ ! -d "${dfs_project_path}" ]; then
  mkdir -p ${dfs_project_path}
fi

dfs_input_path="${dfs_project_path}/data/input"

#Make the data input path if it is not present
if [ ! -d ${dfs_input_path} ]; then
  mkdir -p ${dfs_input_path}
fi

#Synchronise the folders and move the AFS input to DFS input
rsync --archive --update --compress --progress ${afs_input_path}/ ${dfs_input_path}

echo "${afs_input_path}/ up to date with ${dfs_input_path}"

# --- Move models from AFS --- #
dfs_model_path="${dfs_project_path}/data/models"

#Make the model input path if it is not present
if [ ! -d ${dfs_model_path} ]; then
  mkdir -p ${dfs_model_path}
fi

#Synchronise the folders and move the AFS models to DFS models
rsync --archive --update --compress --progress ${afs_model_path}/ ${dfs_model_path}

echo "${afs_model_path}/ up to date with ${dfs_model_path}"

#Install SLEAP through conda
source ~/.bashrc

if { ! conda env list | grep 'sleap'; } >/dev/null 2>&1; then
  TMPDIR="${dfs_project_path}/tmp"
  TMP="${TMPDIR}"
  TEMP="${TMPDIR}"
  mkdir -p "${TMPDIR}"
  export TMPDIR TMP TEMP
  conda create -y -n sleap -c conda-forge -c nvidia -c sleap -c anaconda sleap=1.3.3
  conda deactivate
  rm -rf ${TMPDIR}
fi

#Ensure that you can use the "run_experiments" wrapper
#echo 'export PATH=/home/$USER/cluster-scripts/experiments:$PATH' >> ~/.bashrc
if [ -f "${dfs_input_path}/input.tar.bz2" ]; then
  tar --exclude="._*" -xjvf "${dfs_input_path}/input.tar.bz2" -C "${dfs_project_path}/data"
  rm -rf "${dfs_input_path}/input.tar.bz2"
else
  echo "Could not find '${dfs_input_path}/input.tar.bz2'"
fi
