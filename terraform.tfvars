project_id   = "development-290803"
cluster_name = "cluster-01"
regional     = false
region       = "australia-southeast1"
zones        = ["australia-southeast1-a"]
network_name = "vpc-01"
subnet_name  = "subnet-01"
node_pools = [
  {
    name         = "default-node-pool"
    min_count    = 1
    max_count    = 4
    machine_type = "e2-standard"
    preemptible  = true
    disk_type    = "pd-ssd"
    disk_size_gb = 40
  },
]
