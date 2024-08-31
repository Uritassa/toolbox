resource "aws_autoscaling_group" "main" {
  
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  vpc_zone_identifier       = [aws_subnet.az1.id, aws_subnet.az2.id]
  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }
  target_group_arns = [aws_lb_target_group.main.arn] # add after lb target group created
  tag {
    key                 = var.name
    value               = var.name
    propagate_at_launch = true
  }

}