variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "regional" {
  type    = bool
  default = true
}

variable "region" {
  type = string
}

variable "zones" {
  type    = list(string)
  default = []
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "master_ip_range" {
  type    = string
  default = "172.16.0.0/28"
}

variable "subnet_ip_range" {
  type    = string
  default = "10.5.0.0/20"
}

variable "ip_range_pods_name" {
  type    = string
  default = "ip-range-pods"
}

variable "ip_range_pods" {
  type    = string
  default = "10.0.0.0/14"
}

variable "ip_range_services_name" {
  type    = string
  default = "ip-range-svc"
}

variable "ip_range_services" {
  type    = string
  default = "10.4.0.0/19"
}

variable "firewall_inbound_ports" {
  type    = list(string)
  default = []
}

variable "node_pools" {
  type        = list(map(string))
  description = "List of maps containing node pools"
  default = [
    {
      name = "default-node-pool"
    },
  ]
}

# variable "bastion_members" {
#   type        = list(string)
#   description = "List of users, groups who need access to the bastion host"
#   default     = []
# }

# variable "ip_source_ranges_ssh" {
#   type        = list(string)
#   description = "Additional source ranges to allow for SSH to bastion host. 35.235.240.0/20 allowed by default for IAP tunnel."
#   default     = []
# }
