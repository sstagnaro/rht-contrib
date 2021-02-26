#!/usr/bin/env bash

sudo podman rm -f db wp
sudo podman pod rm -f wp_pod
sudo podman volume rm -a -f
