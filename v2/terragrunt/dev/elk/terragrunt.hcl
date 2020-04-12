terraform {
  source = "git::git@github.com:cheuklau/trading-post-modules.git//elk"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  instance_type  = "t2.medium"
  logstash_port  = 5044
  kibana_port    = 5601
  elb_port       = 80 # Update later to HTTPS/443 with ACM
}
