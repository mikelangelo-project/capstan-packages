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
          |- pkg  # <--- directory containing demo package that requires the package that recipe is for
          |   |- meta
          |      |- package.yaml.templ
          |      |- run.yaml
          |- expected-stdout.txt  # <--- when demo package is run we expect following text in console
```

### Writing `build.sh` script
The `build.sh` script is responsible for providing all the content of the package, including
`meta/package.yaml` and optionally `meta/run.yaml`. Building is assumed successful when script exits
with 0 status code or failed when any other exit code is returned.

Container's main process (implemented in [capstan-packages.py](../docker_files/capstan-packages.py))
runs the `build.sh` script from within the recipe directory and provides following environment
variables to it:

| ENV | EXAMPLE VALUE | DESCRIPTION |
|-----|---------------|-------------|
| `RECIPE_DIR` | /recipes/eu.mikelangelo-project.osv.nfs | recipe directory |
| `PACKAGE_RESULT_DIR` | /results/eu.mikelangelo-project.osv.nfs | directory where build result must appear |
| `PACKAGE_NAME` | eu.mikelangelo-project.osv.nfs | same as directory name of recipe |
| `OSV_DIR` | /git-repos/osv | directory where OSv source code is |
| `OSV_BUILD_DIR` | /git-repos/osv/build/release.x64 | OSv build directory
| `GCCBASE` | /git-repos/osv/external/x64/gcc.bin | path to gcc base |
| `MISCBASE` | /git-repos/osv/external/x64/misc.bin | path to misc base |
| `PATH` | ... | copy of PATH of main process |

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

### Providing test for recipe
When a new MPM is built out of recipe we cannot be sure that it behaves well. At the very least we
should compose a unikernel that requires the new MPM and check if it boots properly. Directory `demo`
therefore offers you an option to provide a demo Capstan package definition that is then composed and
run by the main process. Decision whether demo was a success or a failure is done based on
`expected-stdout.txt` regex: if stdout of the unikernel matches the regex, test passess, otherwise it
fails.

Examine exisitng tests to see it in action.


