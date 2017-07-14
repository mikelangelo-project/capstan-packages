# OpenJDK 8 Zulu Compact3 With Java Beans for OSv
This package provides JVM for your unikernel.

## Usage
```
$ capstan run demo --boot java --env MAIN=main.Hello --env CLASSPATH=/:/src
```
| ENV       |  MAPS TO     | DEFAULT VALUE  | EFFECT
|-----------|--------------|----------------|--------
| XMS       | -Xms         | 512m           | initial JVM memory
| XMX       | -Xmx         | 512m           | max JVM memory
| CLASSPATH | -cp          | /*             | column-separated classpaths
| JVM_ARGS  | arg          | -Duser.dir=/   | arguments prior main
| MAIN      | arg          | main.Hello     | full name of main class
| ARGS      | arg          | (empty)        | arguments after main

IMPORTANT: JVM_ARGS must not be empty string since Java cannot handle two sequential spaces.
At the very least use JVM_ARGS="-Dx=y". To provide more that one JVM argument, do it
like this: JVM_ARGS="-Duser.dir=/ -Dx=y".
