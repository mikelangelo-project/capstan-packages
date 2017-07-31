# Apache Spark 2.1.1 (on top of Hadoop 2.7.3)
This package provides logic for both Spark Master and Spark Worker.
Jobs are expected to be written in Scala.

## Usage
Run Spark master:
```
$ capstan run myspark --boot master --env PORT=7077
```
| ENV    |  MAPS TO     | DEFAULT VALUE  | EFFECT
|--------|--------------|----------------|--------
| XMS    | -Xms         | 512m           | initial JVM memory
| XMX    | -Xmx         | 512m           | max JVM memory
| HOST   | --host       | 0.0.0.0        | endpoint of your Spark master
| PORT   | --port       | 7077           | endpoint of your Spark master
| UIPORT | --webui-port | 8080           | endpoint of your Spark master

Run Spark worker:
```
$ capstan run myspark --boot worker --env MASTER=localhost:7077
```
| ENV    |  MAPS TO | DEFAULT VALUE  | EFFECT
|--------|----------|----------------|--------
| XMS    | -Xms     | 512m           | initial JVM memory
| XMX    | -Xmx     | 512m           | max JVM memory
| MASTER | arg      | localhost:7077 | endpoint of your Spark master

## Limitations
This unikernel was tested on image size of 300 MB.
