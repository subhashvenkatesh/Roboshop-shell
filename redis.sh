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
    echo -e "$2.....$R SUCCESS $N"
fi
}


if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: Try with root access $N"
    exit 1
else
    echo -e "$G Your a root user $N"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "Installing Remi repo"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "Allowing remote access"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "enabling redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "starting redis"

