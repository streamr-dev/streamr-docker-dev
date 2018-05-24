# Streamr cloud development environment

This repository contains Docker compose files and command line tool `streamr_docker_dev` for setting up a local Streamr cloud development environment. The cloud environment consists of base services (3rd party) and Streamr services (in-house).

![Streamr cloud architecture](high-level.png)

### Base services
- 1 x MySQL instance with databases `core_dev` and `core_test`
- 1 x Apache Zookeeper instance
- 1 x Apache Kafka instance
- 1 x Redis instance
- 1 x Apache Cassandra instance with `streamr_dev` keyspace
- 1 x SMTP server

### Streamr services
- 1 x [Cloud Broker](https://github.com/streamr-dev/cloud-broker) instance
- 1 x [Data API](https://github.com/streamr-dev/data-api) instance
- 1 x [Engine and Editor](https://github.com/streamr-dev/engine-and-editor) instance

Data of MySQL and Cassandra are persisted on host machine disk.

## Setting up

### OS X

1. Download, install, and run [Docker Community Edition for Mac](https://store.docker.com/editions/community/docker-ce-desktop-mac).

2. Increase the amount of memory allocated to Docker VM from 2GB to something
   like 5GB or more (Docker icon -> Preferences -> Advanced). Click Apply & Restart.

3. Create a symlink to `streamr-docker-dev` into a suitable directory in your PATH (run from repository root):
```
ln -sf $(pwd)/streamr-docker-dev/bin.sh /usr/local/bin/streamr-docker-dev
```

4.  Attach (unused) IP address 10.200.10.1 to loopback network interface `lo0`
[details](https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds):
```
streamr-docker-dev bind-ip
```

### Linux

1. Install and start Docker service.

2. Add `streamr-docker-dev` into a suitable directory in your PATH (run from repository root), e.g.:
```
ln -sf $(pwd)/streamr-docker-dev/bin.sh /usr/local/bin/streamr-docker-dev
```

4.  Attach (unused) IP address 10.200.10.1 to loopback network interface (usually named `lo`)
[details](https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds):
```
ip addr add 10.200.10.1 dev lo label lo:1
```

### Setting up image upload through AWS (Optional)

You need to follow these steps if you want AWS S3 dependent features (i.e.
image upload) to be available through engine-and-editor.

1. copy `.env.example` as `.env` and change the values to correct ones
(Note: `.env` file is in `.gitignore`)

2. Restart engine-and-editor and S3 services should work. You can debug any
   potential issues with `streamr-docker-dev log -f engine-and-editor`.

## Running

You will want to run subsets of the Streamr cloud environment depending on what
service(s) of Streamr you are developing. For example, when developing
engine-and-editor, you want to run all base services along with Broker and
Data-API (alias 1).

| Description                                      | When developing           | Alias  | Command                                       |
|--------------------------------------------------|---------------------------|--------|-----------------------------------------------|
| Create and run entire service stack                      | nothing                   | 5      | `streamr-docker-dev start --all`              |
| Create and Run base services        | all 3 services / broker   | 4      | `streamr-docker-dev start 4`                  |
| Create and run Broker + base services            | data-api (+ engine-and-editor) | 3      | `streamr-docker-dev start 3`                  |
| Create and run Data-API + base services          | broker + engine-and-editor     | 2      | `streamr-docker-dev start 2`                  |
| Create and run Broker + Data-API + base services | engine-and-editor              | 1      | `streamr-docker-dev start 1`                  |

### Useful Commands

To view process list
`streamr-docker-dev ps [services]`

To view all logs
`streamr-docker-dev log [services]`

To view logs of certain service
`docker-compose logs -tf mysql`

To start Docker services
`streamr-docker-dev start [<services> | --all]`

To stop Docker services
`streamr-docker-dev stop [<services> | --all]`

To SSH into a service
`docker exec -i -t <CONTAINER_ID> /bin/sh`

To show docker disk usage statistics
`docker system df -v`

To prune all unused data
`docker system prune`

### NGINX reverse proxy

When running engine-and-editor during Marketplace development, an nginx reverse proxy is available to map marketplace (default :3333) and engine-and-editor (default :8081) to localhost:80: `streamr-docker-dev start nginx`


## Accounts

| Service           | Username                 | Password                 | Misc                                                       |
|-------------------|--------------------------|--------------------------|------------------------------------------------------------|
| MySQL             | root                     | password                 | `mysql -h127.0.0.1 -uroot -ppassword core_dev`             |
| engine-and-editor | tester1@streamr.com      | tester1TESTER1           | API key:  tester1-api-key                                  |
| engine-and-editor | tester2@streamr.com      | tester2                  | API key:  tester2-api-key                                  |
| engine-and-editor | tester-admin@streamr.com | tester-adminTESTER-ADMIN | API key:  tester-admin-api-key                             |

## FAQ

### How to do a "factory reset" of the development environment?

To kill all services, remove them, remove their persisted data, and re-build and start the services use:
```
streamr-docker-dev restart -r -k [<services> | --all]
```

### How to use streamr-docker-dev?
Run either
```
streamr-docker-dev help
```
or
```
streamr-docker-dev <command> --help
```

## Troubleshooting

#### Error response from daemon: Get https://registry-1.docker.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)

This is a connection issue; could be DNS settings, could be firewall. For me, changing to another wlan helped.

I received this error only during `docker login`, after login I could resume using office wlan (`docker pull` works somehow differently).

## Directory structure

| File                        | Description                                                    |
|-----------------------------|----------------------------------------------------------------|
| docker-compose.yml          | Base service stack (MySQL, Cassandra, Zookeeper, Kafka, Redis) |
| docker-compose.override.yml | Streamr service stack (Broker, Data-API, and Streamr)          |
| custom-mysql-settings.cnf   | Custom MySQL settings                                          |
| mysql\_init\_scripts        | Database dumps used to initalize MySQL databases               |
| keyspace.cql                | Keyspace definitions and demo data for Cassandra               |
| data                        | Persistance of container data                                  |

## License

This software is open source and licensed under [GPLv3](https://www.gnu.org/licenses/gpl.html).

