 #!/bin/bash
#SBATCH -p regular
#SBATCH -N 8
#SBATCH -C knl,quad,cache
#SBATCH -t 00:03:00
#SBATCH --job-name=replay_pnc_knl_414_vars
#SBATCH -o replay_pnc_knl_414_vars_%j.txt
#SBATCH -e replay_pnc_knl_414_vars_%j.err
#SBATCH --exclusive
#SBATCH -L SCRATCH
#SBATCH -A m844

NN=${SLURM_NNODES}
let NP=NN*64

export LD_LIBRARY_PATH=/opt/cray/pe/hdf5-parallel/1.10.5.2/INTEL/19.0/lib:/opt/cray/pe/netcdf-hdf5parallel/4.6.3.2/INTEL/19.0/lib:/opt/cray/pe/parallel-netcdf/1.12.0.1/INTEL/19.1/lib:${LD_LIBRARY_PATH}

OUTDIR=/global/cscratch1/sd/khl7265/FS_64_1M/scorpio/knl/pnc
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

echo "========================== Scorpio Replay PNC =========================="
>&2 echo "========================== Scorpio Replay PNC =========================="

echo "#%$: exp: scropio_replay"
echo "#%$: app: pioperf_rearr"
echo "#%$: api: pnc"
echo "#%$: decom: ${DECOM}"
echo "#%$: nframe: ${NFRAME}"
echo "#%$: nvar: ${NVAR}"
echo "#%$: rearrangers: ${REARG}"
echo "#%$: number_of_nodes: ${NN}"
echo "#%$: number_of_proc: ${NP}"

STARTTIME=`date +%s.%N`

srun -n ${NP}  -c 4 --cpu_bind=cores ./pioperf_rearr --pio-niotasks=${NP} --pio-nframes=${NFRAME} --pio-nvars=${NVAR} --pio-decompfiles="decom.dat" --pio-types=pnetcdf --pio-rearrangers=${REARG}

ENDTIME=`date +%s.%N`
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."$2}'`
echo "#%$: exe_time: $TIMEDIFF"

echo "ls -lah ${OUTDIR}"
ls -lah ${OUTDIR}
echo "lfs getstripe ${OUTDIR}"
lfs getstripe ${OUTDIR}

echo '-----+-----++------------+++++++++--+---'

