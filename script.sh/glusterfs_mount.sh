#!/bin/bash
sed -i '$alocalhost:/docker /srv/docker_swarm glusterfs defaults,_netdev,noauto,x-systemd.automount 0 0' /etc/fstab
mkdir /etc/systemd/system/glusterfs.mount.d
systemctl daemon-reload
mount /srv/docker_swarm