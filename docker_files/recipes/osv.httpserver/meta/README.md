# HTTP server for managing OSv
This package provides HTTP server for remote management of the unikernel.

## Usage
You only need to require this package and http server will
start automatically in its own thread when unikernel is booted.
Then access <unikernel-IP>:8000 in browser to browse the API.
More information about what requests are supported:
https://github.com/cloudius-systems/osv/wiki/Using-OSv-REST-API
