variable "username" {
    type = string
}
variable "ssh_public_key" {
    type = string
}

variable "openstack_projects_domain" {
    type = string
    default = "projects.jetstream-cloud.org"
}

variable "head_image" {
    type = string
    default = "Featured-RockyLinux9"
}

variable "head_user" {
    type = string
    default = "rocky"
}

variable "head_size" {
    type = string
    default = "m3.small"
}

variable "node_size" {
    type = string
    default = "m3.quad"
}

variable "node_count" {
    type = number
    default = 1
}
