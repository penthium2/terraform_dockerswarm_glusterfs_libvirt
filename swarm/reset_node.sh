#!/bin/bash
if docker node ls | grep -qs 'Down' ; then
     docker node demote $(docker node ls | grep 'Down' | awk '{print $1}')
     docker node rm $(docker node ls | grep 'Down' | awk '{print $1}')
     docker service update portainer_portainer --force
fi
