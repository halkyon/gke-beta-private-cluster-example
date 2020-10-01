provider "google" {
  version = "~> 3.4"
}

provider "google-beta" {
  version = "~> 3.4"
}

# locals {
#   bastion_name = format("%s-bastion", var.cluster_name)
#   bastion_zone = format("%s-a", var.region)
# }

# data "template_file" "startup_script" {
#   template = <<-EOF
#   sudo apt-get update -y
#   sudo apt-get install -y tinyproxy
#   EOF
# }

module "enabled_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 9.1"
  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "binaryauthorization.googleapis.com",
    "stackdriver.googleapis.com",
    "iap.googleapis.com",
  ]
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = module.enabled_google_apis.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = var.subnet_ip_range
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  secondary_ranges = {
    "${var.subnet_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = var.ip_range_pods
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = var.ip_range_services
      },
    ]
  }
}

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  project_id    = module.enabled_google_apis.project_id
  region        = var.region
  router        = "${var.network_name}-router"
  network       = module.vpc.network_self_link
  create_router = true
}

# module "bastion" {
#   source         = "terraform-google-modules/bastion-host/google"
#   version        = "~> 2.8"
#   network        = module.vpc.network_self_link
#   subnet         = module.vpc.subnets_self_links[0]
#   project        = module.enabled_google_apis.project_id
#   host_project   = module.enabled_google_apis.project_id
#   name           = local.bastion_name
#   zone           = local.bastion_zone
#   image_project  = "debian-cloud"
#   image_family   = "debian-10"
#   machine_type   = "f1-micro"
#   disk_size_gb   = "20"
#   startup_script = data.template_file.startup_script.rendered
#   members        = var.bastion_members
# }

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                = "~> 11.1"
  project_id             = module.enabled_google_apis.project_id
  name                   = var.cluster_name
  regional               = var.regional
  region                 = var.region
  zones                  = var.zones
  network                = module.vpc.network_name
  subnetwork             = module.vpc.subnets_names[0]
  ip_range_pods          = var.ip_range_pods_name
  ip_range_services      = var.ip_range_services_name
  master_ipv4_cidr_block = var.master_ip_range
  # master_authorized_networks = [{
  #   cidr_block   = "${module.bastion.ip_address}/32"
  #   display_name = "All access"
  # }]
  firewall_inbound_ports        = var.firewall_inbound_ports
  node_pools                    = var.node_pools
  remove_default_node_pool      = true
  enable_private_nodes          = true
  # sandbox_enabled               = true
  # enable_private_endpoint       = true
  # deploy_using_private_endpoint = true
  gce_pd_csi_driver             = true
  http_load_balancing           = false
}

data "google_client_config" "default" {
}

# provider "kubernetes" {
#   load_config_file       = false
#   host                   = "https://${module.gke.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(module.gke.ca_certificate)
# }
