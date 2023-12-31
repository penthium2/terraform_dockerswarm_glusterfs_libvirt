#!/bin/bash
for vm in $(awk "/${VM}[^0]/ {print $NF}" /etc/hosts) ; do
    gluster peer probe "$vm"
done
sleep 5
gluster volume create docker replica $(grep "${VM}" /etc/hosts | wc -l) transport tcp $(awk '/${VM}/ {print $1":/var/glusterfs/no-direct-write-here/docker/brick1"}' /etc/hosts) force
gluster volume start docker
sleep 5
