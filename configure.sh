#!/bin/bash

# grub
sed -i '/GRUB_DEFAULT/c GRUB_DEFAULT=2' /etc/default/grub
sed -i '/GRUB_TIMEOUT/c GRUB_TIMEOUT=5' /etc/default/grub
update-grub

# PS1
sed -i '/PS1/s/w/W/g' ~/.bashrc
