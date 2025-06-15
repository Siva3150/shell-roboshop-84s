#!/bin/bash

AMI=ami-09c813fb71547fc4f
SG_ID=sg-0eb268985a47f9c17 #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z03672276PNJXQMW5BRF # replace your zone ID
DOMAIN_NAME="sivadevops.fun"

for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-0c5d670f0272ebbe0 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done




# #!/bin/bash

# AMI_ID="ami-09c813fb71547fc4f"
# SG_ID="sg-0eb268985a47f9c17" # replace with your SG ID
# INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
# ZONE_ID="Z03672276PNJXQMW5BRF" # replace with your ZONE ID
# DOMAIN_NAME="sivadevops.fun" # replace with your domain

# #for instance in ${INSTANCES[@]}
# for instance in $@
# do
#     INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01bc7ebe005fb1cb2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
#     if [ $instance != "frontend" ]
#     then
#         IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
#         RECORD_NAME="$instance.$DOMAIN_NAME"
#     else
#         IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
#         RECORD_NAME="$DOMAIN_NAME"
#     fi
#     echo "$instance IP address: $IP"

#     aws route53 change-resource-record-sets \
#     --hosted-zone-id $ZONE_ID \
#     --change-batch '
#     {
#         "Comment": "Creating or Updating a record set for cognito endpoint"
#         ,"Changes": [{
#         "Action"              : "UPSERT"
#         ,"ResourceRecordSet"  : {
#             "Name"              : "'$RECORD_NAME'"
#             ,"Type"             : "A"
#             ,"TTL"              : 1
#             ,"ResourceRecords"  : [{
#                 "Value"         : "'$IP'"
#             }]
#         }
#         }]
#     }'
# done
