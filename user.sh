#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
if [ $1 -ne 0 ]
then
    echo -e "$2......$R FAILED $N"
else
    echo -e "$2......$G SUCCESS $N"
fi
}


if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: Try with root access $N"
    exit 1
else
    echo -e "$G Your a Root user $N"
fi


dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "Creating user"
 else
    echo -e "Roboshop user is already exit...$Y SKIPPING $N"
 fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating Directory"
 
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "Unzipping user dependencies"

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon Reloading"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enabling user" 

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongodb repo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing client service"

mongo --host mongodb.erumamadu.online </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into mongodb"
