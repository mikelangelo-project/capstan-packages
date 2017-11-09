# OSv Bootstrap
This package provides basic functions that any OSv unikernel needs
like zfs.so, cpiod.so, mkfs.so and others. You are not supposed to
really run anything on your own from this package, but there is sleep
command provided in case you need it.

## Usage
a) Boot unikernel with its main thread sleeping (meanwhile, other threads
can run normally):
```
$ capstan run demo --boot sleep --env SLEEP_SECONDS=-1
```
This will sleep forever.

| ENV           |  MAPS TO     | DEFAULT VALUE      | EFFECT
|---------------|--------------|--------------------|--------
| SLEEP_SECONDS | arg0         | -1 (sleep forever) | do nothing, sleep

b) Boot unikernel that only prints Hello World and then exits:
```
$ capstan run demo --boot hellow_world
```

c) Boot unikernel that only prints "--- OSV REPORTING READY ---" and then exits:
```
$ capstan run demo --boot report_ready
```
