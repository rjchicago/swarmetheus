# basic-example

With `Swarmetheus` **basic-example** you get:

* Prometheus
* cAdvisor
* Node Exporter
* \+ preconfigured alerts!

## deploy

``` sh
# copy the basic-example docker-compose.yml locally
wget https://raw.githubusercontent.com/rjchicago/swarmetheus/master/examples/basic-example/docker-compose.yml

# stack deploy
docker stack deploy -c docker-compose.yml swarmetheus --prune
```

After a moment, you should have two `swarmetheus` services running:

``` sh
➜  swarmetheus docker service ls
ID             NAME                      MODE         REPLICAS   IMAGE                          PORTS
ob9flfd6hs3v   swarmetheus_prometheus    replicated   1/1        prom/prometheus:latest         *:9090->9090/tcp
eiaoee7qnw8v   swarmetheus_swarmetheus   global       1/1        rjchicago/swarmetheus:latest
```

After another moment, you will have several additional side containers running:

``` sh
➜  ~ docker ps -f "name=^swarmetheus-.+$" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
CONTAINER ID   IMAGE                              STATUS                   PORTS                    NAMES
4ca200e0165f   prom/node-exporter:v1.3.1          Up 1 minutes             0.0.0.0:9092->9100/tcp   swarmetheus-node-exporter
b7d48af0f418   gcr.io/cadvisor/cadvisor:v0.43.0   Up 1 minutes (healthy)   0.0.0.0:9091->8080/tcp   swarmetheus-cadvisor
63ca59739edb   rjchicago/swarmetheus:latest       Up 1 minutes                                      swarmetheus-health
```

## open

Your basic `swarmetheus` suite is up and running:

* Prometheus: <http://localhost:9090/>
* cAdvisor: <http://localhost:9091/>
* Node Exporter: <http://localhost:9092/>

## alerts

Many basic alerts are preconfigured:

<http://localhost:9090/alerts>

![swarmetheus-alerts](./assets/swarmetheus-alerts.png)

## cleanup

Since `swarmetheus` runs additional containers, it is cleaner to remove those first, then the stack, and finally the volumes:

``` sh
# remove containers
docker container rm -f $(docker ps -f "name=^swarmetheus-.+$" --format "{{.ID}}")

# remove stack
docker stack rm swarmetheus

# remove volumes
docker volume rm $(docker volume ls -f "name=^swarmetheus_.+$" --format "{{.Name}}")
```
