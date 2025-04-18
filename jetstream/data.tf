## Data from OpenStack
data "openstack_networking_router_v2" "auto-allocated-router" {
  name = "auto_allocated_router"
}

data "openstack_networking_subnetpool_v2" "shared-default-ipv6" {
  name = "shared-default-ipv6"
}
