#!/usr/bin/env bash
#
# A simple script to test Podman pods
# Author: Stefano Stagnaro <sstagnar@redhat.com>

# A simple readiness function accepting a name and a probe
readiness() {
  servicename="$1"
  echo -n "Waiting for $servicename to come up..."
  shift

  for retries in {1..13}; do
    timeout 1 "$@" &> /dev/null && echo -e "OK\n" && return 0
    echo -n .
    sleep 1
  done

  >&2 echo -e "FAIL\n\nERROR: $servicename instance not ready. Check pods, containers and volumes\n"
  return 1
}

set -e

# Creating the pod with forwarding (publish) of port 80
miopod=$(sudo podman pod create --name wp_pod -p 127.0.0.1:80:80)

# Creating a persistent volume for the MySQL container
miovol=$(sudo podman volume create)

# Getting the path of the persistent volume
pathmiovol=$(sudo podman volume inspect $miovol -f "{{.Mountpoint}}")

# Setting permissions for MySQL on the persistent volume
sudo chown -R 27:27 $pathmiovol

# Creating and running the MySQL container
sudo podman run -d --name db -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -e MYSQL_DATABASE=wordpress -e MYSQL_ROOT_PASSWORD=rootpwd -v $miovol:/var/lib/mysql/data --pod $miopod registry.access.redhat.com/rhscl/mysql-57-rhel7

# Checking readiness for MySQL service
readiness "MySQL" sudo podman exec db bash -c 'mysql -u root -e "SELECT 1"'

# Creating and running the WordPress container
sudo podman run -d --name wp -e WORDPRESS_DB_HOST=127.0.0.1:3306 -e WORDPRESS_DB_USER=wordpress -e WORDPRESS_DB_PASSWORD=wordpress -e WORDPRESS_DB_NAME=wordpress --pod $miopod quay.io/redhattraining/wordpress:5.3.0

# Checking readiness for WordPress
readiness "WordPress" curl -s -o /dev/null http://127.0.0.1/

# This last message will not be shown if readiness fails because of the set -e
echo -e "WordPress instance ready at http://127.0.0.1\n"

