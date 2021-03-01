# manage-pod

So far we have learned how Podman is great compared to Docker in terms of security (just think about the ability to run rootless containers), alignment with OCI standards and strong integration with native Linux technologies like systemd. But the most important reason behind its name, Podman, is truly the ability to create [Pods](https://kubernetes.io/docs/concepts/workloads/pods/).

Instead of creating naked containers, just like Dockers is only capable to do, Podman can create pods just like Kubernetes and run one or more containers inside them.

There are numerous benefits that come with Pods, even for stand-alone (local) deployments as we have using Podman. First of all, you have the ability to couple containers that are intended to work together, like a web app and its database, and avoid to expose the sensitive data on the network. A more complex scenario that comes to my mind involves certain type of applications that are implemented with System V semaphores or POSIX shared memory. Containers in a Pod can communicate with each other using these types of inter-process communications.

## Tutorial

In this tutorial we are going to deploy a WordPress instance made of two containers — the WordPress itself and a MySQL database — created inside the very same Pod. 

First, we need to create a pod. Once the containers are enveloped inside of a Pod, the port forwarding has to be configured at the Pod level:

```
$ sudo podman pod create --name wp_pod -p 127.0.0.1:80:80
79168c838db4c1a5a501ee1e5ae05b6f233613849d1aa3030
```

```
$ sudo podman pod ps
POD ID        NAME    STATUS   CREATED        INFRA ID      # OF CONTAINERS
ea8fa71f2aa4  wp_pod  Created  3 seconds ago  c6c66510db7a  1
```

We notice that our pod has been created and there is an infra container inside. The purpose of the infra container is to maintain the network namespace of the Pod and allow incoming connections to the other containers. It does nothing but it let the pod live even if other containers are stopped. 

```
$ $ sudo podman ps --pod -a
CONTAINER ID  IMAGE                 CREATED         STATUS   PORTS                 NAMES               POD ID        PODNAME
6e2a42529c8a  k8s.gcr.io/pause:3.2  24 seconds ago  Created  127.0.0.1:80->80/tcp  c5340a2dc114-infra  c5340a2dc114  wp_pod
```

The first container we are going to create is the database. It's a simple `podman run` but now we need to specify the Pod name with `--pod wp_pod`:

```
$ sudo podman run -d --name db \
                  -e MYSQL_USER=wordpress \
                  -e MYSQL_PASSWORD=wordpress \
                  -e MYSQL_DATABASE=wordpress \
                  -e MYSQL_ROOT_PASSWORD=somewordpress \
                  --pod wp_pod registry.access.redhat.com/rhscl/mysql-57-rhel7
Trying to pull registry.access.redhat.com/rhscl/mysql-57-rhel7:latest...
Getting image source signatures
Copying blob f1e961fe4c51 done  
...  
Copying config 60726b33a0 done  
Writing manifest to image destination
Storing signatures
0385e9628b5e349b931c138fd550d7c40cb78a7ed2ec8a4a7a71deace805a9ea
```
We can briefly test the database readiness checking the exit status of a simple query:
```
$ sudo podman exec db bash -c 'mysql -u root -e "SELECT 1" &> /dev/null'; echo $?
0
```
and finally create the WordPress container. Notice that the environment variable `WORDPRESS_DB_HOST` is pointing to port 3306 on 127.0.0.1 address. This because containers in the same Pod shares the same network namespace, thus they refer to each other on a certain port on localhost. 

```
$ sudo podman run -d --name wp \
                  -e WORDPRESS_DB_HOST=127.0.0.1:3306 \
                  -e WORDPRESS_DB_USER=wordpress \
                  -e WORDPRESS_DB_PASSWORD=wordpress \
                  -e WORDPRESS_DB_NAME=wordpress \
                  --pod wp_pod quay.io/redhattraining/wordpress:5.3.0
                  Trying to pull quay.io/redhattraining/wordpress:5.3.0...
Getting image source signatures
Copying blob a2427b8dd6e7 done  
...  
Copying config ee025cbcbc done  
Writing manifest to image destination
Storing signatures
c24a1dca93dd4a6770cd5b55eb8fcc33a5b35074b75370857aa92b7f10a0f4f1

```

We can also test if WordPress is up and running. Recall that Pod port 80 has been forwarded to our workstation's localhost address:

```
$ curl -I http://127.0.0.1/wp-admin/install.php
HTTP/1.1 200 OK
Date: Sat, 27 Feb 2021 17:05:57 GMT
Server: Apache/2.4.38 (Debian)
X-Powered-By: PHP/7.3.12
Expires: Wed, 11 Jan 1984 05:00:00 GMT
Cache-Control: no-cache, must-revalidate, max-age=0
Content-Type: text/html; charset=utf-8
```

We can now see that our Pod is currently running 3 containers (wp, db and infra):

```
$ sudo podman pod ps
POD ID        NAME    STATUS   CREATED         INFRA ID      # OF CONTAINERS
79168c838db4  wp_pod  Running  30 minutes ago  152ddc7df478  3
```
```
[sstagnaro@inverary ~]$ $ sudo podman ps --format="{{.ID}} {{.PodName}} {{.Names}} {{.Status}}"
c24a1dca93dd wp_pod wp Up 34 minutes ago 
0385e9628b5e wp_pod db Up 40 minutes ago 
152ddc7df478 wp_pod 79168c838db4-infra Up 40 minutes ago
```

## Practice

In this directory you can find a Bash script called [wp_pod.sh](./wp_pod.sh) that will reproduce all the steps depicted in the tutorial, with the addition of a persistent volume for the database. Feel free to review the script and modify it to fit your needs.

In the script I have added a `readiness()` function to check the status of a certain container before proceeding further. In a production environment with OpenShift you should accomplish this task with [Init Containers](https://docs.openshift.com/container-platform/latest/nodes/containers/nodes-containers-init.html) inside the Pod, but unfortunately they're [not yet available in Podman](https://github.com/containers/podman/issues/6480). 

The second script, [wp_pod_cleanup.sh](./wp_pod_cleanup.sh), is only intended for cleaning up the environment quickly.

## Further readings

Most of the content of this document is inspired to the awesome [Podman: Managing pods and containers in a local container runtime](https://developers.redhat.com/blog/2019/01/15/podman-managing-containers-pods/) article by Brent Baude. 

