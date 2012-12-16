#!/bin/sh
cd $PBS_O_WORKDIR
module load openmpi-psm-gcc

RUNPATH=runpath
EXEPATH=/home/jason/lammps/lammps-2Nov10/src

cd $RUNPATH

mpirun -np `cat $PBS_NODEFILE | wc -l` $EXEPATH/lmp_generic < $RUNPATH/LMP_TEMP

