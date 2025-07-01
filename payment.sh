#!/bin/bash

START_TIME=$(date +%S)
USERID=$(id -u)
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "statred and execute the skript at with: $(date)" | tee -a $LOG_FILE

#check users has root previlages or not 
if [ $USERID -ne 0 ]
then
    echo -e $R "ERROR:: please run the script with using root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto to 127
else 
    echo "you are running with the root access" | tee -a $LOG_FILE
fi

#vaildate functions takes input as exit status what command they tried to install
VALIDATE(){
if [ $1 -eq 0 ]
then
    echo "Installing $2 is... $G SUCCESS $N" | tee -a $LOG_FILE
else
    echo "Installing $2 is... $R FAILURE $N" | tee -a $LOG_FILE
    exit 1
fi
}

dnf install python3 gcc python3-devel -y $>>$LOG_FILE
VALIDATE $? "Installing python3 packages"

id roboshop
if [ $? -ne 0 ]
then
   
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE 
VALIDATE $? "Creating roboshop system user"

else 
    echo -e "System user roboshop already created... $Y Skipping $N"   
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment"

rm -rf /app/*
cd /app
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the payment"

pip3 install -r requirements.txt $>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service $>>$LOG_FILE
VALIDATE $? "Copying payment service"

systemctl daemon-reload  $>>$LOG_FILE
VALIDATE $? "Daemon reloaded"

systemctl enable payment  $>>$LOG_FILE
VALIDATE $? "Enabling payment"

systemctl start payment  $>>$LOG_FILE
VALIDATE $? "Starting payment"