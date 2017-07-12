# Apache Spark 2.1.1 (on top of Hadoop 2.7.3)
## Description
This package provides logic for both Spark Master and Spark Worker.
Only difference between the two is bootcmd used to run the unikernel.

## Usage
Run master:
$ capstan run myspark --boot master

Run worker:
$ capstan run myspark --boot worker --env MASTER=localhost:7077
MASTER -> endpoint of your Spark master

## Limitations
This unikernel was tested on image size of 1GB.
