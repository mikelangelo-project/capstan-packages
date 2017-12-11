# Remote Compose package for contextualizing remote instance
This package provides nothing but an 'init' run configuration
that gets stored into /run/init file. When run, it sleeps for 0
seconds, effectively doing nothing.

This package is required automatically by `capstan package compose-remote` command
so you shouldn't need to require it manually. The purpose of the package is to
neutralize the osv.compose-remote-base package once the unikernel is contextualized
i.e. when the files are uploaded.

## Usage
Just bear in mind that remote instance has following bootcmd set:

```
runscript /run/init;runscript /run/app
```

The first part of the command (`runscript /run/init`) will return immediately resulting in
`runscript /run/app` acting like the only bootcmd. So in your current package you need to make
sure that you provide run configuration named "app" in order for it to get booted in the instance.
