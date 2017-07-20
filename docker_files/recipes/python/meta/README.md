# Python 2.7
This package provides core Python 2.7 runtime environment. It includes default builtin modules.

## Usage
Run Python shell:
```
$ capstan run demo --boot python
```
This will launch default Python shell. To run a script, ensure the script is composed into the OSv
unikernel and then run it using
```
$ capstan run demo --boot python --env ARGS=script.py
```

## Limitations
This package currently contains only the core environement. In order to include third-party modules,
it is possible to add them to `pyenv/lib/python2.7/site-packages/` of your unikernel. However, any
shared object provided by the host system needs to be copied manually to the target unikernel.

For example, if you are using [virtualenv](https://virtualenv.pypa.io/en/stable/) you can use the
following command to find the shared objects used by your Python modules
```
$ cd VIRTUALENV_HOME
$ for so in `find . -iname "*.so"`; do ldd $so ; done | \
        sed 's/^\([^=(]*\)=>\([^(]*\).*$/\1=>\2/g; /=>/!d' | \
        sort | uniq | \
        grep -Pv 'lib(c|gcc|dl|m|util|rt|pthread|stdc\+\+).so'
```
Using this list, it is possible to find the shared objects as well as their locations and manually
copy those that are required.

In the future, we are going to provide a tool that will extract these automatically based on your
Python virtual environment.
