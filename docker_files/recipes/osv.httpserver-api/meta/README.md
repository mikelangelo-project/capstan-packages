# HTTP server API for managing OSv (backend)
This package provides HTTP server for remote management of the unikernel.
GUI for the server is available in package osv.httpserver-html5-gui.

## Usage
You only need to require this package and http server will
start automatically in its own thread when unikernel is booted.
Then send requests to <unikernel-IP>:8000 in browser to use the API.
More information about what requests are supported:
https://github.com/cloudius-systems/osv/wiki/Using-OSv-REST-API
