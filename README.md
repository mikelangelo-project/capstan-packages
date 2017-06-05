# Capstan Packages
This repository contains Dockerfile for `mikelangelo-project/capstan-packages` Docker container that
recompiles `mike/osv-loader` base image and all the Capstan packages (that are maintained by
MIKELANGELO project) from scratch.

## Quick usage
Fastest way is to pull container from DockerHub:
```bash
$ docker pull mikelangelo-project/capstan-packages
```
*NOTE: At this time `mikelangelo-project/capstan-packages` is not uploaded to DockerHub yet due to active
development. Instead you have to build it on your own (see section below). Building Docker container
is a very simple task, but you have to wait quite some time.*

Once having it on your machine, you can run it with:
```bash
$ mkdir ./result
$ docker run -it --volume="$PWD/result:/result" mikelangelo-project/capstan-packages
```
That's it! When container is done working result appears in `./result` directory:
```bash
$ ls -l ./result
total 7412
drwxrwxrwx 9 root root    4096 jun  1 13:30 eu.mikelangelo-project.osv.bootstrap
-rwxrwxrwx 1 root root 1284804 jun  1 13:30 eu.mikelangelo-project.osv.bootstrap.mpm
-rwxrwxrwx 1 root root     137 jun  1 13:30 eu.mikelangelo-project.osv.bootstrap.yaml
-rwxrwxrwx 1 root root     134 jun  1 13:30 index.yaml
-rwxrwxrwx 1 root root 6291456 maj 31 14:21 osv-loader.qemu
```

## Running container
When `mikelangelo-project/capstan-packages` container is run it builds and tests **all** recipes by
default:
```bash
$ docker run -it --volume="$PWD/result:/result" mikelangelo-project/capstan-packages
```
You can, however, customize container behavior by setting following environment variables:

| ENV | EXAMPLE VALUE | EFFECT |
|-----|---------------|--------|
| `RECIPES` |  eu.mikelangelo-project.osv.nfs | builds only recipes listed (comma-separated) |
| `SKIP_TESTS` |  no | do not run tests after building (tests are run by default) |
| `SHARE_OSV_DIR` | yes | should each recipe get its own copy of osv src dir (yes by default) |
| `SHOW_STDOUT` | no | show stdout/stderr of build.sh also on success (no by default) |
| `TEST_RECIPES` | eu.mikelangelo-project.osv.nfs | test only recipes listed (comma-separated) |

To build only `nfs` package, for example, you can use following command:
```bash
$ docker run -it --volume="$PWD/result:/result" --env RECIPES=eu.mikelangelo-project.osv.nfs mikelangelo-project/capstan-packages
```

## Building container
This section describes how to build `mikelangelo-project/capstan-packages` from scratch. Result will
be Docker image in your local Docker repository.

Go ahead, clone our repository:
```bash
$ git clone git@github.com:mikelangelo-project/capstan-packages.git
```
To build the container execute:
```bash
$ cd capstan-packages
$ docker build -t mikelangelo-project/capstan-packages .
```
Building will take somewhat 10 minutes since it does many things:

1. clone latest [OSv repository](https://github.com/cloudius-systems/osv) master
2. clone latest [OSv Apps repository](https://github.com/cloudius-systems/osv-apps)
3. `make` whole OSv
4. clone latest [Capstan repository](https://github.com/mikelangelo-project/capstan)
5. build Capstan binary

When building completes, you can verify that the Docker image is in your repository:
```bash
$ docker images | grep mikelangelo-project/capstan-packages
mikelangelo-project/capstan-packages   latest   bee017f1e55c   16 hours ago   2.82 GB
```
