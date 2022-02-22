# swarmetheus demo

``` sh
# deploy
docker stack deploy -c docker-compose.yml swarmetheus --prune

# remove
docker container rm -f $(docker ps -f "name=^swarmetheus-.+$" --format "{{.ID}}")
docker stack rm swarmetheus

# rm volumes
docker volume rm $(docker volume ls -f "name=^swarmetheus_.+$" --format "{{.Name}}")
```
