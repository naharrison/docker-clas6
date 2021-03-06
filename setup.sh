#!/usr/bin/env bash
BLUE="\033[34m"
DEF="\033[0m"
MAG="\033[35m"
RED="\033[31m"
GREEN="\033[32m"

echo -e $BLUE"Setup for building CLAS6 software in a docker machine\n"$DEF
echo -e $GREEN"Make sure you have docker installed before running the setup\n"$DEF

if [ ! -d clas6/clas-software ]; then
  echo -e $MAG"Downloading CLAS6 software from jlabsvn.jlab.org\n"$DEF
  echo -e $BLUE"This may ask for your jlab username and password"$DEF
  svn co https://jlabsvn.jlab.org/svnroot/clas/trunk/ clas6/clas-software
fi

if [ ! -d singularity/clas-software ]; then
  cp -r clas6/clas-software singularity/clas-software
fi

#read -r -p "Would you like to skip downloding CLAS6 software? [y/N] " response
#case "$response" in
#    [yY][eE][sS]|[yY])
#        echo -e $RED"Skipping download\n"$DEF
#        ;;
#    *)
#        echo -e $BLUE"This may ask for your jlab username and password"$DEF
#        svn co https://jlabsvn.jlab.org/svnroot/clas/trunk/ clas6/clas-software
#        cp -r clas6/clas-software singularity/clas-software
#        ;;
#esac


#echo -e $MAG"\nCopying clasdb to a local copy.\n"$DEF
#echo -e $BLUE"This step involves sshing into login and linking ports 3333->3333"$DEF
#echo -e $BLUE"Then we will connect to the clasdb by linking 3333->3306"$DEF
#echo -e $BLUE"Your local machine will be connected to the clasdb so we can dump the info into"$DEF
#echo -e $BLUE"another docker container"$DEF

#read -r -p "Would you like to skip downloding clasdb? [y/N] " response

#case "$response" in
#    [yY][eE][sS]|[yY])
#        echo -e $RED"Skipping download\n"$DEF
#        ;;
#    *)
#        read -r -p "What is your jlab username: " jlabuser
#        echo -e "In a different terminal execute: \n ssh -L 3333:localhost:3333 $jlabuser@login.jlab.org -tt ssh -L 3333:clasdb.jlab.org:3306 $jlabuser@ifarm"
#        read -r -p "Once you've logged into jlab hit enter: " z
#        ;;
#esac

#if [[ "$z" ]]; then
#  echo -e $BLUE"Be patient this will take a while: "$DEF
#  mysqldump -u clas_offline -h 127.0.0.1 -P 3333 --all-databases > clasdb/clasdb.sql
#fi

echo -e $GREEN"Ready to build docker container!"$DEF
command -v docker >/dev/null 2>&1 || { echo -e >&2 $RED"Docker not installed. Install docker before continuing."$DEF; exit 1; }

username=$(whoami)
if groups $username | grep &>/dev/null '\bdocker\b'; then
    echo -e $BLUE"In Docker group can run commands without sudo"$DEF
else
    echo -e $BLUE"Add yourself to docker group so you don't have to use sudo"$DEF
    echo -e $RED"This will ask for your sudo password"$DEF
    sudo usermod -a -G docker $username
fi

echo -e $BLUE"Continuing with building mysql docker"$DEF

docker build --rm clasdb/. -t clasdb:latest

echo -e $BLUE"Continuing with building clas6 docker"$DEF

docker build --rm clas6/. -t clas6:latest

command -v singularity >/dev/null 2>&1 || { echo -e >&2 $RED"Singularity not installed. Cannot build singularity image."$DEF; exit 1; }
echo -e $BLUE"Building clas6 singularity image"$DEF
cd singularity && ./build.sh
