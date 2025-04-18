variable "username" {
    type = string
}
variable "ssh_public_key" {
    type = string
}

variable "head_image" {
    type = string
    default = "CC-CentOS9-Stream"
}

variable "head_user" {
    type = string
    default = "cc"
}

variable "head_size" {
    type = string
    default = "m1.small"
}

variable "node_size" {
    type = string
    default = "m1.small"
}

variable "node_count" {
    type = number
    default = 1
}
