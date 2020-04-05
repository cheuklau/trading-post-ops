terraform {
  source = "git::git@github.com:cheuklau/trading-post-modules.git//harness"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  account_id     = "650716339685"
  ami_id         = "ami-07a6716a7f1ee6d61"
  instance_type  = "t2.micro" # delegate requires at least 6GB ram
  min_size       = 1
  max_size       = 1
  server_port    = 80
}
