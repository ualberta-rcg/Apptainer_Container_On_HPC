#!/bin/bash
#SBATCH --account=def-sponsor00
#SBATCH --job-name=rstudio
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1         # Adjust CPU resources as needed
#SBATCH --mem=4G                 # Adjust memory as needed
#SBATCH --time=00:10:00           # Set the job runtime limit
#SBATCH -o job_%j.log       # Log file
#SBATCH -e job_%j.err

# Load Apptainer module (if needed)
module load apptainer

# Define ports
RPORT=$((RANDOM % 10000 + 10000))       # Default RStudio Server port
SSHPORT=$((RANDOM % 20000 + 20000))     # Random number from 20000-40000

# Work directory for Apptainer
WORKDIR="$HOME/rstudio/job_$SLURM_JOB_ID"
mkdir -p $WORKDIR
mkdir $WORKDIR/lib
mkdir $WORKDIR/run

# Get compute node hostname
NODE_HOSTNAME=$(hostname)

echo "Job running on: $NODE_HOSTNAME"
echo "Setting up SSH tunnel for RStudio..."

# Show access instructions
echo -e "\nTo connect to RStudio from your local machine, run:"
LOGIN="nibi.alliancecan.ca"     # login host (sometimes same as gateway)

echo -e "\nIf you connect through a gateway, run this from your laptop:"
echo -e "ssh -N -L ${SSHPORT}:${NODE_HOSTNAME}:${RPORT} ${USER}@${LOGIN}"
echo -e "Then open:  http://localhost:${SSHPORT}\n"
echo -e "Once the analysis is done, please type the following to cancel the job\n"
echo -e "scancel ${SLURM_JOB_ID}\n"


# Start rstudio
apptainer exec --workdir $WORKDIR --home $PWD --bind $WORKDIR/lib:/var/lib/rstudio-server --bind $WORKDIR/run:/var/run/rstudio-server ./rstudio_latest.sif rserver --www-port=$RPORT --server-daemonize=0 --server-user=$(whoami)
