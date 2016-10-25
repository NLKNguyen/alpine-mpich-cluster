Alpine MPICH Cluster
====================

Using:
* Docker Swarm Mode
* Docker Compose version 2

## Dockerfile


## config.env file

Configuration file that contains environment variables for both `docker-compose.yml` and `cluster.sh`

## cluster.sh script

Use this POSIX shell script to automate common commands on the cluster of MPI-ready Docker containers.

In your shell where Docker is available, navigate to the project directory.

To run the script directly, make sure the file has executable permission `chmod +x cluster.sh`
```
./cluster.sh [COMMAND] [OPTIONS]
```

Or regardless of executable permission

```
sh cluster.sh [COMMAND] [OPTIONS]
```

Examples where `[COMMAND]` can be:

**up**
```
./cluster.sh up size=10
```
It will:
- shutdown existing services before starting all the services
- spin up an image registry container
- build the image using the Dockerfile
- push the image to the registry
- spin up `n` containers using the image in the registry, where n is the provided size. 
    - 1 container serves as MPI master
    - n-1 containers serve as MPI workers.

The MPI containers will be distributed evenly accross the Docker Swarm cluster. 


**scale**
```
./cluster.sh scale size=20
```
It will:
- shutdown MPI containers
- start `n` MPI containers using the same image existing in the image registry.


**reload**
```
./cluster.sh reload size=20
```
It will:
- shutdown MPI containers
- rebuild image and push to existing image registry
- spin up `n` containers using the image in the registry, where n is the provided size. 
    - 1 container serves as MPI master
    - n-1 containers serve as MPI workers.


**down**
```
./cluster.sh down
```
It will:
- shutdown everything



