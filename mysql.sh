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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disabling current mysql version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copied mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld  &>> $LOGFILE
VALIDATE $? "enabled mysql"

systemctl start mysqld  &>> $LOGFILE
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "setting MySql root password"
