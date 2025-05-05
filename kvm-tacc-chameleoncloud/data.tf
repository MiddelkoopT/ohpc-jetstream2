## Data from OpenStack

data "openstack_identity_auth_scope_v3" "ohpc" {
  name = "ohpc-scope"
}

data "openstack_networking_network_v2" "public" {
  name = "public"
}
