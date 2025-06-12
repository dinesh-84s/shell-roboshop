#!/bash/bin

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-02ee33accb91fcb0a"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch"
"frontend")
ZONE_ID="Z09863983SQIUX95E67RN"
DOMAIN_NAME="dineskonda.site"

for instance in {INSTANCES[@]}
do 
    
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type 
    t2.micro --security-group-ids sg-02ee33accb91fcb0a --tag-specifications "ResourceType=instance,
    Tags=[{Key=Name, Value=test}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    
    then
        IP=aws ec2 describe-instances --instance-ids $INSTANCE_ID -- query "Reservations[0].
        Instances[0].PrivateIpAddress" --output text
        
    else 
        IP=aws ec2 describe-instances --instance-ids $INSTANCE_ID -- query "Reservations[0].
        Instances[0].PublicIpAddress" --output text
    fi
    echo "$Instance ip address: $IP"
done