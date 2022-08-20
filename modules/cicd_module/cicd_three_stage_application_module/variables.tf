
variable dev_account {
    type = string
    default = ""
    description = "This is the number of the development account which owns the AMI that will be used"
}

variable region {
    type    = string
    default = "us-east-1"       # the detault is the sandbox region (Ohio)
    description = "Set this to the region to deploy resources. Ensure the region has at least three availiability zones"
        validation {
        condition     = contains(["us-east-1", "us-east-2", "ap-southeast-2"], var.region)
        error_message = "Allowed values for 'region' parameter are 'us-east-1' and 'ap-southeast-2'."
    }
}


variable "application_name"    {
    type = string
    description = "Name of the code pipeline"
}

variable "repo_connection_arn" {
    type = string
    default = "No production report url provided"
    description = "This is the connection ARN to the repository."
}

variable "git_repo" {
    type = string
    description = "GitHib repository where the code resides"
}

variable "git_repo_dev_branch" {
    type = string
    description = "GitHub repository development branch with the code that needs to be unit tested."
}

variable "git_repo_test_branch" {
    type = string
    description = "GitHub repository test branch with the code that needs to be integration tested."
}

variable "git_repo_prod_branch" {
    type = string
    description = "GitHub repository test branch with the code that needs to be deployed to production."
}

variable "git_repo_sync_branch" {
    type = string
    description = "GitHub repository sync branch with the code that needs to be deployed to production."
}

variable "dev_target_type_tag" {
    type = string
    description = "Name of the type tag on the development server target or targets that will receive the code deployment."
}

variable "test_target_type_tag" {
    type = string
    description = "Name of the type tag on the test server target or targets that will receive the code deployment."
}


variable "sync_target_type_tag" {
    type = string
    description = "Name of the type tag on the sync server target or targets that will receive the code deployment."
}

variable "prod_target_type_tag" {
    type = string
    description = "Name of the type tag on the production server target or targets that will receive the code deployment."
}

variable "prod_cluster_asg_id" {
    type = string
    description = "ID of the Autoscaling group used by the production cluster to scale EC2 instances"
}

variable "prod_cluster_alb_target_name" {
    type = string
    description = "The name of the production server target cluster that that will receive deployed code from CodeDeploy"
}

variable "stage_target_type_tag" {
    type = string
    description = "Name of the type tag on the staging server target or targets that will receive the code deployment."
}

variable "stage_cluster_asg_id" {
    type = string
    description = "ID of the Autoscaling group used by the staging cluster to scale EC2 instances"
}

variable "stage_cluster_alb_target_name" {
    type = string
    description = "The name of the staging server target cluster that that will receive deployed code from CodeDeploy"
}





# variable "deployment_dev_target_name" {
#     type = string
#     description = "Name of the development target that will receive the code deployment."
# }

# variable "deployment_test_target_name" {
#     type = string
#     description = "Name of the target that will receive the code deployment."
# }

# variable "deployment_prod_target_name" {
#     type = string
#     description = "Name of the target that will receive the code deployment."
# }




variable "production_approval_notification_arn" {
    type = string
    description = "Arn of the notification topic to request approval of user acceptance testing after deployment of stage 1"
}

variable "prod_approve_url" {
    type = string
    default = "No production report url provided"
    description = "http url to the production report created from testing commited code on the test server."
}

variable "uat_completion_approval_notification_arn" {
    type = string
    description = "Arn of the notification topic to request approval of user acceptance testing after deployment of stage 1"
}

variable "uat_approve_url" {
    type = string
    default = "No test report url provided"
    description = "http url to the test report created from testing commited code on the test server "
}

variable "cicd_failure_notification_arn" {
    type = string
    description = "Arn of the notification topic on event of cicd failure"
}

# variable "prod_cluster_asg_id" {
#     type = string
#     description = "ID of the Autoscaking group used by the production cluster to scale EC2 instances"
# }

# variable "prod_alb_target_name" {
#     type = string
#     description = "The name of thethe production target that that will receive deployed code from CodeDeploy"
# }

# variable "prod_approve_url" {
#     type = string
#     default = "No production report url provided"
#     description = "http url to the production report created from testing commited code on the test server."
# }

variable "codepipeline_role_arn"    {
    type = string
    description = "This is the IAM role tha code pipeline assumes to perform ooperations"
}

variable "codebuild_role_arn"    {
    type = string
    description = "This is the IAM role tha codebuild assumes to perform ooperations"
}


variable "code_deploy_role_arn"    {
    type = string
    description = "This is the IAM role tha code deploy assumes to perform ooperations"
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