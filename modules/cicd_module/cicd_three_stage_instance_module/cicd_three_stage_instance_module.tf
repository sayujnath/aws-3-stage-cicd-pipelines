############################################################

#   Title:          Three Stage CICD Pipelines
#   Author:         Sayuj Nath, AWS Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use    
#   File Desc:      Provision a three stage CICD pipeline which builds and deploys code
#                   into the target server
#                   from the designated branch of the repository
#                   The pipeline contains three stages:
#                       1. Stage 1 - extract latest commit from git branch using CodesStar
#                       2. Stage 2 - Build the code using CodeBuild
#                       3. Stage 3 - Deploy the code using CodeDeploy
#                   
#   Design Report:  not published in public domain
#
###########################################################


# Provisions one stage CICD pipeline deploying directly to EC2 instances with
# the given tag.
# These stages are number in the comments within this resource.

resource "aws_codepipeline" "three_stage_instance_pipeline" {
    name     = "${var.application_name}-three-stage-instance-${var.target_type_tag}-pipeline"
    role_arn = var.codepipeline_role_arn

# set up a bucket to store application code during deployment
    artifact_store {
            location = "code-pipeline-artifacts-Example"
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
        name = "${var.deployment_target_name}-App-Build"

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


    # 3. Deploy the code into the target server using CodeDeploy
    # This step uses the appspec.yml file that should be in the
    # root folder of the code repository
    stage {
        name = "${var.deployment_target_name}-App-Deployment"

        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CodeDeploy"
            input_artifacts = ["build_output"]
            # output_artifacts = ["test_output"]
            version         = "1"

            configuration = {
                ApplicationName     = aws_codedeploy_app.deploy-target-server-app.name
                DeploymentGroupName   = aws_codedeploy_deployment_group.deploy-target-server-group.deployment_group_name
            }
        }
    }

}



#deploy stage into target server
resource "aws_codedeploy_app" "deploy-target-server-app" {
    compute_platform = "Server"
    name             = "${var.application_name}-${var.target_type_tag}-deploy-target"
}


resource "aws_codedeploy_deployment_group" "deploy-target-server-group" {
    app_name               = aws_codedeploy_app.deploy-target-server-app.name
    deployment_group_name  = "${var.application_name}-${var.target_type_tag}-deploy"
    service_role_arn       = var.code_deploy_role_arn
    deployment_config_name = "CodeDeployDefault.OneAtATime" 

    ec2_tag_filter {
        key   = "DeployType"
        type  = "KEY_AND_VALUE"
        value = var.target_type_tag
    }

    trigger_configuration {
        trigger_events     = ["DeploymentFailure"]
        trigger_name       = "${var.target_type_tag}-deploy-trigger"
        trigger_target_arn = var.cicd_failure_notification_arn
    }

    auto_rollback_configuration {
        enabled = false
        events  = ["DEPLOYMENT_FAILURE"]
    }
}


resource "aws_codebuild_project" "build_app" {
  name          = "${var.application_name}-${var.target_type_tag}-instance-builder"
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
