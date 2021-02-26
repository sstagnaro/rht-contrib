# manage-pod



```
$ miopod=$(sudo podman pod create --name wp_pod -p 127.0.0.1:80:80)
```

```
$ miovol=$(sudo podman volume create)
```

```
$ pathmiovol=$(sudo podman volume inspect $miovol -f "{{.Mountpoint}}")
```

```
$ sudo chown -R 27:27 $pathmiovol
```

```
$ sudo podman run -d --name db -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -e MYSQL_DATABASE=wordpress -e MYSQL_ROOT_PASSWORD=somewordpress -v $miovol:/var/lib/mysql/data --pod $miopod registry.access.redhat.com/rhscl/mysql-57-rhel7
```

```
$ sudo podman run -d --name wp -e WORDPRESS_DB_HOST=127.0.0.1:3306 -e WORDPRESS_DB_USER=wordpress -e WORDPRESS_DB_PASSWORD=wordpress -e WORDPRESS_DB_NAME=wordpress --pod $miopod quay.io/redhattraining/wordpress:5.3.0
```

Cerco l'infra-container del Pod
```
$ sudo podman ps -a
```

Cerco l'IP dell'infra container
```
$ sudo podman inspect wp -f "{{.NetworkSettings.IPAddress}}"
```
