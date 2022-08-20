variable "application_name"    {
    type = string
    description = "Name of the code pipeline"
}

variable "repo_connection_arn" {
    type = string
    default = "No source code  account connection ARN provided"
    description = "This is the connection ARN to the ."
}

variable "git_repo" {
    type = string
    description = "GitHib repository where the code resides"
}

variable "git_repo_branch" {
    type = string
    description = "GitHub repository branch with the code that needs to be deployed."
}

variable "stage_deployment_target_name" {
    type = string
    description = "Name of the target that will receive the code deployment."
}

variable "prod_deployment_target_name" {
    type = string
    description = "Name of the target that will receive the code deployment."
}

variable "stage_target_type_tag" {
    type = string
    description = "Name of the type tag on the target or targets that will receive the code deployment in the first stage of the 2-stage pipeline (Staging)."
}

variable "stage_cluster_asg_id" {
    type = string
    description = "ID of the Autoscaking group used by the production cluster to scale EC2 instances in the first stage of the 2-stage pipeline (Staging)"
}

variable "stage_cluster_alb_target_name" {
    type = string
    description = "The name of the target cluster that that will receive deployed code from CodeDeploy in the first stage of the 2-stage pipeline (Staging)"
}

variable "prod_target_type_tag" {
    type = string
    description = "Name of the type tag on the target or targets that will receive the code deployment in the second stage of the 2-stage pipeline (Production)."
}

variable "prod_cluster_asg_id" {
    type = string
    description = "ID of the Autoscaking group used by the production cluster to scale EC2 instances in the second stage of the 2-stage pipeline (Production)"
}

variable "prod_cluster_alb_target_name" {
    type = string
    description = "The name of the target cluster that that will receive deployed code from CodeDeploy in the second stage of the 2-stage pipeline (Production)"
}

variable "production_approval_notification_arn" {
    type = string
    description = "Arn of the notification topic to request approval of user acceptance testing after deployment of stage 1"
}

variable "prod_approve_url" {
    type = string
    default = "No production report url provided"
    description = "http url to the production report created from testing commited code on the test server."
}

variable "stage_completion_approval_notification_arn" {
    type = string
    description = "Arn of the notification topic to request approval of user acceptance testing after deployment of stage 1"
}

variable "stage_approve_url" {
    type = string
    default = "No test report url provided"
    description = "http url to the test report created from testing commited code on the test server "
}

variable "cicd_failure_notification_arn" {
    type = string
    description = "Arn of the notification topic on event of cicd failure"
}


variable "codepipeline_role_arn"    {
    type = string
    description = "This is the IAM role tha code pipeline assumes to perform ooperations"
}

variable "code_deploy_role_arn"    {
    type = string
    description = "This is the IAM role tha code deploy assumes to perform ooperations"
}

variable "codebuild_role_arn"    {
    type = string
    description = "This is the IAM role tha codebuild assumes to perform ooperations"
}


variable "code_build_container_image"    {
    type = string
    description = "ECR container image with build environment"
}


variable "vpc_id" {
    type = string
    description = "This is the id of the vpc created in the network module"
}

variable "app_subnet" {
    type = string
    description = "The is the subnet where the compute instance will reside in."
}

variable "app_tier_sg_id" {
    type = string
    description = "This is the id of the security group to allow inbound traffic to the application tier."
}
