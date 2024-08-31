resource "aws_iam_role" "role" {
    name               = var.name
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect    = "Allow",
        Principal = {
            Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
        }]
    })

}

resource "aws_iam_policy" "policy" {
    name        = var.name
    description = "Policy to manage network interfaces for EC2 instances"
    policy      = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect    = "Allow",
        Action    = [
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:AttachNetworkInterface",
            "ec2:DetachNetworkInterface",
            "ec2:DeleteNetworkInterface"
        ],
        Resource  = "*"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "policy2role" {
    role       = aws_iam_role.role.name
    policy_arn = aws_iam_policy.policy.arn
}


resource "aws_iam_instance_profile" "instance_profile" {
    name = var.name
    role = aws_iam_role.role.name
}