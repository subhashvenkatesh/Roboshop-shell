#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$IMESTAMP.log"

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo -e "$2.....$R FAILED $N"
else
    echo -e "$2.....$G SUCCESS $N"
fi

}

if [ ID -ne 0 ]
then
    echo -e "$R ERROR:: Try with root user $N"
else
    echo -e "$G Your a root user $N"
fi

cp mongo.repo /etc/yum.repos.d/ &>> $LOGFILE
 
VALIDATE $? "copying mongo.repo" 

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "installing mongdb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "enabling mongdb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongdb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "enabling remote access"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "restarting mongodb"