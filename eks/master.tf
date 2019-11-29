#This script is to provision the actual kubernetes master cluster. This can take a few mins. 
# Be aware of the security group id's. Verify that the naming convention is accurate

resource "aws_eks_cluster" "jenkins" {
    name =  "${var.cluster-name}"
    role_arn = "${aws_iam_role.jenkins-node.arn}"

    vpc_config {
        security_group_ids = ["${aws_security_group.jenkins.id}"]
        subnet_ids = ["${aws_subnet.jenkins.*.id}"]
    }

    depends_on = [
        "${aws_iam_role_policy_attachment.jenkins-awseksclusterpolicy}",
        "${aws_iam_role_policy_attachment.jenkins-awseksservicepolicy}"
    ]
}


