# Node.js 4.8.2
This package provides Node.js support for your unikernel.

## Usage
```
$ capstan run demo --boot node --env MAIN=/server.js
```
| ENV       |  MAPS TO     | DEFAULT VALUE    | EFFECT
|-----------|--------------|------------------|--------
| NODE_ARGS | arg          | --no-deprecation | arguments prior main
| MAIN      | arg          | /mymain.js       | full name of main class
| ARGS      | arg          | (empty)          | arguments after main

IMPORTANT: NODE_ARGS must not be empty string due to bug in OSv. At the very least use NODE_ARGS="--no-deprecation".
To provide more that one JVM argument, do it like this: NODE_ARGS="--no-deprecation --v8-options".
