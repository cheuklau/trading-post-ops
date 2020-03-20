terraform {
  source = "git::git@github.com:cheuklau/trading-post-modules.git//asg"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  instance_type  = "t2.micro"
  min_size       = 1
  max_size       = 1
  server_port    = 80
  elb_port       = 80 # Update later to HTTPS/443 with ACM
}
