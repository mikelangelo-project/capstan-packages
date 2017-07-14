# NFS (Network File System) Client for OSv
This packge enables you to mount/unmount nfs volume by url.

## Usage
Mount nfs:
```
$ capstan run demo --boot mount-nfs --env NFS_ENDPOINT=92.168.122.1/mydir/?uid=0 --env NFS_MOUNT=/mydir
```
| ENV          |  MAPS TO     | DEFAULT VALUE              | EFFECT
|--------------|--------------|----------------------------|--------
| NFS_ENDPOINT | arg1         | 192.168.122.1/mydir/?uid=0 | nfs server endpoint
| NFS_MOUNT    | arg2         | /mydir                     | osv directory to mount to

Unmount nfs:
```
$ capstan run demo --boot unmount-nfs --env NFS_MOUNT=/mydir
```
| ENV          |  MAPS TO     | DEFAULT VALUE              | EFFECT
|--------------|--------------|----------------------------|--------
| NFS_MOUNT    | arg          | /mydir                     | osv directory to mount to

Usually you will want to chain some command after mounting the nfs:
```
$ capstan run demo --execute "runscript /run/mount-nfs; runscript /run/myapp" \
    --env NFS_ENDPOINT=92.168.122.1/mydir/?uid=0 --env NFS_MOUNT=/mydir
```
