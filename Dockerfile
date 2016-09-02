FROM nlknguyen/alpine-mpich:onbuild

# # ------------------------------------------------------------
# # Build MPI project
# # ------------------------------------------------------------

# Put all build steps here

# Notice: the current directory is ${WORKDIR:=/project}, which is 
# also the default directory where ${USER:=mpi} will SSH login to

# # ------------------------------------------------------------
# # Start SSH Server
# # ------------------------------------------------------------
USER root
EXPOSE 22
CMD ["/usr/sbin/sshd","-D", "-e"]
