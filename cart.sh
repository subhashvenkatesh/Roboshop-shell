#!bin/bash

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
        echo -e "ERROR:: $R Try with root access $N"
        exit 1
    else
        echo -e " $G Your a root user $N"
    fi


    dnf module disable nodejs -y &>> $LOGFILE
    VALIDATE $? "Disabling nodejs" 

    dnf module enable nodejs:18 -y &>> $LOGFILE
    VALIDATE $? "enabling nodejs" 

    dnf install nodejs -y &>> $LOGFILE
    VALIDATE $? "Installing nodejs" 

    id roboshop
    if [ $? -ne 0 ]
    then
        useradd roboshop &>> $LOGFILE
        VALIDATE $? "creating user" 
    else
        echo -e "roboshop user already exits....$Y SKIPPING $N"
    fi

    mkdir -p /app &>> $LOGFILE
       VALIDATE $? "creating app directory"

    curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
     VALIDATE $? "downloading cart"
    cd /app

    unzip -o /tmp/cart.zip &>> $LOGFILE
    VALIDATE $? "unzipping cart"

    npm install &>> $LOGFILE
    VALIDATE $? "installing dependencies"

    cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service  &>> $LOGFILE
    VALIDATE $? "copying cart"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "daemon reloading"

    systemctl enable cart &>> $LOGFILE
    VALIDATE $? "enabling cart"

    systemctl start cart &>> $LOGFILE

    VALIDATE $? "start cart"