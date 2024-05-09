#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
if [ $1 -ne 0]
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

dnf install nginx -y
VALIDATE $? "Installing nginx"

systemctl enable nginx
VALIDATE $? "enabling nignx"

systemctl start nginx
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "downloading web content"

cd /usr/share/nginx/html
VALIDATE $? "moving html directory"

unzip -o /tmp/web.zip
VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "copying roboshop revers proxy config"

systemctl restart nginx 
VALIDATE $? "restart nginx"