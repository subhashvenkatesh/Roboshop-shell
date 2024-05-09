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
    echo -e "$2.....$R FAILED $N"
else
    echo -e "$2.....$G SUCCESS $N"
fi

}

if [ $ID -ne 0 ]
then
    echo -e "ERROR::$R Try with root access $N"
else
    echo -e "$G Your a root user $N"
fi   

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nignx"

systemctl start nginx  &>> $LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*  &>> $LOGFILE
VALIDATE $? "removing default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "downloading web content"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving html directory"

unzip -o /tmp/web.zip  &>> $LOGFILE
VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copying roboshop revers proxy config"

systemctl restart nginx  &>> $LOGFILE
VALIDATE $? "restart nginx"