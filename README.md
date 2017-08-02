# Capstan Packages
This repository contains Dockerfile for `mikelangelo/capstan-packages` Docker container that
recompiles `mike/osv-loader` base image and all the Capstan packages (that are maintained by
MIKELANGELO project) from scratch.

## Quick usage
Fastest way is to pull container from DockerHub:
```bash
$ docker pull mikelangelo/capstan-packages:2017-07-12_c601abb
```
*NOTE: container tag is composed like this: `<compile-date>_<osv-commit>`. So you can know what OSv
commit you have in the container. Navigate to
[mikelangelo dockerhub repo](https://hub.docker.com/r/mikelangelo/capstan-packages/tags/)
to see available tags*

Once having it on your machine, you can run it with:
```bash
$ mkdir ./result
$ docker run -it --privileged --volume="$PWD/result:/result" mikelangelo/capstan-packages
```
*NOTE: the `--privileged` flag is needed in order to enable KVM inside container. Container will
still work without the flag, but recipe tests will last longer.*

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
When `mikelangelo/capstan-packages` container is run it builds and tests **all** recipes by
default:
```bash
$ docker run -it --privileged --volume="$PWD/result:/result" mikelangelo/capstan-packages
```
You can, however, customize container behavior by setting following environment variables:

| ENV | EXAMPLE VALUE | EFFECT |
|-----|---------------|--------|
| `RECIPES` |  osv.nfs | builds only recipes listed (comma-separated), `[]` means empty list (don't use brackets for non-empty list). By default it builds all recipes i.e. `RECIPES=all`. |
| `SKIP_TESTS` |  no | do not run tests after building (tests are run by default) |
| `SHARE_OSV_DIR` | yes | should each recipe get its own copy of osv src dir (yes by default) |
| `TEST_RECIPES` | osv.nfs | test only recipes listed (comma-separated), `[]` means empty list (don't use brackets for non-empty list). By default it is a copy of `RECIPES`. To test all recipes use `TEST_RECIPES=all`. |
| `KEEP_RECIPES` | yes | keep packages that are already in /result dir when mounted (yes by default) |

To build only `osv.nfs` package, for example, you can use following command:
```bash
$ docker run -it --privileged --volume="$PWD/result:/result" --env RECIPES=osv.nfs mikelangelo/capstan-packages
```

### Using local recipes
The container image contains all recipes from this repository (located in `docker_files/recipes`
directory). To use your own recipe, you can either add it into the `docker_files/recipes` and
rebuild the whole container or you can attach local directory containing your own recipes into
container's `/user_recipes` directory using `--volume` argument.

For example, to make directory `/home/user/my_recipes` recognizable by the container, run it with
```bash
docker run --volume="/home/user/my_recipes:/user_recipes" ...
```

## Building container
This section describes how to build `mikelangelo/capstan-packages` from scratch. Result will
be Docker image in your local Docker repository.

Go ahead, clone our repository:
```bash
$ git clone git@github.com:mikelangelo-project/capstan-packages.git
```
To build the container execute:
```bash
$ cd capstan-packages
$ docker build -t mikelangelo/capstan-packages .
```
Building will take somewhat 10 minutes since it does many things:

1. clone latest [OSv repository](https://github.com/cloudius-systems/osv) master
2. clone latest [OSv Apps repository](https://github.com/cloudius-systems/osv-apps)
3. `make` whole OSv
4. clone latest [Capstan repository](https://github.com/mikelangelo-project/capstan)
5. build Capstan binary

When building completes, you can verify that the Docker image is in your repository:
```bash
$ docker images | grep mikelangelo/capstan-packages
mikelangelo/capstan-packages   latest   bee017f1e55c   16 hours ago   2.82 GB
```

## More Documentation
* [Adding New Recipe](doc/recipes.md)
* [Pushing image to DockerHub](doc/dockerhub.md)

