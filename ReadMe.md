# OpenHPC 3.x, ww4, Rocky9, OpenStack/Jetstream2

## Setup
Template `local.tf`, replace `$USER` and `$SSH_KEY`
Since there is only one main router - populate the `$ROUTER_ID` and `$SHARED_IVP6` pool variables. This could be automated with `openstack port list --router` and a tofu import (see router docs).

```
variable "username" {
    type = string
    default = "$USER"
}
variable "ssh_public_key" {
    type = string
    default = "$SSH_KEY"
}
variable "openstack_router_id" {
    type = string
    default = "$ROUTER"
}

variable "openstack_subnet_pool_shared_ipv6" {
    type = string
    default = "$SHARED_IPV6"
}
```

Create the EFI image
Must have the following properties:
```ini
hw_firmware_type=uefi
hw_scsi_model=virtio-scsi
```

```bash
./ipxe.sh
openstack image create --disk-format raw --file disk.img --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' efi-ipxe
```

## Debug
```bash
openstack console log show c0
ssh -i ~/.ssh/id_rsa -R 8180 c0
export all_proxy=socks5h://127.0.0.1:8180
scontrol update nodename=c0 state=RESUME
```
