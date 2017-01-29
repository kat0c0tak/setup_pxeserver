# Network Install Environment for CentOS.

## What's this?

This describes a way of setting up environment in which installing CentOS through your netowrk.
The environment includes **PXE** (Preboot eXecutable Environment), which is network booting environment, and **kickstart**, which is automatically installing CentOS, and is deployed by **Ansible**. 

##  Steps to build the environment

1. Setting Ansible
1. Deploying PXE server
1. Putting OS images
1. Making you kickstart config file (If you need)
1. Setting your DHCP


1. Modify ```./playbook/inv```. You add the target machine IP under [pxeserver] group in the file.
1. Execute ```./bin/run.sh```



## Setting Ansible

### Install Ansible

Installing Ansible from EPEL.
```
% yum install ansible
```

Checking the install.
```
% ansible -h
Usage: ansible <host-pattern> [options]

Options:
  -a MODULE_ARGS, --args=MODULE_ARGS
                        module arguments
...
```

### Allowing an access a target machine for Ansible

In this script, Ansible requires to access a target machine by SSH as root without a password.

IP in following sentence is a example. Please use your target machine IP instead of it.

```
% ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/xxx/.ssh/id_rsa): <ENTER> 
Enter passphrase (empty for no passphrase): <ENTER> 
Enter same passphrase again: <ENTER> 
Your identification has been saved in /home/xxx/.ssh/id_rsa.
Your public key has been saved in /home/xxx/.ssh/id_rsa.pub.
...

% ssh-copy-id root@192.168.122.2
root@192.168.122.2's password: <ROOT_PASSWORD>
Now try logging into the machine, with "ssh 'root@192.168.122.2'", and check in:

  .ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.
```

After that, You can access by SSH as root without a password.

```
% ssh root@192.168.122.2
```

And you can get some information from a target machine with Ansible.
```
% ansible -m setup -i 192.168.122.2, all -u root
192.168.122.2 | SUCCESS => {
...
```


## Deploying PXE server


You specify a target machine IP into ```./playbook/inv```.

```
[pxeserver]
xxx.xxx.xxx.xxx
```

***Deploy!***

```
% ./bin/run.sh
```

## Putting OS images

You copy OS images, which is used to network boot, to the following path by yourself. Because this script not include OS images.
The OS image path is ```/var/www/html/kickstart/<OS_NAME>/iso/``` based on the directory tree below.

This includes directories and kickstart config files for CentOS6.5 and CentOS7.2.
If you use these OS, you put these OS images to ```/var/www/html/CentOS_6.5 or 7.2/iso/```.

If you use other versions, you need to put OS image and create kickstart config files for other version.


The following script copies OS image to the correct path from ISO file.
```
ISOPATH=xxx.iso
MOUNTPOINT=/tmp/$(basename $ISOPATH)
OSDEST=/var/www/html/<OS NAME>/iso

mkdir -p $MOUNTPOINT
mount -t iso9660 -o loop $ISOPATH $MOUNTPOINT

if [[ ! -e $OSDEST ]]; then
    mkdir -p $OSDEST
fi

\cp -rf $MOUNTPOINT/* $OSDEST/

umount $MOUNTPOINT
rm -r $MOUNTPOINT
```


## Making your kickstart config file (If you need)

If you use sample kickstart config file, you do not need this paragraph.

If you want to modify a setting of installing OS or add new OS / new kickstart config file, you can make your kickstart config file and put it to a apropriate path and modify a PXE menu file.

After makeing / modifing your kickstart config file, please use this script in order to add the file to a apropriate path and PXE menu.

```
./bin/add_kickstart.sh
```

 
## Setting your DHCP.

When booting a machine with PXE, the machine requires PXE server IP with DHCP.
You need to add a settings to DHCP below.

```
filename "/pxelinux.0";
next-server <PXE SERVER IP>;
```

# Appendix

## Directory Tree

### Initial tree

```
/tftpboot
|-- kickstart -> /var/www/html/kickstart # mounted
|-- pxelinux.0
|-- pxelinux.cfg
|   `-- default
|-- reboot.c32
`-- vesamenu.c32


/var/www/html/kickstart
|-- CentOS_6.5
|   |-- iso/ 
|   |-- added-ks.cfg
|   `-- partition.cfg
|
`-- CentOS_7.2
    |-- iso/
    |-- added-ks.cfg
    `-- partition.cfg
```

### After coping OS images

```
/tftpboot
|-- kickstart -> /var/www/html/kickstart # mounted
|-- pxelinux.0
|-- pxelinux.cfg
|   `-- default
|-- reboot.c32
`-- vesamenu.c32


/var/www/html/kickstart
|-- CentOS_6.5
|   |-- iso 
|   |   |-- CentOS_BuildTag
|   |   |-- ... 
|   |   `-- images
|   |       `-- pxeboot
|   |           |-- initrd.img
|   |           |-- TRANS.TBL
|   |           `-- vmlinuz
|   |-- added-ks.cfg
|   `-- partition-ks.cfg
|
`-- CentOS_7.2
    |-- iso 
    |   |-- CentOS_BuildTag
    |   |-- ... 
    |   `-- images
    |       `-- pxeboot
    |           |-- initrd.img
    |           |-- TRANS.TBL
    |           `-- vmlinuz
    |-- added-ks.cfg
    `-- partition-ks.cfg
```
