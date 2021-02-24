# **buildah-operations**

Buildah is a great tool for building Open Container Initiative (OCI) images but it never get mentioned in the DO180 course, even if — and I'm quoting **podman-build(1)** here — `podman build` uses code sourced from the `buildah` project to build container images.

Buildah can create an image from a Dockerfile — or a more standard Containerfile — simply issuing `buildah bud -t mytag .` just as Podman (`podman build -t mytag .`) and Docker (`docker build -t mytag .`) are already doing. But even if writing Dockerfiles is the most widespread method, there is a more interesting way for creating container images. This is what are called *Buildah native commands*.

## Buildah native commands

With Buildah you can directly interact with the temporary container used for the build process. In the lecture, I start showing how to create a working-container with `buildah from scratch` command and then perform customizations with `buildah run`, `buildah config` and finally closing up with `buildah commit`.

One awesome resource I use to prepare my lecture and live demo is the [**Buildah Tutorial 1**](https://github.com/containers/buildah/blob/master/docs/tutorials/01-intro.md). Even [Creating small containers with Buildah](https://opensource.com/article/18/5/containers-buildah) from Tom Sweeney and [Getting started with Buildah](https://opensource.com/article/18/6/getting-started-buildah) from Chris Collins are great blogposts.

## Guided Excercise

In this directory you can find two Bash scripts that are intended to replicate the very same [Dockerfile](./Dockerfile) prestented in the dockerfile-create guided excercise of DO180, but using *Buildah native commands* instead.

The first script, [buildah.sh](./buildah.sh), is a simplest 1:1 conversion from Dockerfile.

In the second script, [buildah_mount.sh](./buildah_mount.sh), I tried to demostrate the power of Buildah, mounting the container overlay on the host and then perform actions like packages installation from the local `yum` instance.

If you have time, you can run all the three builds (the Dockerfile and the two scripts) alongside with `time` and compare the results.