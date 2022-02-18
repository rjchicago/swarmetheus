# swarmetheus

``` sh
# stack deploy
docker stack deploy -c docker-compose.yml swarmetheus --prune

# remove
docker container rm -f $(docker ps -f "name=^swarmetheus-.+$" --format "{{.ID}}")
docker stack rm swarmetheus

# rm volumes
docker volume rm $(docker volume ls -f "name=^swarmetheus_.+$" --format "{{.Name}}")
```

## Node CPU

``` sh
100 - 100 * avg by(instance, env) (irate(node_cpu_seconds_total{mode="idle"}[5m]))
```

## Node Memory

``` sh
100 * (1 - ((node_memory_MemFree_bytes + node_memory_Cached_bytes + node_memory_Buffers_bytes) / node_memory_MemTotal_bytes))
```

## Container CPU

``` sh
rate(container_cpu_usage_seconds_total{image=~".+"}[5m])*100
```

## Container Memory

``` sh
container_memory_rss{image=~".+"}
```
