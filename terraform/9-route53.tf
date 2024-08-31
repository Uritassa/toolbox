resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = "" // TODO: replace with your domain
  type    = "A"
  ttl     = 300
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}