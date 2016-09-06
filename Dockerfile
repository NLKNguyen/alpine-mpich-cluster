FROM nlknguyen/alpine-mpich:onbuild

# # ------------------------------------------------------------
# # Build MPI project
# # ------------------------------------------------------------

# Put all build steps here

# Note: the current directory is ${WORKDIR:=/project}, which is 
# also the default directory where ${USER:=mpi} will SSH login to

COPY project/ .
RUN mpicc -o mpi_hello_world mpi_hello_world.c
