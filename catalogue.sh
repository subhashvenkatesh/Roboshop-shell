#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo -e "$2.....$R FAILED $N"
else
    echo -e "$2.....$G SUCCESS $N"
fi

}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: Try with root access $N"
else
    echo -e "$G Your a root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating user"

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue data"

cd /app &>> $LOGFILE

VALIDATE $? "entering directory"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "unzipping the dependencies"

npm install &>> $LOGFILE

VALIDATE $? "installing the dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reloading"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb repo"

mongo --host mongodb.erumamadu.online </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into mongodb"