## Data from OpenStack
data "openstack_networking_network_v2" "public" {
  name = "public"
}
