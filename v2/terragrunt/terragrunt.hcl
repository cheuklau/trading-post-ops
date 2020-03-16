remote_state {
  backend = "s3"
  config = {
    bucket         = "mtgtradingpost-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "mtgtradingpost-lock-table"
  }
}
