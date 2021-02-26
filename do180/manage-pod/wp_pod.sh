#!/usr/bin/env bash

set -e

miopod=$(sudo podman pod create --name wp_pod -p 127.0.0.1:80:80)

miovol=$(sudo podman volume create)

pathmiovol=$(sudo podman volume inspect $miovol -f "{{.Mountpoint}}")

sudo chown -R 27:27 $pathmiovol

sudo podman run -d --name db -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -e MYSQL_DATABASE=wordpress -e MYSQL_ROOT_PASSWORD=somewordpress -v $miovol:/var/lib/mysql/data --pod $miopod registry.access.redhat.com/rhscl/mysql-57-rhel7

sudo podman run -d --name wp -e WORDPRESS_DB_HOST=127.0.0.1:3306 -e WORDPRESS_DB_USER=wordpress -e WORDPRESS_DB_PASSWORD=wordpress -e WORDPRESS_DB_NAME=wordpress --pod $miopod quay.io/redhattraining/wordpress:5.3.0

set +e

for wp_retries in {1..9}; do

  wp_return=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1/wp-admin/install.php)

  if [ $wp_return == 200 ]; then
    echo -e "\nWordPress instance ready at http://127.0.0.1\n"
    break
  fi

  echo "Waiting for WordPress to come up..."
  sleep 2
done
