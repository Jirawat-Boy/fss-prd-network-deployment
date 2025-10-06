locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("/live/common_vars.hcl"))
}

# BACKEND CONFIGURATION
remote_state {
  backend = "s3"
  config = {
    profile                = local.common_vars.inputs.aws_configuration.profile
    encrypt                = true
    bucket                 = local.common_vars.inputs.s3_bucket_name 
    key                    = "${path_relative_to_include()}/terraform.tfstate"
    region                 = local.common_vars.inputs.aws_configuration.region
    skip_region_validation = local.common_vars.inputs.aws_configuration.skip_region_validation
    dynamodb_table         = local.common_vars.inputs.dynamodb_table_name

    s3_bucket_tags = merge(
      local.common_vars.inputs.tags,
      {
        Name = "Terraform state storage"
      }
    )

    dynamodb_table_tags = merge(
      local.common_vars.inputs.tags,
      {
        Name = "Terraform lock table"
      }
    )
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# PROVIDER CONFIGURATION
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region                 = "${local.common_vars.inputs.aws_configuration.region}"
  profile                = "${local.common_vars.inputs.aws_configuration.profile}"
  skip_region_validation = ${local.common_vars.inputs.aws_configuration.skip_region_validation}

  # Note: assume_role is commented out in common_vars.hcl
  # Uncomment the block below if you need to assume a role
  # assume_role {
  #   role_arn     = "arn:aws:iam::ACCOUNT:role/ROLE-NAME"
  #   session_name = "terragrunt-session"
  # }
}
EOF
}

# TERRAFORM CONFIGURATION

terraform {
  extra_arguments "bucket" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      "${get_terragrunt_dir()}/${find_in_parent_folders("account.tfvars", "ignore")}"
    ]
  }
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
  extra_arguments "compact_output" {
    commands = get_terraform_commands_that_need_vars()
    arguments = ["-compact-warnings", "-no-color"]
  }
}
