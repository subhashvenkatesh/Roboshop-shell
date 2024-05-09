#!/bin/bash

ID=$( id -u )

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
else
    echo -e "$G Your a root user $N"
fi

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing Maven"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "user is already existing ....$Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading shipping file"

cd /app &>> $LOGFILE
VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming jar file"

cp /home/centos/roboshop.shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying Shipping service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reloding"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql"

mysql -h mysql.erumamadu.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Loading data into mysql"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping"
