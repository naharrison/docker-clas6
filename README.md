# Docker CLAS6

This github will help you to build a docker container with the CLAS6 software in it.
In order to build the container you will need to have access to jlabsvn.jlab.org to download the software.

Currently I do not have the cernlib building from source.
I have copied a version from the farm which is precompiled to for CENTOS6.
I also am working on getting a second docker container which has a copy of clasdb running inside it.

I have not attempted to run graphics from this docker container, although it should be possible, in theory.

## Requirements

### For CLAS6 container
* Access to jlab
* Subversion
* Docker
* Copy the needed files from `/group/clas/parms/` to the `clas6/parms` folder

On Debian/Ubuntu systems:
```
sudo apt-get install docker-ce subversion mysql-client
```

On RedHat/Centos systems:
```
sudo yum install docker-ce subversion mysql-client
```

### For mysql container
* Access to jlab
* Docker
* mysql-client

See instructions in [clasdb](clasdb/README.md)

## Download precompiled

I have precompiled versions of both the clas6 image and clasdb image.
The file is 6.1 GB so I haven't posted it online yet but contact me and I will find a way to get it to you.
Once the image is downloaded just load it into docker
```
docker load -i clas6.tar
```
and start the mysql server with:
```
docker run --name clasdb -e MYSQL_USER=root -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d clas6db
```

This will take a while since it is loading the databases on the first run, but it only needs to be started once on the system you want to use.
You should be able to see if it's still loading the databases by looking at the cpu usage of the container with `docker stats`. Once the cpu usage of the container has gone down the databases have been successfully loaded.

Then run the container with the CLAS6 software with:
```
docker run --link clasdb:clasdb -v`pwd`:/root/data -it clas6
```

## Build your own:
First download the CLAS6 software to `clas6/clas-software`.
```
svn co https://jlabsvn.jlab.org/svnroot/clas/trunk/ clas6/clas-software
```
You can modify or add anything you would like to `clas6/clas-software` before you build the container.
After the software is checked out, you can build the container with:
```
docker build -t clas6:test clas6/.
```
It is also possible to modify the `clas6/clas-software` and then rebuild the container by just re-running the above command.

To run the built container:
```
docker run -v`pwd`:/root/data -it clas6:test
```
Which will give you a bash shell with all the CLAS6 executables in the path.
It will also give you access to your current working directory.
This should be used for input and output of files.

## Basic docker commands:
Change name:tag with what you would like to call your container and tag it. If
you don't include the tag it will automatically be called latest.

### Building:
```
docker build -t name:tag /path/to/Dockerfile
```
### Running:
```
docker run -v`pwd`:/root/data -it name:tag
```
The `-i` means interactive terminal.
The `-t` means tty.
Combined this will give you and interactive terminal you can run any of the CLAS6 software from.
The `-v` will add a volume to the docker container.
I usually add the current working directory to the container but you can add more paths by adding additional `-v /local/path:/container/path` to the existing command line.

### Looking at containers

To see the containers that are downloaded or built on your system use `docker images` or `docker images -a`.
To see the currently running containers you can run `docker ps -a`.

### Helpful functions
You can add these helpful functions to your `.bashrc`/`.zshrc` in order to manage docker container space.

```
# docker shortcuts
docker-rm() { docker rm $(docker ps -aq); }
docker-rmi() { docker rmi $(docker images -f "dangling=true" -q); }

dclas-db() { docker run --name clasdb -p 3333:3306 -e MYSQL_USER=clas_offline -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d clasdb; }
dclas-6() { docker run --link clasdb:clasdb -v`pwd`:/root/data -it clas6; }
```

### Run a single command

You can also modify the ENTRYPOINT at the end of the container in order to just run a single command.

## To Do
- [ ] Build cernlib in the container
- [ ] Get mysql docker container working
- [ ] Get setup script working
- [ ] Include docker helper functions for bashrc
