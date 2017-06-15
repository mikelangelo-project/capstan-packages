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
That's it! When container is done working, following directories appear in `./result` directory:
```bash
$ tree -L 2 result
result
├── intermediate
│   ├── erlang
│   ├── mysql
│   ├── node-4.4.5
│   ├── ...
├── log
│   ├── erlang.log
│   ├── mysql.log
│   ├── node-4.4.5.log
│   ├── ...
├── mike
│   └── osv-loader
│       ├── index.yaml
│       ├── osv-loader.qemu
│       └── osv-loader.qemu.gz
└── packages
    ├── erlang.mpm
    ├── erlang.yaml
    ├── mysql.mpm
    ├── mysql.yaml
    ├── node-4.4.5.mpm
    ├── node-4.4.5.yaml
    ├── ...
```
Where:

* `intermediate` directory contains uncompressed packages. As the name suggests, these are not final
results, but come handy if you need to peek in package content.
* `log` directory contains one file per package that was built e.g. `log/osv.cli.log`. Content of this
file is nothing but redirected `stdout` and `stdin` of the recipe's `build.sh` script. In other
words, when building recipe fails, this is where you find answers about what went wrong.
* `mike` directory contains compiled OSv kernel that is packaged into a small qemu image. Copy this
whole directory into your `$CAPSTAN_ROOOT/repository` and Capstan will be able to compose images
that base on `mike/osv-loader`.
* `packages` directory contains result of container execution - the Capstan packages. There are two
files for each package: `<package-name>.mpm` and `<package-name>.yaml`. The former contains actual
package files (that are in .tar.gz format, in case you were wondering) while the latter contains
package metadata. Copy this whole directory into your `$CAPSTAN_ROOOT` and Capstan will be able to
compose images that require these packages.

## Running container
When `mikelangelo-project/capstan-packages` container is run it builds and tests **all** recipes by
default:
```bash
$ docker run -it --volume="$PWD/result:/result" mikelangelo-project/capstan-packages
```
You can, however, customize container behavior by setting following environment variables:

| ENV | EXAMPLE VALUE | EFFECT |
|-----|---------------|--------|
| `RECIPES` |  eu.mikelangelo-project.osv.nfs | builds only recipes listed (comma-separated), `[]` means empty list (don't use brackets for non-empty list) |
| `SKIP_TESTS` |  no | do not run tests after building (tests are run by default) |
| `SHARE_OSV_DIR` | yes | should each recipe get its own copy of osv src dir (yes by default) |
| `TEST_RECIPES` | eu.mikelangelo-project.osv.nfs | test only recipes listed (comma-separated) |
| `KEEP_RECIPES` | yes | keep packages that are already in /result dir when mounted (yes by default) |

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

## More Documentation
* [Adding New Recipe](doc/recipes.md)
