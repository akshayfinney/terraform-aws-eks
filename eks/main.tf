## This script defines the Terraform deploy for an AWS EKS cluster. Specifically four Jenkins cluster. 
# The main.tf file contains the provider script, access key, secret key and networking. 
provider "aws" {
    access_key = "AKIAVLIXMP4BXH4CGL4I"
    secret_key = "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"
    region = "us-east-1"
}

## Add networking in the next section ##
# Check for what AZ's are available. However, we should define it since we dont want to create something in the EU 
data "aws_availability_zones" "available" {

}

# define VPC 
# range in cidr_block is a sample range only. This needs to be updated as needed. 
resource "aws_vpc" "jenkins" {
    cidr_block = "10.0.0.0/16"
    # quotes are needed when defined name and the kubernetes cluster name since `kubectl` is called
    tags = {
        "name" = "jenkins-eks-node"
        "kubernetes.io/cluster/${var.cluster.name}" = "shared"

    }
}
# Define subnets for the cluster
resource "aws_subnet" "jenkins" {
    #we want atleast a min of 2. scale up or down as needed 
    count = 2
    # Define the AZ where we want to place the cluster 
    availability_zone = data.aws_availability_zones.available.names[count.index]
    # Env var to obtain the cidr range for vpc 
    cidr_block = "10.0.${count.index}.0/24"
    # Auto get vpc ID 
    vpc_id = "${aws_vpc.jenkins.id}"
   
    tags = {
        "name" = "jenkins-eks-node"
        "kubernetes.io/cluster/${var.cluster.name}" = "shared"

    }
}

#Define Internet gateway 
resource "aws_internet_gateway" "jenkins" {
    vpc_id = "${aws_vpc.jenkins.vpc_id}"
    
    tags = {
        "name" = "jenkins-eks"
    }
}

# Add VPC routes
resource "aws_route_table" "jenkins" {
    vpc_id = "${aws_vpc.jenkins.vpc_id}"

    route {
        # Example route only! For security reasons, only route this through VPN and not open to the whole wide world 
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.jenkins.id}"
    }
  
}

# Add route table association
resource "aws_route_table_association" "jenkins" {
   # Min of 2  
    count = 2 
    # Gather subnet ID that was previously defined 
    subnet_id = "${aws_subnet.jenkins[count.index].id}"
    # Gather route table ID from previosly defined ID 
    route_table_id = "${aws_route_table.jenkins.id}"
}




