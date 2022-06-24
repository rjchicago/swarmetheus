# bonus-example

Are you the type of person who never settles for just the basics?

Well, you're in the right place! `Swarmetheus` **bonus-example** has it all!

* cAdvisor
* Node Exporter
* Traefik
* Alertmanager
* Grafana
* \+ https & preconfigured alerts!

## deploy

``` sh
# clone this repo
git clone https://github.com/rjchicago/swarmetheus.git

# cd into bonus-example
cd swarmetheus/examples/bonus-example

# generate self-signed certs
sh ./certs/create-certs.sh

# stack deploy
docker stack deploy -c docker-compose.yml swarmetheus --prune
```

After a moment, you should have X services running:

``` sh
➜  ~ docker service ls
ID             NAME                       MODE         REPLICAS   IMAGE                          PORTS
pokkwiwaanrz   swarmetheus_alertmanager   replicated   1/1        prom/alertmanager:latest
pz6ndibec21z   swarmetheus_grafana        replicated   1/1        grafana/grafana:latest
mympzvrzmd6p   swarmetheus_prometheus     replicated   1/1        prom/prometheus:latest
nvf1t5z407lk   swarmetheus_swarmetheus    global       1/1        rjchicago/swarmetheus:latest
td3h2myc0zxh   swarmetheus_traefik        global       1/1        traefik:latest                 *:80->80/tcp, *:443->443/tcp, *:8080->8080/tcp, *:8084->8084/tcp
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

Your **bonus-example** suite is up and running:

* <http://traefik.localhost/>
* <http://grafana.localhost/>
* <http://prometheus.localhost/>
* <http://alertmanager.localhost>
* cAdvisor: <http://localhost:9091/>
* Node Exporter: <http://localhost:9092/>

## grafana

Open <http://grafana.localhost/> in your browser.

Credentials are preconfigured in [docker-compose.yml](./docker-compose.yml):

``` yml
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=password
```

Prometheus datasource is preconfigured:

``` yml
apiVersion: 1

datasources:
- name: Prometheus
  type: prometheus
  url: http://prometheus:9090 
  isDefault: true
  access: proxy
  editable: true
```

## cleanup

``` sh
# remove
docker container rm -f $(docker ps -f "name=^swarmetheus-.+$" --format "{{.ID}}")
docker stack rm swarmetheus

# rm volumes
docker volume rm $(docker volume ls -f "name=^swarmetheus_.+$" --format "{{.Name}}")
```

## https

> NOTE: https will not work with Chrome. For https try Firefox.

Examples:

* <https://traefik.localhost>
* <https://prometheus.localhost>
