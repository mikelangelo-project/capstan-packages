# Push container to DockerHub
Query short git hash of the OSv used before pushing container image to DockerHub since
it's the most important part of image tag:
```bash
$ docker exec -it bf0c93dbdb84 /bin/bash -c "git rev-parse --short HEAD"
c601abb
```
Then you are able to push the image to the DockerHub:
```bash
# query image id
$ docker images | grep mikelangelo/capstan-packages
mikelangelo/capstan-packages    latest     5f7edecb9614     About an hour ago   3.87GB
                                          |---- ID ----|

# tag image
$ docker tag 5f7edecb9614 mikelangelo/capstan-packages:2017-07-12_c601abb

# login to dockerhub and push the tagged image
$ docker login
$ docker push mikelangelo/capstan-packages:2017-07-12_c601abb
```
