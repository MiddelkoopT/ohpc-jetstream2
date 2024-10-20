# OpenHPC 3.x, ww4, Rocky9, OpenStack/Jetstream2

## Setup
Template `local.tfvars`, replace `$USER` and `$SSH_KEY`
Since there is only one main router - populate the `$ROUTER_ID` and `$SHARED_IVP6` pool variables. This could be automated with `openstack port list --router` and a tofu import (see router docs).

```
username = "$USER"
ssh_public_key = "$SSH_KEY"
openstack_router_id = "$ROUTER"
openstack_subnet_pool_shared_ipv6 = "$SHARED_IPV6"
```

Create the EFI image
Must have the following properties:
```ini
hw_firmware_type=uefi
hw_scsi_model=virtio-scsi
```

```bash
./ipxe.sh
openstack image create --disk-format raw --file disk.img --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' --property hw_machine_type=q35 efi-ipxe
```

## Run

```bash
./create.sh
./run.sh
```