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

d) Mount volume
```
$ capstan run demo --boot format_volume --env VOLUME_IDX=1 --env VOLUME_MOUNT=/volume
```
This will ZFS-format whatever is attached to /dev/vblk1 and mount it to /volume.

| ENV           |  MAPS TO     | DEFAULT VALUE      | EFFECT
|---------------|--------------|--------------------|--------
| VOLUME_IDX    | -            | 1                  | what index of /dev/vblk{index} to format
| VOLUME_MOUNT  | -            | /volume            | where to mount volume to

There are some shortcut configurations available:

```
$ capstan run demo --boot format_volume1 --env VOLUME1_MOUNT=/volume
$ capstan run demo --boot format_volume2 --env VOLUME2_MOUNT=/volume
$ capstan run demo --boot format_volume3 --env VOLUME3_MOUNT=/volume
```
They will format and mount volume with corresponding index to VOLUME1_MOUNT, which is /volume by default.
