#!/bin/sh
set -e


# shellcheck disable=SC1091
. ./.env

#######################
# TASK INDICATORS
COMMAND_UP=0
COMMAND_DOWN=0
COMMAND_RELOAD=0
COMMAND_SCALE=0
COMMAND_LOGIN=0
COMMAND_LIST=0


# Default values if providing empty
SIZE=4

#############################################
usage ()
{
    echo " Alpine MPICH Cluster"
    echo ""
    echo " USAGE: ./cluster.sh [COMMAND] [OPTIONS]"
    echo ""
    echo " Examples of [COMMAND] can be:"
    echo "      up: start cluster"
    echo "          ./cluster.sh up size=10"
    echo ""    
    echo "      scale: resize the cluster"
    echo "          ./cluster.sh scale size=30"
    echo ""
    echo "      reload: rebuild image and distribute to nodes"
    echo "          ./cluster.sh reload size=15"
    echo ""
    echo "      login: login to Docker container of MPI master node "
    echo "          ./cluster.sh login"
    echo ""     
    echo "      down: shutdown cluster"
    echo "          ./cluster.sh down"
    echo ""
    echo "      list: show running containers of cluster"
    echo "          ./cluster.sh list"
    echo ""    
    echo "      help: show this message"
    echo "          ./cluster.sh help"
    echo ""    
    echo "  "
}




HEADER="
         __v_
        (.___\/{
~^~^~^~^~^~^~^~^~^~^~^~^~\n"

down_all ()
{
    printf "\n\n===> CLEAN UP CLUSTER"

    printf "\n$HEADER"
    echo "$ docker-compose down"
    printf "\n"

    docker-compose down
}

up_registry ()
{
    printf "\n\n===> SPIN UP REGISTRY"

    printf "\n$HEADER"
    echo "$ docker-compose up -d registry"
    printf "\n"

    docker-compose up -d registry
}

generate_ssh_keys ()
{
    if [ -f ssh/id_rsa ] && [ -f ssh/id_rsa.pub ]; then
        return 0
    fi
    
    printf "\n\n===> GENERATE SSH KEYS \n\n"

    echo "$ mkdir -p ssh/ "
    printf "\n"
    mkdir -p ssh/

    echo "$ ssh-keygen -f ssh/id_rsa -t rsa -N ''"
    printf "\n"
    ssh-keygen -f ssh/id_rsa -t rsa -N ''
}

build_and_push_image ()
{
    printf "\n\n===> BUILD IMAGE"
    printf "\n$HEADER"
    echo "$ docker build -t \"$REGISTRY_ADDR:$REGISTRY_PORT/$IMAGE_NAME\" ."
    printf "\n"
    docker build -t "$REGISTRY_ADDR:$REGISTRY_PORT/$IMAGE_NAME" .

    printf "\n"

    printf "\n\n===> PUSH IMAGE TO REGISTRY"
    printf "\n$HEADER"
    echo "$ docker push \"$REGISTRY_ADDR:$REGISTRY_PORT/$IMAGE_NAME\""
    printf "\n"
    docker push "$REGISTRY_ADDR:$REGISTRY_PORT/$IMAGE_NAME"
}

up_master ()
{
    printf "\n\n===> SPIN UP MASTER NODE"
    printf "\n$HEADER"
    echo "$ docker-compose up -d master"
    printf "\n"
    docker-compose up -d master
}


up_workers ()
{
    printf "\n\n===> SPIN UP WORKER NODES"
    printf "\n$HEADER"
    echo "$ docker-compose up -d worker"
    printf "\n"
    docker-compose up -d worker

    printf "\n"
    printf "\n$HEADER"

    NUM_WORKER=$(($SIZE - 1))
    echo "$ docker-compose scale worker=$NUM_WORKER"
    printf "\n"
    docker-compose scale worker=${NUM_WORKER}
}

down_master ()
{
    printf "\n\n===> TORN DOWN MASTER NODE"
    printf "\n$HEADER"

    echo "$ docker-compose stop master && docker-compose rm -f master"
    printf "\n"
    docker-compose stop master && docker-compose rm -f master
}

down_workers ()
{
    printf "\n\n===> TORN DOWN WORKER NODES"
    printf "\n$HEADER"
    echo "$ docker-compose stop worker && docker-compose rm -f worker"
    printf "\n"
    docker-compose stop master && docker-compose rm -f master
}

list ()
{
    printf "\n\n===> LIST CONTAINERS"
    printf "\n$HEADER"
    echo "$ docker-compose ps"
    printf "\n"
    docker-compose ps
}

# get_docker_ip() {
#     docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
# }

# get_master_container_name ()
# {
#     docker-compose ps | grep 'master'| awk '{print $1}'
# }

exec_on_mpi_master_container ()
{
    docker exec -it -u mpi $(docker-compose ps | grep 'master'| awk '{print $1}') "$@"
}

show_instruction ()
{
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

    echo "To run MPI programs:"
    echo "  1. Login to master node:"
    echo "     Using Docker through command wrapper:"
    echo "     $ ./cluster.sh login"
    echo ""
    echo "     Or using SSH with keys through exposed port:"
    echo "     $ ssh -o \"StrictHostKeyChecking no\" -i ssh/id_rsa -p $SSH_PORT mpi@localhost"
    echo '       where [localhost] could be changed to the host IP of master node'
    echo ''
    echo "  2. Execute MPI programs inside master node"
    echo "     $ mpirun hostname"
    echo "      *----------------------------------------------------*"
    echo "      | Default hostfile of connected nodes in the cluster |"
    echo "      | is automatically updated at /etc/opt/hosts         |"
    echo "      | To obtain hostfile manually: $ get_hosts > hosts   |"
    echo "      * ---------------------------------------------------*"

}

#############################################

while [ "$1" != "" ];
do
    PARAM=$(echo "$1" | awk -F= '{print $1}')
    VALUE=$(echo "$1" | awk -F= '{print $2}')

    case $PARAM in
        help)
            usage
            exit
            ;;
        -i)
            show_instruction
            exit
            ;;

        login)
            COMMAND_LOGIN=1
            ;;

        up)
            COMMAND_UP=1
            ;;

        down)
            COMMAND_DOWN=1
            ;;

        reload)
            COMMAND_RELOAD=1
            ;;

        scale)
            COMMAND_SCALE=1
            ;;

        list)
            COMMAND_LIST=1
            ;;

        size)
            OPTION_SIZE=1
            [ "$VALUE" ] && SIZE=$VALUE
            ;;

        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done


if [ $COMMAND_UP -eq 1 ]; then
    down_all
    up_registry
    generate_ssh_keys
    build_and_push_image
    up_master
    up_workers
    show_instruction

elif [ $COMMAND_DOWN -eq 1 ]; then
    down_all

elif [ $COMMAND_SCALE -eq 1 ]; then
    down_master
    down_workers
    up_master
    up_workers
    show_instruction

elif [ $COMMAND_RELOAD -eq 1 ]; then
    down_master
    down_workers
    build_and_push_image
    up_master
    up_workers
    show_instruction

elif [ $COMMAND_LOGIN -eq 1 ]; then
    exec_on_mpi_master_container ash

elif [ $COMMAND_LIST -eq 1 ]; then
    list
else
    usage
fi
