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

# Or you can use lapply
Rhpc_lapply(cl, 1:10, sq)

# Close the cluster
Rhpc_finalize()


