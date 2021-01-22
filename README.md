## Set up

First we need to load the necessary modules and install [`Rhpc`](https://cran.r-project.org/package=Rhpc). Once you have logged into Artemis proceed with the following:

```
module load R/4.0.0
module load openmpi-gcc/4.0.3
```

Once you have loaded those modules, install the Rhpc package with:

`Rscript -e 'install.packages("Rhpc", repos="https://cloud.r-project.org")'`

After that you are ready to submit a job.

## PBS Script

Here is an example PBS script, which can also be downloaded from the file `Rhpc_example.pbs` above. This job will select 2 nodes, each containing 2 CPU cores and 1GB of memory each for a combined 4 CPU cores and 2GB of memory.

```bash
#!/bin/bash

#PBS -N Rhpc_example
#PBS -P Add your project name here
#PBS -l select=2:ncpus=2:mpiprocs=2:mem=1GB
#PBS -l walltime=00:02:00
#PBS -q defaultQ

cd $PBS_O_WORKDIR

module load R/4.0.0
module load openmpi-gcc/4.0.3

mpiexec -machinefile $PBS_NODEFILE ~/R/x86_64-pc-linux-gnu-library/4.0/Rhpc/Rhpc CMD BATCH --no-save Rhpc_example.R
```

## R script

This basic script will calculate the square of a number and tell you which node and compute core it was calculated on.

```r
library(Rhpc)

# Example function that returns the square of a number
sq = function(x) {
  print(sprintf('%d squared is %d. Calculated on rank %d on node %s',
                x, x^2, options('Rhpc.mpi.rank')[[1]], Sys.info()['nodename']))
  return(x^2)
}

# Initialise
Rhpc_initialize()

# Setup the cluster
cl = Rhpc_getHandle()

# Parallel sapply
Rhpc_sapply(cl, 1:10, sq)

# Or you could use lapply
# Rhpc_lapply(cl, 1:10, sq)

# Close the cluster
Rhpc_finalize()
```

Submit the job (`qsub Rhpc_example.pbs`) and if all goes well, you should see a file named `Rhpc_example.Rout` which will contain:

```
> library(Rhpc)
> 
> # Example function that returns the square of a number
> sq = function(x) {
+   print(sprintf('%d squared is %d. Calculated on rank %d on node %s',
+                 x, x^2, options('Rhpc.mpi.rank')[[1]], Sys.info()['nodename']))
+   return(x^2)
+ }
> 
> # Initialise
> Rhpc_initialize()
reload mpi library /usr/local/openmpi/4.0.3-gcc/lib/libmpi.so.40
 rank/procs(     f.comm) : processor_name                   :   pid
    0/    4(          0) : hpc024                           : 153002
    1/    4(          0) : hpc024                           : 152997
    2/    4(          0) : hpc026                           : 168510
    3/    4(          0) : hpc026                           : 168511
> 
> # Setup the cluster
> cl = Rhpc_getHandle()
Detected communication size 4
> 
> # Parallel sapply
> Rhpc_sapply(cl, 1:10, sq)
 [1]   1   4   9  16  25  36  49  64  81 100
> 
> # Or you could use lapply
> # Rhpc_lapply(cl, 1:10, sq)
> 
> # Close the cluster
> Rhpc_finalize()
> 
> proc.time()
   user  system elapsed 
  0.382   0.093   2.706
```

And the standard output will be written to a file `Rhpc_example.o` which contains the printed statements from the `sq` function:
```
[1] "1 squared is 1. Calculated on rank 1 on node hpc024"
[1] "2 squared is 4. Calculated on rank 2 on node hpc026"
[1] "3 squared is 9. Calculated on rank 3 on node hpc026"
[1] "4 squared is 16. Calculated on rank 1 on node hpc024"
[1] "7 squared is 49. Calculated on rank 1 on node hpc024"
[1] "10 squared is 100. Calculated on rank 1 on node hpc024"
[1] "5 squared is 25. Calculated on rank 2 on node hpc026"
[1] "8 squared is 64. Calculated on rank 2 on node hpc026"
[1] "6 squared is 36. Calculated on rank 3 on node hpc026"
[1] "9 squared is 81. Calculated on rank 3 on node hpc026"
```
