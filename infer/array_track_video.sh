#!/bin/bash
# Author(s): James Owers (james.f.owers@gmail.com)
#
# Template for running an sbatch arrayjob with a file containing a list of
# commands to run. Copy this, remove the .template, and edit as you wish to
# fit your needs.
#
# Assuming this file has been edited and renamed slurm_arrayjob.sh, here's an
# example usage:
# ```
# EXPT_FILE=experiments.txt  # <- this has a command to run on each line
# NR_EXPTS=`cat ${EXPT_FILE} | wc -l`
# MAX_PARALLEL_JOBS=12
# sbatch --array=1-${NR_EXPTS}%${MAX_PARALLEL_JOBS} array_track_video.sh $EXPT_FILE
# ```
#
# or, equivalently and as intended, with provided `run_experiment`:
# ```
# run_experiment -b array_track_video.sh -e experiments.txt -m 12
# ```


# ====================
# Options for sbatch
# ====================
# FMI about options, see https://slurm.schedmd.com/sbatch.html
# N.B. options supplied on the command line will overwrite these set here

# *** To set any of these options, remove the first comment hash '# ' ***
# i.e. `# # SBATCH ...` -> `#SBATCH ...`

# Location for stdout log - see https://slurm.schedmd.com/sbatch.html#lbAH
#SBATCH --output=/home/%u/slogs/slurm-%A_%a.out

# Location for stderr log - see https://slurm.schedmd.com/sbatch.html#lbAH
#SBATCH --error=/home/%u/slogs/slurm-%A_%a.out

# Maximum number of nodes to use for the job
#SBATCH --nodes=1

# Generic resources to use - typically you'll want gpu:n to get n gpus
#SBATCH --gres=gpu:1

# Megabytes of RAM required. Check `cluster-status` for node configurations
#SBATCH --mem=23000

# Number of CPUs to use. Check `cluster-status` for node configurations
#SBATCH --cpus-per-task=1

# Maximum time for the job to run, format: days-hours:minutes:seconds
#SBATCH --time=0-04:00:00

# Partition of the cluster to pick nodes from (check `sinfo`)
#SBATCH --partition=PGR-Standard

# Any nodes to exclude from selection
#SBATCH --exclude=damnii[01-12]


# =====================
# Logging information
# =====================

# slurm info - more at https://slurm.schedmd.com/sbatch.html#lbAJ
echo "Job running on ${SLURM_JOB_NODELIST}"

dt=$(date '+%d/%m/%Y %H:%M:%S')
echo "Job started: $dt"


# ===================
# Environment setup
# ===================

echo "Setting up bash environment"

# Make available all commands on $PATH as on headnode
source ~/.bashrc

# Make script bail out after first error
set -e

# Make your own folder on the node's scratch disk
# N.B. disk could be at /disk/scratch_big, or /disk/scratch_fast. Check
# yourself using an interactive session, or check the docs:
#     http://computing.help.inf.ed.ac.uk/cluster-computing
SCRATCH_DISK=/disk/scratch
SCRATCH_HOME=${SCRATCH_DISK}/${USER}
mkdir -p ${SCRATCH_HOME}

# Activate your conda environment
CONDA_ENV_NAME=sleap
echo "Activating conda environment: ${CONDA_ENV_NAME}"
conda activate ${CONDA_ENV_NAME}


# =================================
# Move input data to scratch disk
# =================================
# Move data from a source location, probably on the distributed filesystem
# (DFS), to the scratch space on the selected node. Your code should read and
# write data on the scratch space attached directly to the compute node (i.e.
# not distributed), *not* the DFS. Writing/reading from the DFS is extremely
# slow because the data must stay consistent on *all* nodes. This constraint
# results in much network traffic and waiting time for you!
#
# This example assumes you have a folder containing all your input data on the
# DFS, and it copies all that data  file to the scratch space, and unzips it.
#
# For more guidelines about moving files between the distributed filesystem and
# the scratch space on the nodes, see:
#     http://computing.help.inf.ed.ac.uk/cluster-tips

echo "Moving input data to the compute node's scratch space: $SCRATCH_DISK"

project_name=sleap

#Move the model folders across too
DFS_HOME=/home/${USER}

models="${project_name}/data/models"
input="${project_name}/data/input"
output="${project_name}/data/output"
# model data directory path on the DFS
dfs_models_path="${DFS_HOME}/${models}"
# input data directory path on the DFS
dfs_input_path="${DFS_HOME}/${input}"
dfs_output_path="${DFS_HOME}/${output}"

# model data directory path on the scratch disk of the node
scratch_models_path="${SCRATCH_HOME}/${models}"
scratch_input_path="${SCRATCH_HOME}/${input}"
scratch_output_path="${SCRATCH_HOME}/${output}"

mkdir -p ${scratch_models_path}  # make it if required

rsync --archive --update --compress --progress ${dfs_models_path}/ ${scratch_models_path}
echo "${scratch_models_path}/ is up to date with ${dfs_models_path}"


# ==============================
# Finally, run the experiment!
# ==============================
# Read line number ${SLURM_ARRAY_TASK_ID} from the experiment file and run it
# ${SLURM_ARRAY_TASK_ID} is simply the number of the job within the array. If
# you execute `sbatch --array=1:100 ...` the jobs will get numbers 1 to 100
# inclusive.

# input data directory path on the scratch disk of the node
mkdir -p ${scratch_input_path}  # make it if required
mkdir -p ${scratch_output_path}

experiment_text_file=$1
data_file="`sed \"${SLURM_ARRAY_TASK_ID}q;d\" ${experiment_text_file}`"



# Added to move only the video being analysed to the drive, rather than whole input
rsync --archive --update --compress --progress "${dfs_input_path}/${data_file}.mp4" ${scratch_input_path}
echo "${dfs_input_path}/${data_file} is up to date with ${scratch_input_path}"

echo "Analysing ${data_file}"
bash track_video.sh ${data_file} ${scratch_input_path} ${scratch_output_path} ${scratch_models_path}
echo "Command ran successfully!"


# ======================================
# Move output data from scratch to DFS
# ======================================
# This presumes your command wrote data to some known directory. In this
# example, send it back to the DFS with rsync

echo "Moving output data back to DFS"

rsync --archive --update --compress --progress ${scratch_output_path}/ ${dfs_output_path}


# =========================
# Post experiment logging
# =========================
echo ""
echo "============"
echo "job finished successfully"
dt=$(date '+%d/%m/%Y %H:%M:%S')
echo "Job finished: $dt"