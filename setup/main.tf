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




module "cicd_three_stage_deployment" {
    source = "../modules/cicd_module/cicd_three_stage_application_module"
    depends_on = [
        module.iam_module
    ]
    
    application_name = var.application_name
    repo_connection_arn = var.bitbucket_source_arn
    git_repo = "${var.git_account}/${var.application_name}"
    
    git_repo_dev_branch = "dev"
    git_repo_test_branch = "test"
    git_repo_prod_branch = "prod"    

    dev_target_type_tag = "dev" 
    test_target_type_tag = "test" 

    prod_target_type_tag = "prod" 
    prod_cluster_alb_target_name = lookup(module.loadbalancer_external.prod_alb_targets,"example-app").name
    prod_cluster_asg_id = module.prod_compute_cluster.prod_compute_cluster_asg.id

    stage_target_type_tag = "stage"
    stage_cluster_alb_target_name = lookup(module.uat_loadbalancer_internal.stage_alb_targets,"example-app").name
    stage_cluster_asg_id = module.stage_compute_cluster.prod_compute_cluster_asg.id

    production_approval_notification_arn = module.notify.production_approval_notification_arn
    uat_completion_approval_notification_arn = module.notify.app_uat_completion_approval_notification_arn

    cicd_failure_notification_arn = module.notify.cicd_failure_notification_arn

    codepipeline_role_arn = module.iam_module.codepipeline_role_arn
    code_deploy_role_arn = module.iam_module.code_deploy_role_arn

    codebuild_role_arn = module.iam_module.codebuild_role_arn

    code_build_container_image =  var.code_build_container_image

    vpc_id = module.network_module.vpc.id
    app_subnet = module.network_module.subnet_map.app.A.id
    app_tier_sg_id = module.security_module.security_group_map.app_dev.id
}

module "notify" {
    source = "../modules/notify_module"
    tester_email = var.emails.tester_email
    production_manager_email = var.emails.production_manager_email
    uat_tester_email = var.emails.uat_tester_email
    uat_app_approver_email = var.emails.uat_approver_email
}