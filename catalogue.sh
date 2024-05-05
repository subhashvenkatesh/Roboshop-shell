#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/"$0-$TIMESTAMP.log"

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: Try with root access $N "
else
    echo -e "$G Your a root user $N"
fi