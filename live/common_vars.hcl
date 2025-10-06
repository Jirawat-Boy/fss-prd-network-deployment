inputs = {
  aws_configuration = {
    "profile" = "trueidc-deploy"
    "region" = "ap-southeast-7"   
    "skip_region_validation"  = true
  }

  # assume_role = {
  #   "role_arn"     = "arn:aws:iam::767828768839:role/poc-ntb-top"
  #   "session_name" = "network-account-1"
  #   }
  
  s3_bucket_name = "fss-network-prd-landing-zone"
  dynamodb_table_name = "fss-network-prd-landing-zone"

  tags = {
    "environment"    = "PRD"
    "created-by"     = "TrueIDC"
    "created-at"     = formatdate("DD-MMM-YY", timestamp())
    "managed-by"     = "terraform"
  }
}



