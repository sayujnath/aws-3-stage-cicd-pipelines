variable "application_name"    {
    type = string
    description = "Name of the code pipeline"
}

variable "repo_connection_arn" {
    type = string
    description = "This is the connection ARN to the repository."
}

variable "git_repo" {
    type = string
    description = "GitHib repository where the code resides"
}

variable "git_repo_branch" {
    type = string
    description = "GitHub repository branch with the code that needs to be tested."
}

variable "deployment_target_name" {
    type = string
    description = "Name of the target that will receive the code deployment."
}

variable "target_type_tag" {
    type = string
    description = "Name of the type tag on the target or targets that will receive the code deployment."
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