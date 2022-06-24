# traefik example

``` sh
# generate self-signed certs
sh ./certs/create-certs.sh

# stack deploy
docker stack deploy -c docker-compose.yml swarmetheus --prune

# remove
docker container rm -f $(docker ps -f "name=^swarmetheus-.+$" --format "{{.ID}}")
docker stack rm swarmetheus

# rm volumes
docker volume rm $(docker volume ls -f "name=^swarmetheus_.+$" --format "{{.Name}}")
```

> NOTE: <https://traefik.localhost> & <https://prometheus.localhost> will not work with Chrome. For this try in Firefox.
