

# Set up SNS topic that notifies tester and production manager for approval
resource "aws_sns_topic" "uat_completion_approval" {
    name = "user_acceptance_test_completion_approval"
    kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "uac_completion_approval_target" {
    topic_arn = aws_sns_topic.uat_completion_approval.arn
    protocol  = "email"
    endpoint  = var.uat_tester_email
}

resource "aws_sns_topic" "app_uat_completion_approval" {
    name = "app_user_acceptance_test_completion_approval"
    kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "app_uat_completion_approval_target" {
    topic_arn = aws_sns_topic.app_uat_completion_approval.arn
    protocol  = "email"
    endpoint  = var.uat_app_approver_email
}

resource "aws_sns_topic" "production_approval" {
    name = "production_approval"
    kms_master_key_id = "alias/aws/sns"
}




// resource "aws_sns_topic_subscription" "production_approval_target" {
//     topic_arn = aws_sns_topic.production_approval.arn
//     protocol  = "email"
//     endpoint  = var.production_manager_email
// }

# Set up notifiation in the event that the CI/CD pipeline fails
resource "aws_sns_topic" "cicd_failure" {
    name = "cicd_failure"
    kms_master_key_id = "alias/aws/sns"
}

# resource "aws_sns_topic_subscription" "cicd_failure_tester_target" {
#     topic_arn = aws_sns_topic.cicd_failure.arn
#     protocol  = "email"
#     endpoint  = var.production_manager_email
# }

resource "aws_sns_topic_subscription" "cicd_failure_production_target" {
    topic_arn = aws_sns_topic.cicd_failure.arn
    protocol  = "email"
    endpoint  = var.production_manager_email
}