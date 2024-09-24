provider "openstack" {
}

resource "openstack_networking_network_v2" "ohpc-external" {
  name = "ohpc-vpc-external"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "ohpc-internal" {
  name = "ohpc-vpc-internal"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "ohpc-external-ipv4" {
  name = "ohpc-external-ipv4"
  network_id = openstack_networking_network_v2.ohpc-external.id
  cidr = "10.4.0.0/16"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "ohpc-internal-ipv4" {
  name = "ohpc-internal-ipv4"
  network_id = openstack_networking_network_v2.ohpc-internal.id
  enable_dhcp = false
  cidr = "10.5.0.0/16"
  allocation_pool {
    start = "10.5.1.0"
    end = "10.5.254.254"
  }
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "ohpc-external-ipv6" {
  name = "ohpc-external-ipv6"
  network_id = openstack_networking_network_v2.ohpc-external.id
  subnetpool_id = var.openstack_subnet_pool_shared_ipv6
  ip_version = 6
  ipv6_address_mode = "dhcpv6-stateful"
  ipv6_ra_mode = "dhcpv6-stateful"
}

resource "openstack_networking_router_interface_v2" "ohpc-external-ipv4" {
  router_id = var.openstack_router_id
  subnet_id = openstack_networking_subnet_v2.ohpc-external-ipv4.id
}

resource "openstack_networking_router_interface_v2" "ohpc-internal-ipv4" {
  router_id = var.openstack_router_id
  subnet_id = openstack_networking_subnet_v2.ohpc-internal-ipv4.id
}

resource "openstack_networking_router_interface_v2" "ohpc-external-ipv6" {
  router_id = var.openstack_router_id
  subnet_id = openstack_networking_subnet_v2.ohpc-external-ipv6.id
}

resource "openstack_networking_floatingip_v2" "ohpc" {
  pool = "public"
}

resource "openstack_networking_secgroup_v2" "ohpc-external" {
  name        = "ohpc-sg-external"
}

resource "openstack_networking_secgroup_v2" "ohpc-internal" {
  name        = "ohpc-sg-internal"
}

resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv4-ssh" {
  security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv6-ssh" {
  security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv4-icmp" {
  security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv6-icmp" {
  security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_ip_prefix  = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv4-subnet" {
  security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = openstack_networking_subnet_v2.ohpc-external-ipv4.cidr
}

resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv6-subnet" {
  security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
  direction         = "ingress"
  ethertype         = "IPv6"
  remote_ip_prefix  = openstack_networking_subnet_v2.ohpc-external-ipv6.cidr
}

# internal
resource "openstack_networking_secgroup_rule_v2" "ohpc-internal-ipv4-subnet" {
  security_group_id = openstack_networking_secgroup_v2.ohpc-internal.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = openstack_networking_subnet_v2.ohpc-internal-ipv4.cidr
}

# resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv4-ingress" {
#   security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   remote_ip_prefix  = "0.0.0.0/0"
# }

# resource "openstack_networking_secgroup_rule_v2" "ohpc-external-ipv6-ingress" {
#   security_group_id = openstack_networking_secgroup_v2.ohpc-external.id
#   direction         = "ingress"
#   ethertype         = "IPv6"
#   remote_ip_prefix  = "::/0"
# }

resource "openstack_networking_port_v2" "ohpc-external" {
  name           = "ohpc-port-external-head"
  admin_state_up = "true"
  network_id = openstack_networking_network_v2.ohpc-external.id

  security_group_ids = [openstack_networking_secgroup_v2.ohpc-external.id]
  fixed_ip {
      subnet_id = openstack_networking_subnet_v2.ohpc-external-ipv4.id
      ip_address = cidrhost(openstack_networking_subnet_v2.ohpc-external-ipv4.cidr, 8)
  }
  fixed_ip {
      subnet_id = openstack_networking_subnet_v2.ohpc-external-ipv6.id
      ip_address = cidrhost(openstack_networking_subnet_v2.ohpc-external-ipv6.cidr, 8)
  }
}

resource "openstack_networking_port_v2" "ohpc-internal" {
  name           = "ohpc-port-internal-head"
  admin_state_up = "true"
  network_id = openstack_networking_network_v2.ohpc-internal.id

  port_security_enabled = false
  fixed_ip {
      subnet_id = openstack_networking_subnet_v2.ohpc-internal-ipv4.id
      ip_address = cidrhost(openstack_networking_subnet_v2.ohpc-internal-ipv4.cidr, 8)
  }
}

resource "openstack_networking_floatingip_associate_v2" "ohpc" {
  floating_ip = openstack_networking_floatingip_v2.ohpc.address
  port_id = openstack_networking_port_v2.ohpc-external.id
}

## Compute

resource "openstack_compute_instance_v2" "ohpc" {
  name = "head"
  image_name = var.head_image
  flavor_name = var.head_size
  key_pair = "orange"
  network {
    port = openstack_networking_port_v2.ohpc-external.id
  }
  network {
    port = openstack_networking_port_v2.ohpc-internal.id
  }
  user_data = <<-EOF
    #!/bin/bash
    passwd -d root
    rm -v /root/.ssh/authorized_keys
    EOF
}

resource "openstack_compute_instance_v2" "node" {
  count = var.node_count
  name = "c${count.index}"
  image_name = "efi-ipxe"
  flavor_name = var.node_size
  network {
    uuid = openstack_networking_network_v2.ohpc-internal.id
    fixed_ip_v4 = cidrhost(openstack_networking_subnet_v2.ohpc-internal-ipv4.cidr, 256 + count.index)
  }
  security_groups = [openstack_networking_secgroup_v2.ohpc-internal.name]
}

## Ouptput

resource "local_file" "ansible" {
  filename = "local.ini"
  content = <<-EOF
    ## auto-generated
    [ohpc]
    head ansible_host=${openstack_networking_port_v2.ohpc-external.all_fixed_ips[1]} ansible_user=${var.head_user} arch=x86_64

    [ohpc:vars]
    sshkey=${var.ssh_public_key}
    EOF
}

output "ohpc_ipv4" {
  value = openstack_networking_floatingip_v2.ohpc.address
}

output "ohpc_ipv6" {
  value = openstack_networking_port_v2.ohpc-external.all_fixed_ips[1]
}
