#!/bin/sh
set -e 

NUM_WORKER=4

printf "===> CLEAN UP CLUSTER \n\n"
docker-compose down

printf "\n\n===> BUILD IMAGE \n\n"   
docker-compose build

printf "\n\n===> SPIN UP WORKER NODES \n\n"  
docker-compose up -d mpi_worker
docker-compose scale mpi_worker=${NUM_WORKER} 

printf "\n\n===> SPIN UP MASTER NODE \n\n" 
docker-compose up -d mpi_master

printf "\n\n===> CLUSTER READY \n\n"

echo '                            ##         .          '
echo '                      ## ## ##        ==          '
echo '                   ## ## ## ## ##    ===          '
echo '               /"""""""""""""""""\___/ ===        '
echo '          ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~ '
echo '               \______ o           __/            '
echo '                 \    \         __/               '
echo '                  \____\_______/                  '
echo '                                                  '
echo '               Alpine MPICH Cluster v1.0          '
echo ''       
echo ' More info: https://github.com/NLKNguyen/alpine-mpich-cluster'

# echo "
#  __v_       __v_        __v_       __v_      __v_         __v_    
# (____\/{   (____\/{    (____\/{   (____\/{  (____\/{     (____\/{ 
# "
echo ''
echo '=============================================================='
echo ''

port=$(docker-compose ps | grep '\->22' | sed 's/.*0.0.0.0://g' | sed 's/->22.*//g')

echo "To run MPI programs:"
echo "  1. Login to master node at exposed port using ssh with key"
echo "     $ ssh -i ssh/id_rsa -p $port mpi@192.168.99.100"
echo "     or"
echo "     $ ssh -i ssh/id_rsa -p $port mpi@localhost"
echo ''
echo "  2. Execute MPI programs inside master node"
echo "     $ mpirun -f hosts hostname"
echo "      *--------- ^ ----------------------------------------*"
echo "      | This hostfile is automatically created upon login. |"
echo "      | It contains IP addresses of nodes in the cluster.  |"
echo "      | To recreate: $ get_hosts > hosts                   |"
echo "      * ---------------------------------------------------*"
