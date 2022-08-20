application_name = "example-app"
git_codestar_source_arn = "arn:aws:codestar-connections:ap-southeast-2:4XXXXXXXXXXX4:connection/89XXXXXXXXXXXXXXXXXXXb4"
git_account = "git-account-name"

git_prod_branch = "production-branch"
git_dev_branch  = "development-branch"
git_test_branch = "test-branch"

emails = {
    tester_email = "tester@canditude.com",
    production_manager_email = "prod-manager@canditude.com",
    uat_tester_email = "uat-tester@canditude.com",
    uat_approver_email = "uat-approver@@canditude.com",
}

code_build_container_image =  "aws/codebuild/amazonlinux2-x86_64-standard:4.0"