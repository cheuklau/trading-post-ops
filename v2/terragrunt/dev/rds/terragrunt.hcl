terraform {
    source = "git::ssh//git@github.com/cheuklau/trading-post-ops.git//v2/modules/rds"
}

include {
    path = "${find_int_parent_folders()}"
}