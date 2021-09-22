#! /bin/bash
# AWS CLI Installation
# sudo apt update
# sudo apt install awscli

# VPC Created
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--query 'Vpc.{VpcId:VpcId}' \
--output text \
--region us-east-1)

echo "ID: $VPC_ID created in US-EAST-1"

aws ec2 create-tags \
--resources $VPC_ID \
--tags "Key=Name,Value=Mock_group_4" \
--region us-east-1

echo "Creating first public subnet...."

SUBNET_PUBLIC_ID1=$(aws ec2 create-subnet \
--vpc-id $VPC_ID \
--cidr-block 10.0.1.0/24 \
--query 'Subnet.{SubnetId:SubnetId}' \
--output text \
--region us-east-1)

aws ec2 create-tags \
--resources $SUBNET_PUBLIC_ID1 \
--tags "Key=Name,Value=Public_Subnet_Mock_group_4" \
--region us-east-1

echo "Creating first private subnet...."

SUBNET_PRIVATE_ID1=$(aws ec2 create-subnet \
--vpc-id $VPC_ID \
--cidr-block 10.0.3.0/24 \
--query 'Subnet.{SubnetId:SubnetId}' \
--output text \
--region us-east-1)

aws ec2 create-tags \
--resources $SUBNET_PRIVATE_ID1 \
--tags "Key=Name,Value=Private_Subnet_Mock_group_4" \
--region us-east-1


echo "ID of Public Subnet 1:$SUBNET_PUBLIC_ID1"
echo "ID of Private Subnet 1: $SUBNET_PRIVATE_ID1"

# Creating Internet Gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
--query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
--output text \
--region us-east-1)

aws ec2 create-tags \
--resources $IGW_ID \
--tags "Key=Name,Value=Internet_Gateway_Mock_group_4" \
--region us-east-1
echo " Internet Gateway ID '$IGW_ID' CREATED."

# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
--vpc-id $VPC_ID \
--internet-gateway-id $IGW_ID \
--region us-east-1
echo " Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."
echo "Creating Route Table..."

#   Create public Route Table
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
--vpc-id $VPC_ID \
--query 'RouteTable.{RouteTableId:RouteTableId}' \
--output text \
--region us-east-1)

aws ec2 create-tags \
--resources $ROUTE_TABLE_ID \
--tags "Key=Name,Value=Public_Route_Table_Mock_group_4" \
--region us-east-1

# Associating Internet Gateway with Route Table
aws ec2 create-route \
--route-table-id $ROUTE_TABLE_ID \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $IGW_ID \
--region us-east-1
echo " Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
"Route Table ID '$ROUTE_TABLE_ID'."

# Associate Public Subnet with Route Table
aws ec2 associate-route-table \
--subnet-id $SUBNET_PUBLIC_ID1 \
--route-table-id $ROUTE_TABLE_ID \
--region us-east-1
echo " Public Subnet ID '$SUBNET_PUBLIC_ID1' ASSOCIATED with Route Table
ID" \
"'$ROUTE_TABLE_ID'."

#   Create Private Route Table
PRIVATE_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
--vpc-id $VPC_ID \
--query 'RouteTable.{RouteTableId:RouteTableId}' \
--output text \
--region us-east-1)

aws ec2 create-tags \
--resources $PRIVATE_ROUTE_TABLE_ID \
--tags "Key=Name,Value=Private_Route_Table_Mock_Group4" \
--region us-east-1

#Associate Private subnet to Private Route table
aws ec2 associate-route-table \
--subnet-id $SUBNET_PRIVATE_ID1 \
--route-table-id $PRIVATE_ROUTE_TABLE_ID \
--region us-east-1

# Allocate Elastic IP Address for NAT Gateway
echo "Creating NAT Gateway..."
EIP_ALLOC_ID=$(aws ec2 allocate-address \
--domain vpc \
--query '{AllocationId:AllocationId}' \
--output text \
--region us-east-1)
echo " Elastic IP address ID '$EIP_ALLOC_ID' ALLOCATED."

# Create NAT Gateway
NAT_GW_ID=$(aws ec2 create-nat-gateway \
--subnet-id $SUBNET_PUBLIC_ID1 \
--allocation-id $EIP_ALLOC_ID \
--query 'NatGateway.{NatGatewayId:NatGatewayId}' \
--output text \
--region us-east-1)

aws ec2 create-tags \
--resources $NAT_GW_ID \
--tags "Key=Name,Value=NAT_Gateway_Mock_Group4" \
--region us-east-1