# External script.
set -x
wget http://{{ HTTP_SERVER_IP }}/kickstart/CentOS_6.5/postscript.sh -o /root/postscript.sh
%include /root/postscript.sh

# Add myself to grub.conf.
mount /dev/sda1 /boot
echo "title CentOS 6.5" >> /boot/grub/grub.conf
echo -e "\troot (hd0,0)" >> /boot/grub/grub.conf
echo -e "\tkernel /vmlinuz-2.6.32-431.el6.x86_64 ro root=/dev/mapper/VolGroup-lv_root_centos65 rd_NO_LUKS LANG=en_US.UTF-8 rd_NO_MD rd_LVM_LV=VolGroup/lv_swap SYSFONT=latarcyrheb-sun16 rd_LVM_LV=VolGroup/lv_root_centos65  KEYBOARDTYPE=pc KEYTABLE=us crashkernel=auto rhgb quiet rd_NO_DM rhgb quiet" >> /boot/grub/grub.conf
echo -e "\tinitrd /initramfs-2.6.32-431.el6.x86_64.img" >> /boot/grub/grub.conf

