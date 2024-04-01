resource "aws_cloudwatch_event_rule" "ip_to_slack" {
    name        = "ip-to-slack"
    
    event_pattern = jsonencode({
        source = [
            "aws.autoscaling"
        ]

        detail-type = [
            "EC2 Instance Launch Successful"
        ]

        detail = {
            AutoScalingGroupName = [
                "${var.ecs_asg_name}"
            ]
        }
    })
}

resource "aws_cloudwatch_event_target" "ip_to_slack" {
    arn       = var.ip_update_to_slack_lambda_arn
    rule      = aws_cloudwatch_event_rule.ip_to_slack.name
}

resource "aws_lambda_permission" "ip_update_to_slack_lambda_permissionn" { // ??
    action = "lambda:InvokeFunction"
    function_name = var.ip_update_to_slack_lambda_arn
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.ip_to_slack.arn
}
