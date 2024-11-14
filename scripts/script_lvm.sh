#!/bin/bash

echo "Genero particiones"

#5GB
sudo fdisk /dev/sdc << EOF
n




t
8e
w
EOF

#Limpiar mugre del disco
sudo wipefs -a /dev/sdc1

#VG
sudo vgcreate vg_datos /dev/sdc1

#LV
sudo lvcreate -L +10M vg_datos -n lv_docker
sudo lvcreate -L +2.5G vg_datos -n lv_workareas

sudo mkfs.ext4 /dev/mapper/vg_datos-lv_docker
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_workareas

sudo mkdir -p /var/lib/Docker
sudo mkdir -p /work

echo "/dev/mapper/vg_datos-lv_docker /var/lib/docker ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "/dev/mapper/vg_datos-lv_workareas /work ext4 defaults 0 0" | sudo tee -a /etc/fstab

#3GB

sudo fdisk /dev/sdd << EOF
n




t
8e
w
EOF

#VG
sudo vgcreate vg_temp /dev/sdd1

#LV
sudo lvcreate -L +2.5G vg_temp -n lv_swap

sudo mkswap /dev/mapper/vg_temp-lv_swap

echo "/dev/mapper/vg_temp-lv_swap none swap sw 0 0" | sudo tee -a /etc/fstab

sudo swapon
sudo mount -a

#2GB

sudo fdisk /dev/sde << EOF
n



+1G
t
82
w
EOF

echo "LVM terminado..."
