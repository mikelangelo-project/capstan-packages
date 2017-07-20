# Recipes
The `mikelangelo-project/capstan-packages` container iterates recipes in `/recipes` directory and
uses them to prepare Capstan packages.

## What is a Recipe
Recipe is a directory that contains `build.sh` script and optionally a `demo` subdirectory
that is used for testing. Structure of Recipe is as follows:
```
recipes
  |- eu.mikelangelo-project.osv.nfs  # <--- recipe
      |- build.sh
      |- demo     # <--- optional recipe test
      |   |- pkg  # <--- directory containing demo package that requires the package that recipe is for
      |   |   |- meta
      |   |      |- package.yaml.templ
      |   |      |- run.yaml
      |   |- expected-stdout.txt  # <--- when demo package is run we expect following text in console
      |- meta     # <--- content of this directory is copied as-it-is into package's meta/ directory
          |- README.md
          |- run.yaml
```

### Writing `build.sh` script
The `build.sh` script is responsible for providing all the content of the package, including
`meta/package.yaml`. Building is assumed successful when script exits with 0 status code or failed
when any other exit code is returned.

Container's main process (implemented in [capstan-packages.py](../docker_files/capstan-packages.py))
runs the `build.sh` script from within the recipe directory and provides following environment
variables to it:

| ENV | EXAMPLE VALUE | DESCRIPTION |
|-----|---------------|-------------|
| `COMMON_DIR` | /common | directory with files that are common to all patches |
| `CPU_COUNT` | 6 | number of CPUs available to container |
| `GCCBASE` | /git-repos/osv/external/x64/gcc.bin | path to gcc base |
| `HOME` | /root | $HOME |
| `JAVA_HOME` | /usr/lib/jvm/java-8-oracle | $JAVA_HOME |
| `MISCBASE` | /git-repos/osv/external/x64/misc.bin | path to misc base |
| `OSV_DIR` | /git-repos/osv | directory where OSv source code is |
| `OSV_BUILD_DIR` | /git-repos/osv/build/release.x64 | OSv build directory
| `PACKAGE_NAME` | osv.nfs | same as directory name of recipe |
| `PACKAGE_RESULT_DIR` | /results/osv.nfs | directory where build result must appear |
| `PATH` | ... | copy of PATH of main process |
| `RECIPE_DIR` | /recipes/osv.nfs | recipe directory |

Following statements are true:

* `$PACKAGE_RESULT_DIR` is guaranteed to exist and is empty when script is called.
* It is `build.sh`'s task to fill `$PACKAGE_RESULT_DIR` with content that will be packaged into MPM.
* `$OSV_DIR` points to the OSv source code. It is guaranteed that
`git submodule update --init --recursive` and then `make` were run.
* `build.sh` can apply any patches in `$OSV_DIR` and `$OSV_BUILD_DIR` and does not need to undo them.
That's because each recipe will be run with its own copy of the OSv source directory that is then
discarded.

When implementing a `build.sh` script bear in mind that in the end the `$PACKAGE_RESULT_DIR` will be
compressed into MPM package using `capstan package build` command.

### Providing `meta/run.yaml` and `README.md` for recipe
Generally, your `build.sh` script is supposed to provide all the content of the package. But there is
a shortcut available for package's meta/ directory which can be described as follows: if your recipe
contains `meta/` directory, then all its content is copied into package's `meta/` directory right after
the `build.sh` script has finished its work.

The shortcut is convenient to be used when providing meta/run.yaml and README.md for your package.
It can also be used to provide meta/package.yaml, but it is advised that we provide that one from
within build.sh script in order to be able to make use of `${PACKAGE_NAME}` variable for package name.


### Providing test for recipe
When a new MPM is built out of recipe we cannot be sure that it behaves well. At the very least we
should compose a unikernel that requires the new MPM and check if it boots properly. Directory `demo`
therefore offers you an option to provide a demo Capstan package definition that is then composed and
run by the main process. Decision whether demo was a success or a failure is done based on
`expected-stdout.txt` regex: if stdout of the unikernel matches the regex, test passess, otherwise it
fails.

Examine exisitng tests to see it in action.

## Debugging
When container gets stopped, all the temporary results are discarded. Only content of `/result` directory
is persisted on host if it was mounted when the container was run. Therefore container is never stopped
automatically - it waits for you to press CTRL + C to stop it.

While container is running, you can connect to it to manually experiment inside it. First query
container ID:
```bash
$ docker ps
CONTAINER ID        IMAGE                          COMMAND                  CREATED
f510a69c74e3        mikelangelo/capstan-packages   "/bin/sh -c 'pytho..."   13 seconds ago
```
and then connect:
```bash
$ docker exec -it f510a69c74e3 /bin/bash
root@f510a69c74e3:/git-repos/osv#
```
There you go, experiment however you want. Bear in mind that everything will be discarded when the
container is stopped.


