# OpenFOAM porousSimpleFoam solver
This package provides a solver provided by OpenFOAM.

## Usage
To run the solver on a provided OpenFOAM case, you should compose the unikernel with the case.
```
$ capstan run demo --boot porousSimpleFoam --env FOAM_CASE_DIR=/case
```
| ENV            |  MAPS TO | DEFAULT VALUE  | EFFECT
|----------------|----------|----------------|--------
| FOAM_CASE_DIR  | -case    | /case          | location of your OpenFOAM case
| FOAM_ARGS      | arg      | (empty)        | additional arguments
| WM_PROJECT_DIR | env      | /openfoam      | location of core FOAM libraries
