#!/bin/bash
dnf install -y glusterfs-server
systemctl enable glusterd --now
firewall-cmd --zone=public --add-service=glusterfs --permanent
#firewall-cmd --add-port=24007/tcp --permanent
firewall-cmd --reload
mkdir -p /var/glusterfs/no-direct-write-here/docker/brick1
mkdir -p /srv/docker_swarm
