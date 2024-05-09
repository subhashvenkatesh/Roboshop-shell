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
        echo -e "$2........$R FAILED $N"
    else
        echo -e "$2........$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: Try with root access $N"
else
    echo -e "$G Your a root user $N"
fi

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Downloading erland script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Downloading rabbitmq script"

dnf install rabbitmq-server -y  &>> $LOGFILE
VALIDATE $? "installing rabbitmq server"

systemctl enable rabbitmq-server  &>> $LOGFILE
VALIDATE $? "enabling rabbitmq server"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "starting rabbitmq server" 

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "seting permission"