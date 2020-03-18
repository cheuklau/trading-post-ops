terraform {
    source = "git::git@github.com:cheuklau/trading-post-modules.git//rds"
}

include {
    path = find_in_parent_folders()
}
