# OpenFOAM Core 2.4.0
This package provides core libraries, binaries and default configuration required
by the OpenFOAM solvers.

## Usage
You only need to require this package and the libraries become available.
In fact, the openfoam.core package is included in solvers so you shouldn't
need to require this package manually.

Note that configuration files reside inside /openfoam directory so solvers will need
to set WM_PROJECT_DIR=/openfoam environment variable.
