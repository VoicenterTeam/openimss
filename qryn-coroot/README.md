<a href="https://qryn.dev" target="_blank"><img src='https://user-images.githubusercontent.com/1423657/218816262-e0e8d7ad-44d0-4a7d-9497-0d383ed78b83.png' width=250></a>

# qryn + coroot
[Blog Tutorial](https://blog.qryn.dev/coroot-qryn-turn-telemetry-into-answers): [qryn](https://qryn.dev) + [coroot](https://coroot.com/docs/coroot-community-edition) 


Coroot is a _qryn compatible_ open-source monitoring and troubleshooting tool for microservice architectures.

In this tutorial we'll use Coroot and [Coroot Node-agent](https://coroot.com/docs/metric-exporters/node-agent) to collect system and application metrics using eBPF.

<img src="https://user-images.githubusercontent.com/1423657/205445466-67a81963-e593-47c3-ad73-8365e68d9e4f.png" width=800px />


## Requirements
- [qryn](https://qryn.dev) or [qryn.cloud](https://qryn.cloud)
- [grafana](https://grafana.com)
- Docker, docker-compose

## Usage
The provided `docker-compose` will spin up coroot, coroot-agent and vector scraper pointed at your qryn instance
```
export QRYN_URL=http://qryn:3100/prom/remote/write
docker-compose up -d
```

### Coroot UI
#### Configuration
On your first usage, create a new project and point it at your **qryn** API endpoint _(prometheus protocol)_

<img src="https://user-images.githubusercontent.com/1423657/205444113-b52ddc6c-c8a1-4e38-b6ed-2e8cc26bd5ed.png" width=600px />

#### Usage
Once metrics are collected, they will automatically display in the coroot user interface. Happy times!

<!-- 
![image](https://user-images.githubusercontent.com/1423657/205444050-21fb7a10-d0d0-4cf1-85fb-98ba3141ec71.png) 
<img src="https://user-images.githubusercontent.com/1423657/205444493-4b3ec904-ff72-424a-b272-9a9e2503594a.gif" width=600px />
-->

<img src="https://user-images.githubusercontent.com/194465/195115881-babd5bd0-8c2b-4718-9cc6-e6dfb5a20c00.gif" width=800px />
