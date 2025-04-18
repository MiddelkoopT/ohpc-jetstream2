# OpenHPC 3.x, ww4, Rocky9, OpenStack/Jetstream2

## Setup
In the template `local.tfvars` in each platform directory replace `$USER` and `$SSH_KEY`; see `local.tfvars.example`.

```ini
username = "$USER"
ssh_public_key = "$SSH_KEY"
```

Create the ipxe boot image that chains the Warewulf IPXE
```bash
cd ipxe
./ipxe.sh
openstack image create --disk-format raw --file disk.img --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' --property hw_machine_type=q35 efi-ipxe
```

## Run

```bash
. ./auth-env.sh
./create.sh
./ohpc-run.sh
```
