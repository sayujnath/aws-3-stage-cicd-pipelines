
output "production_approval_notification_arn" {
    value = aws_sns_topic.production_approval.arn
    description = "Arn of the notification topic to request approval of submitting code into production"
}


output "uat_completion_approval_notification_arn" {
    value = aws_sns_topic.uat_completion_approval.arn
    description = "Arn of the notification topic to request approval of user acceptance test completion status"
}

output "app_uat_completion_approval_notification_arn" {
    value = aws_sns_topic.app_uat_completion_approval.arn
    description = "Arn of the notification topic to request approval of user acceptance test completion status . This is used only by the  app Service"
}

output "cicd_failure_notification_arn" {
    value = aws_sns_topic.cicd_failure.arn
    description = "Arn of the notification topic on event of cicd failure"
}