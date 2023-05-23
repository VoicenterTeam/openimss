# OpenIMSs 
A community effort to bring up a comprehensive open source environment for real life development of IMS based 4G/5G/NR voice/video/data/RCS/IM services.

We started from https://github.com/herlesupreeth/docker_open5gs , and begin to generalize and expand from it

Status:
- Open5GS EPC 
- SRSRan 4G/LTE Radio Access 
- implementation of IMS CSCFs in OpenSIPS 
- qryn monitoring metrics telemethry 
- portainer 
- graphana
- coroot

## Tested Setup

Docker host machine

- Ubuntu 22.04

SDRs tested with srsLTE eNB

- Ettus USRP B210 or Chinese compatible 😉

## Build and Execution Instructions

* Mandatory requirements:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu)
	* [docker-compose](https://docs.docker.com/compose)




```
git clone https://github.com/VoicenterTeam/openimss.git
cd openimss/base
docker build --no-cache --force-rm -t docker_openimss_open5gs .

cd ../ims_base
docker build --no-cache --force-rm -t docker_openimss_opensips .

cd ../srslte
docker build --no-cache --force-rm -t docker_openimss_srslte .

cd ../ueransim
docker build --no-cache --force-rm -t docker_openimss_ueransim .
```

### Build and Run using docker-compose

```
cd ..
set -a
source .env
docker-compose build --no-cache
docker-compose up

# srsRAN eNB
docker-compose -f srsenb.yaml up -d && docker attach srsenb
# srsRAN gNB
docker-compose -f srsgnb.yaml up -d && docker attach srsgnb
# srsRAN ZMQ based setup
    # eNB
    docker-compose -f srsenb_zmq.yaml up -d && docker attach srsenb_zmq
    # gNB
    docker-compose -f srsgnb_zmq.yaml up -d && docker attach srsgnb_zmq
    # 4G UE
    docker-compose -f srsue_zmq.yaml up -d && docker attach srsue_zmq
    # 5G UE
    docker-compose -f srsue_5g_zmq.yaml up -d && docker attach srsue_5g_zmq

# UERANSIM gNB
docker-compose -f nr-gnb.yaml up -d && docker attach nr_gnb

# UERANSIM NR-UE
docker-compose -f nr-ue.yaml up -d && docker attach nr_ue
```

## Configuration

For the quick run (eNB/gNB, CN in same docker network), edit only the following parameters in .env as per your setup

```
MCC
MNC
TEST_NETWORK --> Change this only if it clashes with the internal network at your home/office
DOCKER_HOST_IP --> This is the IP address of the host running your docker setup
SGWU_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP set above only if eNB/gNB is not running the same docker network/host
UPF_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP set above only if eNB/gNB is not running the same docker network/host
```

If eNB/gNB is NOT running in the same docker network/host as the host running the dockerized Core/IMS then follow the below additional steps

Under mme section in docker compose file (docker-compose.yaml, nsa-deploy.yaml), uncomment the following part
```
...
    # ports:
    #   - "36412:36412/sctp"
...
```

Under amf section in docker compose file (docker-compose.yaml, nsa-deploy.yaml, sa-deploy.yaml), uncomment the following part
```
...
    # ports:
    #   - "38412:38412/sctp"
...
```

If deploying in SA mode only (sa-deploy.yaml), then uncomment the following part under upf section
```
...
    # ports:
    #   - "2152:2152/udp"
...
```

If deploying in NSA mode only (nsa-deploy.yaml, docker-compose.yaml), then uncomment the following part under sgwu section
```
...
    # ports:
    #   - "2152:2152/udp"
...
```

## Register a UE information

Open (http://<DOCKER_HOST_IP>:3000) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials
```
Username : admin
Password : 1423
```

Using Web UI, add a subscriber

## srsLTE eNB settings

If SGWU_ADVERTISE_IP is properly set to the host running the SGWU container in NSA deployment, then the following static route is not required.
On the eNB, make sure to have the static route to SGWU container (since internal IP of the SGWU container is advertised in S1AP messages and UE wont find the core in Uplink)

```
# NSA - 4G5G Hybrid deployment
ip r add <SGWU_CONTAINER_IP> via <SGWU_ADVERTISE_IP>
```

## Not supported
- IPv6 usage in Docker

## Ta-daaa
<pre>
~/openimss (master) # docker ps
CONTAINER ID   IMAGE                                      COMMAND                  CREATED         STATUS                   PORTS                                                                                                                          NAMES
215bb6200149   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             2123/udp, 3868/sctp, 3868/tcp, 3868/udp, 5868/tcp, 5868/sctp, 5868/udp, 36412/sctp, 9091/tcp                                   mme
a0cab0060ee9   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             2123/udp, 8805/udp                                                                                                             sgwc
8f057a5febe0   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             2152/udp, 8805/udp                                                                                                             sgwu
be53d5adaf23   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             2152/udp, 8805/udp, 9091/tcp                                                                                                   upf
6e4d93f13983   docker_openimss_opensips                   "/bin/bash -c ./star…"   5 minutes ago   Up 5 minutes             3871/tcp, 3871/udp, 5060/tcp, 5060/udp, 5100-5120/tcp, 5100-5120/udp, 6100-6120/tcp, 8080/tcp, 6100-6120/udp                   pcscf
9a644e5f2de0   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             2123/udp, 3868/sctp, 3868/tcp, 3868/udp, 5868/tcp, 5868/udp, 7777/tcp, 8805/udp, 5868/sctp, 9091/tcp                           smf
0ba9d91f46f1   docker_openimss_opensips                   "/bin/bash -c ./star…"   5 minutes ago   Up 5 minutes             3869/tcp, 3869/udp, 4060/tcp, 8080/tcp, 4060/udp                                                                               icscf
81763a3141e6   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp, 9091/tcp, 38412/sctp                                                                                                 amf
593a93826ee0   timberio/vector:latest-alpine              "/usr/local/bin/vect…"   5 minutes ago   Up 5 minutes                                                                                                                                            vector_logs
db47f463c3f3   sipcapture/heplify-server                  "./heplify-server"       5 minutes ago   Up 5 minutes             9090/tcp, 0.0.0.0:9060-9061->9060-9061/tcp, 0.0.0.0:9060->9060/udp, :::9060-9061->9060-9061/tcp, :::9060->9060/udp, 9096/tcp   heplify-server
effabab912d1   timberio/vector:latest-alpine              "/usr/local/bin/vect…"   5 minutes ago   Up 5 minutes                                                                                                                                            vector
3ea4c8cd33a4   docker_openimss_fhoss                      "/bin/sh -c /mnt/fho…"   5 minutes ago   Up 5 minutes             3868/tcp, 3868/udp, 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                                                                  fhoss
b63d0d547968   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp                                                                                                                       bsf
ec3749c08add   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp, 9091/tcp                                                                                                             pcf
645c01d56b32   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp                                                                                                                       ausf
e588b76710f2   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp                                                                                                                       udm
65923334962a   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp                                                                                                                       nssf
aef322972ad7   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp                                                                                                                       udr
4cb9027cbab7   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             3868/sctp, 3868/tcp, 3868/udp, 5868/sctp, 5868/tcp, 5868/udp                                                                   hss
39004a28aa34   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             3868/sctp, 3868/tcp, 3868/udp, 5868/sctp, 5868/tcp, 5868/udp                                                                   pcrf
8d84f59f20a0   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             0.0.0.0:3000->3000/tcp, :::3000->3000/tcp                                                                                      webui
17e909a22b89   timberio/vector:latest-alpine              "/usr/local/bin/vect…"   5 minutes ago   Up 5 minutes                                                                                                                                            vector-coroot
d4ec0c185e29   docker_openimss_osmomsc                    "/bin/sh -c '/mnt/os…"   5 minutes ago   Up 5 minutes             2775/tcp, 29118/sctp                                                                                                           osmomsc
458a787106cf   grafana/grafana-oss:latest                 "/run.sh"                5 minutes ago   Up 5 minutes             0.0.0.0:9080->3000/tcp, :::9080->3000/tcp                                                                                      grafana
eab34b76e65b   qxip/qryn:latest                           "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes             0.0.0.0:3100->3100/tcp, :::3100->3100/tcp                                                                                      qryn
1e0b3bddba04   docker_openimss_mongo                      "/bin/sh -c /mnt/mon…"   5 minutes ago   Up 5 minutes             27017/tcp, 27017/udp                                                                                                           mongo
77003e897f85   ghcr.io/coroot/coroot                      "/opt/coroot/coroot"     5 minutes ago   Up 5 minutes             0.0.0.0:8013->8080/tcp, :::8013->8080/tcp                                                                                      coroot
985d0b119222   docker_openimss_mysql                      "/bin/sh -c /mysql_i…"   5 minutes ago   Up 5 minutes             3306/tcp                                                                                                                       mysql
f7d4e0e4a968   clickhouse/clickhouse-server:22.8-alpine   "/entrypoint.sh"         5 minutes ago   Up 5 minutes (healthy)   9000/tcp, 0.0.0.0:8123->8123/tcp, :::8123->8123/tcp, 9009/tcp                                                                  clickhouse-serv
er
2133a1f57a52   ghcr.io/coroot/coroot-node-agent           "coroot-node-agent -…"   5 minutes ago   Up 5 minutes             80/tcp                                                                                                                         exporter
49ea9dd767fa   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp                                                                                                                       scp
c260a4a8a053   portainer/portainer-ce:latest              "/portainer"             5 minutes ago   Up 5 minutes             0.0.0.0:8000->8000/tcp, :::8000->8000/tcp, 0.0.0.0:9443->9443/tcp, :::9443->9443/tcp, 9000/tcp                                 portainer
5868a53cc66e   docker_openimss_osmohlr                    "/bin/sh -c '/mnt/os…"   5 minutes ago   Up 5 minutes             4222/tcp                                                                                                                       osmohlr
48efb254ba8e   docker_openimss_dns                        "/bin/sh -c '/mnt/dn…"   5 minutes ago   Up 5 minutes             53/udp                                                                                                                         dns
c7665137d42c   docker_openimss_rtpengine                  "/bin/sh -c /mnt/rtp…"   5 minutes ago   Up 5 minutes             2223/udp, 49000-50000/udp                                                                                                      rtpengine
09bd99f2a02b   docker_openimss_open5gs                    "/bin/sh -c /open5gs…"   5 minutes ago   Up 5 minutes             7777/tcp                                                                                                                       nrf
5e0a05b79569   docker_openimss_metrics                    "/bin/sh -c /mnt/met…"   5 minutes ago   Up 5 minutes             0.0.0.0:9090->9090/tcp, :::9090->9090/tcp                                                                                      metrics



~/openimss (master) # docker-compose -f srsenb.yaml up -d && docker attach srsenb
WARNING: Found orphan containers (scscf, clickhouse-server, mysql, portainer, fhoss, hss, sgwc, rtpengine, dns, icscf, bsf, qryn, exporter, nssf, coroot, osmomsc, udm, osmohlr, smf, pcscf, mme, sgwu, heplify-server, ausf, pcrf, webui, vector-coroot, mongo, vector, v
ector_logs, scp, upf, nrf, amf, grafana, metrics, pcf, udr) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
Starting srsenb ... done

Built in Release mode using commit 10f81ca03 on branch lc/main.

Opening 1 channels in RF device=default with args=default
Supported RF device list: UHD soapy zmq lime file
Trying to open RF device 'UHD'
[INFO] [UHD] linux; GNU C++ version 9.4.0; Boost_107100; UHD_4.4.0.0-0ubuntu1~focal1
[INFO] [LOGGING] Fastpath logging disabled at runtime.
[INFO] [B200] Loading firmware image: /usr/share/uhd/images/usrp_b200_fw.hex...
Opening USRP channels=1, args: type=b200,master_clock_rate=23.04e6
[INFO] [UHD RF] RF UHD Generic instance constructed
[INFO] [B200] Detected Device: B210
[INFO] [B200] Loading FPGA image: /usr/share/uhd/images/usrp_b210_fpga.bin...
[INFO] [B200] Operating over USB 3.
[INFO] [B200] Detecting internal GPSDO.... 
[INFO] [GPS] No GPSDO found
[INFO] [B200] Initialize CODEC control...
[INFO] [B200] Initialize Radio control...
[INFO] [B200] Performing register loopback test... 
[INFO] [B200] Register loopback test passed
[INFO] [B200] Performing register loopback test... 
[INFO] [B200] Register loopback test passed
[INFO] [B200] Asking for clock rate 23.040000 MHz... 
[INFO] [B200] Actually got clock rate 23.040000 MHz.
RF device 'UHD' successfully opened

==== eNodeB started ===
Type <t> to view trace
Setting frequency: DL=2660.0 Mhz, UL=2540.0 MHz for cc_idx=0 nof_prb=50
[INFO] [UHD RF] Tx while waiting for EOB, timed out... 14.8769 >= 0. Starting new burst...

</pre>
