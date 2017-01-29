#!/bin/bash

WEBROOT=/var/www/html
TFTPROOT=/tftpboot
OSNAME=$1
KSFILE=$2
OSDEST=$WEBROOT/kickstart/$OSNAME/iso
PXEMENU=$TFTPROOT/pxelinux.cfg/default
HTTP_SERVER_IP=$(ip -f inet -o addr show eth0 | awk '{print $4}' | cut -d/ -f 1)

help()
{
    echo "E.g. $0 <OS NAME> [<KICKSTART CONFIG FILE>]"
    echo ""
    echo "This script adds a install option to PXE boot menu."
    echo "When you don't give <KICKSTART CONFIG FILE> it adds a option for manual install."
    echo ""
    echo "Before executing itself, Please take following steps."
    echo ""
    echo "1. Setup PXE server by ./bin/run.sh."
    echo "2. Put OS images to /var/www/html/kickstart/<OS NAME>/iso ."
    echo ""
    echo "When it is kickstart."
    echo "3. Make kickstart config file and give the file path to this script."
}

if [[ ${EUID:-${UID}} != 0 ]]; then
    echo "You are not root."
    help
    exit -1
fi

if [[ "$OSNAME" == "" ]]; then
    echo "Invalid OS name."
    help
    exit -1
fi

if [[ ! -e $OSDEST ]]; then
    echo "Not found $OSDEST"
    help
    exit -1
fi

if [[ ! -e $WEBROOT ]]; then
    echo "Not found $WEBROOT"
    help
    exit -1
fi

if [[ ! -e $TFTPROOT ]]; then
    echo "Not found $TFTPROOT"
    help
    exit -1
fi

if [[ ! -e $PXEMENU ]]; then
    echo "Not found $PXEMENU"
    help
    exit -1
fi

if [[ ! -e $TFTPROOT/kickstart ]]; then
    echo "Not found $TFTPROOT/kickstart"
    help
    exit -1
fi

if [[ "$KSFILE" != "" ]] && [[ ! -r $KSFILE ]]; then
    echo "Invalid kickstart config file $KSFILE"
    help
    exit -1
fi

echo "Web root              : $WEBROOT"
echo "TFTP root             : $TFTPROOT"
echo "OS Name               : $OSNAME"
echo "OS Image Destination  : $OSDEST" 
echo "PXE Menu              : $PXEMENU"
echo "HTTP SERVER           : $HTTP_SERVER_IP"
echo "Kickstart config file : $KSFILE"
echo ""

echo "Do you want to add kickstart to PXE menu? Continuing is Enter. Stopping is Ctrl+C."
read 

if [[ ! -w $PXEMENU ]]; then
    echo "Can not write $PXEMENU"
fi

if [[ -r $KSFILE ]]; then
    # Kickstart Install

    # Copy kickstart config file.
    cp $KSFILE $WEBROOT/kickstart/$OSNAME/
    echo "Copy $KSFILE $WEBROOT/kickstart/$OSNAME/"

    KSNAME=$(basename $KSFILE)
    echo "" >> $PXEMENU
    echo "label $OSNAME Install ($KSNAME)" >> $PXEMENU
    echo "kernel kickstart/$OSNAME/iso/images/pxeboot/vmlinuz" >> $PXEMENU
    echo "append load devfs=nomount initrd=kickstart/$OSNAME/iso/images/pxeboot/initrd.img ks=http://$HTTP_SERVER_IP/kickstart/$OSNAME/$KSNAME" >> $PXEMENU

    echo "Add the option of kickstart install to $PXEMENU"
else
    # Manual Install
    echo "" >> $PXEMENU
    echo "label $OSNAME Install (Manual)" >> $PXEMENU
    echo "kernel kickstart/$OSNAME/iso/images/pxeboot/vmlinuz" >> $PXEMENU
    echo "append load devfs=nomount initrdl=kickstart/$OSNAME/iso/images/pxeboot/initrd.img inst.repo=http://$HTTP_SERVER_IP/kickstart/$OSNAME/iso" >> $PXEMENU

    echo "Add the option of manual install to $PXEMENU"
fi

echo "Complete."

