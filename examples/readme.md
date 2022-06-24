# swarmetheus demo

As a reminder, use the following to clean up after all swarmetheus data and services:

## cleanup

``` sh
# remove
docker container rm -f $(docker ps -f "name=^swarmetheus-.+$" --format "{{.ID}}")
docker stack rm swarmetheus

# rm volumes
docker volume rm $(docker volume ls -f "name=^swarmetheus_.+$" --format "{{.Name}}")
```
