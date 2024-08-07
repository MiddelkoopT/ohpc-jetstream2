# Developer Notes

Ongoing developer notes.  Don't forget to delete your lease when you are done.

## Chameleon
https://www.chameleoncloud.org/

### Create credentials

Application Credentials.  Create with all defaults, download clouds.yaml, and make sure `yq` is installed
```bash
./login.sh ~/Downloads/clouds.yaml cloud/chi.tacc.chameleoncloud.org.env
./login.sh ~/Downloads/clouds.yaml cloud/chi.uc.chameleon.env
```

### Create a reservation

Select IB based nodes with at least two active network cards (for example, `compute_cascadelake_r_ib` or `compute_haswell_ib`).  Tested at CHI@UC and CHI@TACC.  Reserve one IP, no need to reserve any network.

### Manual Config

* Create a network w/ a subnet (ohpc), disable default gateway and turn off DHCP.  Use `10.5.0.0/16` as the subnet. 
* When creating the instance, select sharednet1 as #1 and ohpc as #2.
* Turn off firewall

### Openstack
Login to OpenStack

Pick one based on the system your using
```bash
. ./auth-env.sh cloud/chi.tacc.chameleoncloud.org.env
. ./auth-env.sh cloud/chi.uc.chameleon.env
openstack project list
```

