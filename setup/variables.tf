

variable "application_name" {
    type = string
    description = "Name of application being deployed"
}


variable "bitbucket_source_arn" {
    type    = string
    description = "The arn for the bitbucket connection"
}

variable "git_account" {
    type    = string
    description = "The name of the account where all the code resides"
}

variable "git_prod_branch" {
    type = string
    description = "The repo branch with live production code"
}

variable "git_test_branch" {
    type = string
    description = "The repo branch with code for automated testing and staging"
}

variable "git_dev_branch" {
    type = string
    description = "The repo branch to test out and debug new features"
}

variable "emails" {
    type = map
    description = "Map of emails who that receive CICD niotifications"
}

variable "code_build_container_image"    {
    type = string
    description = "ECR container image with build environment"
}
