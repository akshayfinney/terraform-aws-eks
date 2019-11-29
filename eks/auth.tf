## This script defines the IAM role needed for Terraform to access the eks cluster 
#The below is an example IAM role and policy to allow the EKS service to manage or retrieve data from other AWS services. 
resource "aws_iam_role" "jenkins-node" {
    name = "jenkins-eks-cluster"

    # Allow assume role and define the IAM policy. IAM policies will have to be standard JSON
    assume_role_policy = <<POLICY
    {
        "Version" : "2012-10-17",
        "Statement" : [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazon.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]


    }
    POLICY
}

## Define policy attachment for the cluster ! 
# Make sure ARN is good. Otherwise wont work ! 
resource "aws_iam_role_policy_attachment" "jenkins-awseksclusterpolicy" {
    policy_arn = "arn:aws:iam::aws:policy/awseksclusterpolicy"
    role = "${aws_iam_role.jenkins-node.name}"
  
}

## Define the policy for the service ! 
resource "aws_iam_role_policy_attachment" "jenkins-awseksservicepolicy" {
    policy_arn = "arn:aws:iam::aws:policy/awseksservicepolicy"
    role = "${aws_iam_role.jenkins-node.name}"
}

