############################################################

#   Title:          Three Stage CICD Pipelines for Stage and Production Deployment with Approval
#   Author:         Sayuj Nath, AWS Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use    
#   File Desc:      Provision a three stage CICD pipeline which builds and deploys code
#                   into the staging cluster first and subsequently the productiuon cluster 
#                   after an approval process.
#                   The pipeline contains three stages:
#                       1. Stage 1 - extract latest commit from git branch using CodesStar
#                       2. Stage 2 - Build the code using CodeBuild
#                       3. Stage 3 - Deploy the code using CodeDeploy
#                   
#   Design Report:  not published in public domain
#
###########################################################


# Provisions four stage CICD pipeline with the following five stages.
# These stages are number in the comments within this resource.

resource "aws_codepipeline" "three_stage_cluster_pipeline" {
    name     = "${var.application_name}-three-stage-cluster-${var.stage_target_type_tag}-${var.prod_target_type_tag}-pipeline-with-approval"
    role_arn = var.codepipeline_role_arn

# set up a bucket to store application code during deployment
    artifact_store {
            location = "code-pipeline-artifacts"
            type    = "S3"
    }

    # 1. Obtain latest code from the master branch of the nominated
    # source repository. The source repo is precreated in AWS via console
    # due the manual steps needed for authenticating the repo (ie. Bitbucket)
    stage {
        name = "Source"

        action {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = ["source_output"]

        configuration = {
            ConnectionArn    = var.repo_connection_arn
            FullRepositoryId = var.git_repo
            BranchName       = var.git_repo_branch
            }
        }
    }


    # 2. Build the code using CodeBuild. Requires buildspec.yml
    # to be installed in root dircetory of repository.
    stage {
        name = "${var.stage_deployment_target_name}-App-Build"

        action {
            name            = "Build"
            category        = "Build"
            owner           = "AWS"
            provider        = "CodeBuild"
            input_artifacts = ["source_output"]
            output_artifacts = ["build_output"]
            version         = "1"

            configuration = {
                ProjectName = aws_codebuild_project.build_app.name
            }
        }
    }


    # 3. This is the final stage of the pipeline which will deploy
    # all the code into production
    stage {
        name = "${var.stage_deployment_target_name}-App-Cluster-Deployment"

        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CodeDeploy"
            input_artifacts = ["build_output"]
            version         = "1"

            configuration = {
                ApplicationName     = aws_codedeploy_app.deploy-stage-cluster-app.name
                DeploymentGroupName   = aws_codedeploy_deployment_group.deploy-stage-cluster-group.deployment_group_name
            }
        }
    }

    # 4. Send a notification to the software tester to requst for
    # approval or rejection. Once approved in the AWS console, 
    # this pipeline will progress to stage four
    stage {
        name = "User-Acceptance-Test-Completion-Approval"

        action {
            name     = "Approval"
            category = "Approval"
            owner    = "AWS"
            provider = "Manual"
            version  = "1"

            configuration = {
                NotificationArn = var.stage_completion_approval_notification_arn
                CustomData = "Please appove once all user acceptance tests are working on the staging server via VPN. Attach any test results if any."
                ExternalEntityLink = var.stage_approve_url
            }
        }
    }

    # 5. Send a notification to the production manager to request for
    # approval or rejection. Once approved in the AWS console, 
    # this pipeline deploy the code into all the production servers.
    stage {
        name = "Approve-Commit-to-Production"

        action {
            name     = "Approval"
            category = "Approval"
            owner    = "AWS"
            provider = "Manual"
            version  = "1"

            configuration = {
                NotificationArn = var.production_approval_notification_arn
                CustomData = "User acceptance testing is completed on staging server. Please approve if code is ready to commit for production."
                ExternalEntityLink = var.prod_approve_url
            }
        }
    }

    # 6. This is the final stage of the pipeline which will deploy
    # all the code into production
    stage {
        name = "Production-System-Deploy"

        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CodeDeploy"
            input_artifacts = ["build_output"]

            version         = "1"

            configuration = {
                ApplicationName     = aws_codedeploy_app.deploy-prod-cluster-app.name
                DeploymentGroupName   = aws_codedeploy_deployment_group.deploy-prod-cluster-group.deployment_group_name
            }
        }
    }
}


resource "aws_codedeploy_app" "deploy-stage-cluster-app" {
    compute_platform = "Server"
    name             = "${var.application_name}-${var.stage_target_type_tag}-deploy-cluster-target"
}

resource "aws_codedeploy_deployment_group" "deploy-stage-cluster-group" {
    app_name               = aws_codedeploy_app.deploy-stage-cluster-app.name
    deployment_group_name  = "${var.application_name}-${var.stage_target_type_tag}-cluster-deploy"
    service_role_arn       = var.code_deploy_role_arn
    autoscaling_groups     = [var.stage_cluster_asg_id]
    deployment_config_name  = "CodeDeployDefault.OneAtATime" 
    
    deployment_style {
        deployment_option  = "WITHOUT_TRAFFIC_CONTROL"
        deployment_type    = "IN_PLACE"
    }  

    ec2_tag_filter {
        key   = "DeployType"
        type  = "KEY_AND_VALUE"
        value = var.stage_target_type_tag
    }

    load_balancer_info  {

        target_group_info {
            name = var.stage_cluster_alb_target_name
        }
    }

    trigger_configuration {
        trigger_events     = ["DeploymentFailure"]
        trigger_name       = "cluster-deploy-trigger"
        trigger_target_arn = var.cicd_failure_notification_arn
    }

    auto_rollback_configuration {
        enabled = true
        events  = ["DEPLOYMENT_FAILURE"]
    }
}


resource "aws_codedeploy_app" "deploy-prod-cluster-app" {
    compute_platform = "Server"
    name             = "${var.application_name}-${var.prod_target_type_tag}-deploy-cluster-target"
}

resource "aws_codedeploy_deployment_group" "deploy-prod-cluster-group" {
    app_name               = aws_codedeploy_app.deploy-prod-cluster-app.name
    deployment_group_name  = "${var.application_name}-${var.prod_target_type_tag}-cluster-deploy"
    service_role_arn       = var.code_deploy_role_arn
    autoscaling_groups     = [var.prod_cluster_asg_id]
    deployment_config_name  = "CodeDeployDefault.OneAtATime" 
    
    deployment_style {
        deployment_option  = "WITH_TRAFFIC_CONTROL"
        deployment_type    = "IN_PLACE"
    }  

    ec2_tag_filter {
        key   = "DeployType"
        type  = "KEY_AND_VALUE"
        value = var.prod_target_type_tag
    }

    load_balancer_info  {

        target_group_info {
            name = var.prod_cluster_alb_target_name
        }
    }

    trigger_configuration {
        trigger_events     = ["DeploymentFailure"]
        trigger_name       = "prod-deploy-trigger"
        trigger_target_arn = var.cicd_failure_notification_arn
    }



    auto_rollback_configuration {
        enabled = true
        events  = ["DEPLOYMENT_FAILURE"]
    }
}


resource "aws_codebuild_project" "build_app" {
  name          = "${var.application_name}-cluster-builder"
  description   = " Build the application using a ECR container"
  build_timeout = "10"
  service_role  = var.codebuild_role_arn

source {
    type = "CODEPIPELINE"
}
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.code_build_container_image
    type                        = "LINUX_CONTAINER"
    # image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode  = true
  }

  source_version = "master"

   vpc_config {
    vpc_id = var.vpc_id

    subnets = [
      var.app_subnet
    ]

    security_group_ids = [
        var.app_tier_sg_id
    ]
  }

}
