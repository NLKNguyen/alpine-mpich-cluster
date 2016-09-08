#!/bin/sh

set -e

source ./.env

NUM_WORKER=4

printf "===> CLEAN UP CLUSTER \n\n"
docker-compose down

printf "\n\n===> SPIN UP REGISTRY \n\n" 
docker-compose up -d registry

printf "\n\n===> BUILD IMAGE \n\n"   
docker build -t localhost:${REGISTRY_PORT}/alpine-mpich-node .

printf "\n\n===> PUSH IMAGE TO REGISTRY \n\n" 
docker push localhost:${REGISTRY_PORT}/alpine-mpich-node

printf "\n\n===> SPIN UP MASTER NODE \n\n" 
docker-compose up -d master

printf "\n\n===> SPIN UP WORKER NODES \n\n"  
docker-compose up -d worker
docker-compose scale worker=${NUM_WORKER} 



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
echo ''
echo '=============================================================='
echo ''

# port=$(docker-compose ps | grep '\->22' | sed 's/.*0.0.0.0://g' | sed 's/->22.*//g')

echo "To run MPI programs:"
echo "  1. Login to master node at exposed port using ssh with key"
echo "     $ ssh -i ssh/id_rsa -p $SSH_PORT mpi@192.168.99.100"
echo "     or"
echo "     $ ssh -i ssh/id_rsa -p $SSH_PORT mpi@localhost"
echo ''
echo "  2. Execute MPI programs inside master node"
echo "     $ mpirun hostname"
echo "      *----------------------------------------------------*"
echo "      | Default hostfile of connected nodes in the cluster |"
echo "      | is automatically updated at /etc/opt/hosts         |"
echo "      | To obtain hostfile manually: $ get_hosts > hosts   |"
echo "      * ---------------------------------------------------*"
