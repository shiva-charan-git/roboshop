#!/bin/bash

##### Change these values ###
ZONE_ID="Z01050902R4BE1CZTBGLG"
DOMAIN="devsig90.online"
SG_NAME="ALLOW_ALL"
#############################



create_ec2() {
  echo -e '#!/bin/bash' >/tmp/user-data
  echo -e "\nset-hostname ${COMPONENT}" >>/tmp/user-data
  PRIVATE_IP=$(aws ec2 run-instances \
      --image-id ${AMI_ID} \
      --instance-type t3.micro \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPON                                                                                                             ENT}}, {Key=Monitor,Value=yes}]" "ResourceType=spot-instances-request,Tags=[{Key                                                                                                             =Name,Value=${COMPONENT}}]"  \
      --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=p                                                                                                             ersistent,InstanceInterruptionBehavior=stop}"\
      --security-group-ids ${SGID} \
      --user-data file:///tmp/user-data \
      | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

  sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" -e "s/DOMAI                                                                                                             N/${DOMAIN}/" route53.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-b                                                                                                             atch file:///tmp/record.json 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "Server Created - SUCCESS - DNS RECORD - ${COMPONENT}.${DOMAIN}"
  else
     echo "Server Created - FAILED - DNS RECORD - ${COMPONENT}.${DOMAIN}"
     exit 1
  fi
}


## Main Program
AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOps-Pra                                                                                                             ctice" | jq '.Images[].ImageId' | sed -e 's/"//g')
if [ -z "${AMI_ID}" ]; then
  echo "AMI_ID not found"
  exit 1
fi

SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NA                                                                                                             ME} | jq  '.SecurityGroups[].GroupId' | sed -e 's/"//g')
if [ -z "${SGID}" ]; then
  echo "Given Security Group does not exit"
  exit 1
fi


for component in catalogue cart user shipping payment frontend mongodb mysql rab                                                                                                             bitmq redis dispatch; do
  COMPONENT="${component}-dev"
  create_ec2
done
