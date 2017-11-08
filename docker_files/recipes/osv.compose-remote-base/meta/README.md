# Remote Compose package for creating base
This package provides nothing but an 'init' run configuration
that gets stored into /run/init file. When run, it starts cpiod
tool on port 10000 and is ready to upload files.

## Usage
Require this package when you're preparing base image for your
cloud provider. Set bootcmd like this:

```
$ capstan package compose base --run "runscript /run/init;runscript /run/app"
```

When instance will be started out of such image, it will run the cpiod
tool and wait for you to upload files using `capstan package compose-remote`.
See also osv.compose-remote package that is automatically required by
compose-remote command.
