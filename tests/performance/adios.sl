 #!/bin/bash
#SBATCH -p regular
#SBATCH -N 16
#SBATCH -C haswell
#SBATCH -t 00:03:00
#SBATCH --job-name=replay_adios_414_vars
#SBATCH -o replay_adios_414_vars_%j.txt
#SBATCH -e replay_adios_414_vars_%j.err
#SBATCH -L SCRATCH
#SBATCH -A m844

NN=${SLURM_NNODES}
let NP=NN*32

export LD_LIBRARY_PATH=/global/homes/k/khl7265/.local/adios2/2.7.1/lib64/:/global/homes/k/khl7265/.local/pnetcdf/master/lib/:/global/homes/k/khl7265/.local/hdf5/1.12.0/lib/:${LD_LIBRARY_PATH}

OUTDIR=/global/cscratch1/sd/khl7265/FS_64_1M/scorpio/adios2
DECOM=/global/homes/k/khl7265/FS_64_1M/e3sm_data/decom/piodecomp_72x48602_512p.dat
NVAR=414
NFRAME=1
REARG=1

echo "mkdir -p ${OUTDIR}"
mkdir -p ${OUTDIR}
echo "rm -rf ${OUTDIR}/*"
rm -rf ${OUTDIR}/*

echo "cd ${OUTDIR}"
cd ${OUTDIR}

echo "ln -s ${DECOM} decom.dat"
ln -s ${DECOM} decom.dat

echo "ln -s ${SLURM_SUBMIT_DIR}/pioperf_rearr pioperf_rearr"
ln -s ${SLURM_SUBMIT_DIR}/pioperf_rearr pioperf_rearr

ulimit -c unlimited

TSTARTTIME=`date +%s.%N`

echo "========================== Scorpio Replay ADIOS2 =========================="
>&2 echo "========================== Scorpio Replay ADIOS2 =========================="

echo "#%$: exp: scropio_replay"
echo "#%$: app: pioperf_rearr"
echo "#%$: api: adios2"
echo "#%$: decom: ${DECOM}"
echo "#%$: nframe: ${NFRAME}"
echo "#%$: nvar: ${NVAR}"
echo "#%$: rearrangers: ${REARG}"
echo "#%$: number_of_nodes: ${NN}"
echo "#%$: number_of_proc: ${NP}"

STARTTIME=`date +%s.%N`

srun -n ${NP} ./pioperf_rearr --pio-niotasks=${NP} --pio-nframes=${NFRAME} --pio-nvars=${NVAR} --pio-decompfiles="decom.dat" --pio-types=adios --pio-rearrangers=${REARG}

ENDTIME=`date +%s.%N`
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."$2}'`
echo "#%$: exe_time: $TIMEDIFF"

echo "ls -lah ${OUTDIR}"
ls -lah ${OUTDIR}
echo "lfs getstripe ${OUTDIR}"
lfs getstripe ${OUTDIR}

echo '-----+-----++------------+++++++++--+---'

