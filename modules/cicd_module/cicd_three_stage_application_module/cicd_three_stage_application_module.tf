############################################################

#   Title:          Three Stage CICD Pipelines for Dev, Test, Stage and Production Environments
#   Author:         Sayuj Nath, AWS Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use    
#   File Desc:      Create three CICD Pipelines:
#                   Each pipeline contains three stages:
#                       1. Stage 1 - extract latest commit from git branch using CodesStar
#                       2. Stage 2 - Build the code using CodeBuild
#                       3. Stage 3 - Deploy the code using CodeDeploy (the production pipeline also has an approval process before deployment)
#
#                   Each pipline is used to deploy to diffeent enviornment:
#                       - Developmemt environment (server)
#                       - Test environment (server)
#                       - Stage and Production environments (cluster). This pipeline first deploys to a staging auto-scaling cluster
#                         before requesting approval to deploy to the production auto-scaling cluster.
#                   
#   Design Report:  not published in public domain
#
###########################################################


# Sets up a CICD pipeline for the development server
module "dev_three_stage_instance_deployment" {
    source = "../cicd_three_stage_instance_module"

    application_name = var.application_name
    repo_connection_arn = var.repo_connection_arn
    git_repo = var.git_repo
    git_repo_branch = var.git_repo_dev_branch
    deployment_target_name = "Development-Server"
    target_type_tag = var.dev_target_type_tag
    
    cicd_failure_notification_arn = var.cicd_failure_notification_arn

    codepipeline_role_arn = var.codepipeline_role_arn
    code_deploy_role_arn = var.code_deploy_role_arn

    codebuild_role_arn = var.codebuild_role_arn

    code_build_container_image = var.code_build_container_image

    vpc_id = var.vpc_id
    app_subnet = var.app_subnet
    app_tier_sg_id = var.app_tier_sg_id
}


# Sets up a CICD pipeline to the test server
module "test_three_stage_instance_deployment" {
    source = "../cicd_three_stage_instance_module"

    application_name = var.application_name
    repo_connection_arn = var.repo_connection_arn
    git_repo = var.git_repo
    git_repo_branch = var.git_repo_test_branch
    deployment_target_name = "Test-Server"
    target_type_tag = var.test_target_type_tag
    
    cicd_failure_notification_arn = var.cicd_failure_notification_arn

    codepipeline_role_arn = var.codepipeline_role_arn
    code_deploy_role_arn = var.code_deploy_role_arn
    
    codebuild_role_arn = var.codebuild_role_arn

    code_build_container_image = var.code_build_container_image

    vpc_id = var.vpc_id
    app_subnet = var.app_subnet
    app_tier_sg_id = var.app_tier_sg_id
}

# # deploys the CodePipeline to both the staging cluster and production cluster 
# in two stages with manual approval and attaches CodeDeploy to the
# appropriate cluster Application Load Balancer(internal and external) and Auto Scaling Groups
module "uat_prod_three_stage_cluster_deployment" {
    source = "../cicd_three_stage_cluster_module"

    application_name = var.application_name
    repo_connection_arn = var.repo_connection_arn
    git_repo = var.git_repo
    git_repo_branch = var.git_repo_prod_branch  
    stage_deployment_target_name = "Multistage-Staging-Cluster-Deployment"
    prod_deployment_target_name = "Multistage-Production-Cluster-Deployment"
    
    stage_target_type_tag = var.stage_target_type_tag
    stage_cluster_asg_id = var.stage_cluster_asg_id
    stage_cluster_alb_target_name = var.stage_cluster_alb_target_name
    
    prod_target_type_tag = var.prod_target_type_tag
    prod_cluster_asg_id = var.prod_cluster_asg_id
    prod_cluster_alb_target_name = var.prod_cluster_alb_target_name
    
    production_approval_notification_arn = var.production_approval_notification_arn
    uat_completion_approval_notification_arn = var.uat_completion_approval_notification_arn
    
    cicd_failure_notification_arn = var.cicd_failure_notification_arn

    codepipeline_role_arn = var.codepipeline_role_arn
    code_deploy_role_arn = var.code_deploy_role_arn
    
    codebuild_role_arn = var.codebuild_role_arn

    code_build_container_image = var.code_build_container_image

    vpc_id = var.vpc_id
    app_subnet = var.app_subnet
    app_tier_sg_id = var.app_tier_sg_id
}

