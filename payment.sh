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
    echo -e "$R ERROR:: Try with root access $N"
    exit 2
else
    echo -e "$G Your a root user $N"
fi

dnf install python36 gcc python3-devel -y &>> $LOGFILE

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "user is already existing ....$Y SKIPPING $N"
fi

mkdir -p /app &>> $VALIDATE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $VALIDATE
VALIDATE $? "Downloading payment"

cd /app  &>> $VALIDATE
VALIDATE $? "changing directory into app"

unzip -o /tmp/payment.zip &>> $VALIDATE
VALIDATE $? "Unzipping payment"


pip3.6 install -r requirements.txt &>> $VALIDATE
VALIDATE $? "Installing payment dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $VALIDATE
VALIDATE $? "coping payment service"

systemctl daemon-reload &>> $VALIDATE
VALIDATE $? "Daemon loading"

systemctl enable payment &>> $VALIDATE
VALIDATE $? "enabling payment"

systemctl start payment &>> $VALIDATE
VALIDATE $? "starting payment"