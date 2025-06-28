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

mkdir -p $LOGS_FOLDER
echo "started and execute the script at with: $(date)" | tee -a $LOG_FILE

# check users has root privileges or not 
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: please run the script with using root access $N" | tee -a $LOG_FILE
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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis:7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"


sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connection"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling the redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "start the Redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE