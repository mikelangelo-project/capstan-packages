# OSv cloud-init
This package brings cloud-init functionality to OSv.

## Usage
You only need to require this package and cloud-init is enabled. To actually make use of the
cloud-inti you need to performs following steps:

## NoCloud

### 1. Specify user-data yaml file
The user-data file supports many options, but let's focus on `run:` that allows you to execute
any number of commands supported by osv.httpserver-api package (visit http://osv.io/api/swagger-ui/dist/index.html
to see a list of all supported commands). Below please find an example where we first set
two environment variables (PORT and UIPORT) and then run our application specify arbitrary
bootcmd that will be run in a new thread on the OSv unikernel.

```yaml
# meta/user-data.yaml

run:
  - POST: /env/PORT
     val: 7077
  - POST: /env/UIPORT
     val: 8080
  - PUT: /app/
     command: "runscript /run/hello-world"
```

Another option is `files:` that lets you create one or more files with given content:

```yaml
# meta/user-data.yaml

files:
  /configuration.conf: |
     This is the content of
     my configuration file.
```

### 2. Bake the user-data file on ISO9660 disk
At the moment we need to manually bake user-data onto a ISO9660 disk by using external tool called
cloud-localds:

```
cloud-localds -d raw ./cloud-init.iso ./meta/user-data.yaml
```

This will produce ./cloud-inits.iso disk that should be attached to the OSv unikernel in order cloud-init to
get used.

### 3. Attach the disk to the OSv unikernel (using Capstan)

```bash
$ capstan run demo \
   --boot sleep \
   --volume ./cloud-init.iso
```

There are two important arguments used here:

* `--boot sleep` sets bootcmd for the unikernel (the main thread). We want the main thread to sleep forever
    because we will run application via cloud-init in a new thread. The "/run/sleep" configuration is provided by
    osv.bootstrap package.
* `--volume ./cloud-init.iso` attaches the cloud-init disk to the OSv unikernel. Make sure that in case you're attaching
    other volumes as well besides the cloud-init disk, the cloud-init must be listed **first**.

## Cloud Providers

### OpenStack
OpenStack cloud-init is supported (the one where file gets served on 169.254.169.254). Example configuration script:

```
#cloud-config
run:
- PUT: /app/
  command: "runscript /run/hello_world"
```

## Limitations
Following cloud-init implementations are supported:

*  OpenStack/AWS/GCE cloud-init
* ISO9660 cloud-init

Read this documentation about supported fields:
https://github.com/cloudius-systems/osv/wiki/Cloud-init
