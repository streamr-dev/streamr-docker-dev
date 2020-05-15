# Streamr development environment

This repository contains Docker compose files and command line tool `streamr_docker_dev` for setting up a local Streamr development environment. The environment consists of Streamr services and supporting (3rd party) services. The data of the services is persisted on the local disk.

## Setting up

### OS X

1. Download, install, and run [Docker Community Edition for Mac](https://store.docker.com/editions/community/docker-ce-desktop-mac).

2. Increase the amount of memory allocated to Docker VM from 2GB to something
   like 5GB or more (Docker icon -> Preferences -> Advanced). Click Apply & Restart.

3. Create a symlink to `streamr-docker-dev` into a suitable directory in your PATH (run from repository root):
```
ln -sf $(pwd)/streamr-docker-dev/bin.sh /usr/local/bin/streamr-docker-dev
```

### Linux

1. Install and start Docker service.

2. Add `streamr-docker-dev` into a suitable directory in your PATH (run from repository root), e.g.:
```
ln -sf $(pwd)/streamr-docker-dev/bin.sh /usr/local/bin/streamr-docker-dev
```

3.  Attach (unused) IP address 10.200.10.1 to loopback network interface (usually named `lo`)
[details](https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds):
```
ip addr add 10.200.10.1 dev lo label lo:1
```

## Quickstart

- Start the full stack and wait until it's up and running: `streamr-docker-dev start --wait `
- Browse to [http://localhost](http://localhost) to use the Core UI
- Log in as `tester1@streamr.com` with password `tester1TESTER1`

## Commands

### `help`

List available commands: `streamr-docker-dev`

Help about particular command: `streamr-docker-dev help [command]`

### `start`

Start all services: `streamr-docker-dev start`

Start particular services: `streamr-docker-dev start [services]`

Start all services except particular ones: `streamr-docker-dev start --except [service]`

Start and wait for services to become healthy: `streamr-docker-dev start --wait`

### `stop`

Stop all services: `streamr-docker-dev stop`

Stop particular services: `streamr-docker-dev stop [services]`

### `restart`

Restart all services: `streamr-docker-dev restart`

Restart particular services: `streamr-docker-dev restart [services]`

### `wait`

Wait up to 5 min for pending health checks to pass: `streamr-docker-dev wait --timeout 300`

### `ps`

View process list: `streamr-docker-dev ps [services]`

### `log`

View all logs: `streamr-docker-dev log [-f]`

View logs of certain services: `streamr-docker-dev log [-f] [services]`

### `shell`

Open an interactive shell into a container: `streamr-docker-dev shell [service]`

### `pull`

Pull latest images of all services: `streamr-docker-dev pull`

Pull latest images of certain services: `streamr-docker-dev pull [services]`

### `update`

Update the tool to the latest version: `streamr-docker-dev update`

### `wipe`

Wipe the persisted data of all services: `streamr-docker-dev wipe`

### `factory-reset`

"Factory reset" the environment by removing all images and persisted data: `streamr-docker-dev factory-reset` 

## Accessing the Core app and Streamr API

Once the services are running, browse to [http://localhost](http://localhost) to use Core.

The API root is at `http://localhost/api/v1`.

### Accounts

The environment ships with some predefined user accounts.

| Username                 | Password                 | Misc                                                       |
|--------------------------|--------------------------|------------------------------------------------------------|
| tester1@streamr.com      | tester1TESTER1           | API key:  tester1-api-key                                  |
| tester2@streamr.com      | tester2                  | API key:  tester2-api-key                                  |
| tester-admin@streamr.com | tester-adminTESTER-ADMIN | API key:  tester-admin-api-key                             |

The MySQL credentials are `root` / `password`.

## Usage in Streamr development

When you're developing one of the Streamr components, you'll want to use the `streamr-docker-dev` tool with the `--except` flag to exclude the service you're developing:

```
streamr-docker-dev start --except [service-under-development]
```

## Usage in testing and CI

In CI, the `--wait` flag can be used with `start` to block until all health checks are passing. This ensures that the services are up and running before starting your tests.

For integration tests, use the `--except` option to exclude the service under test: 

```
streamr-docker-dev start --except [service-under-test] --wait
```

When testing the SDKs or running other end-to-end tests, just start the full stack before your tests: 

```
streamr-docker-dev start --wait
```

## Included services

### Streamr services
- 3 x [Broker](https://github.com/streamr-dev/broker) nodes (2 normal ones + 1 storage node)
- 1 x [Tracker](https://github.com/streamr-dev/network)
- 1 x [Core frontend](https://github.com/streamr-dev/streamr-platform/app)
- 1 x [Core backend](https://github.com/streamr-dev/engine-and-editor)
- 1 x [Data Union Server](https://github.com/streamr-dev/streamr-community-products)
- 1 x [ethereum-watcher](https://github.com/streamr-dev/streamr-ethereum-watcher)

### Supporting services
- 1 x MySQL instance with databases `core_dev` and `core_test`
- 1 x Redis instance
- 1 x Apache Cassandra instance with `streamr_dev` keyspace
- 1 x SMTP server
- 1 x ganache
- 1 x nginx

## Troubleshooting

### Making image uploads to AWS work

Uploading images to AWS needs credentials to be able to access the target S3 bucket.

1. copy `.env.example` as `.env` and change the values to correct ones
(Note: `.env` file is in `.gitignore`)

2. Restart `engine-and-editor` and S3 services should work. You can debug any
   potential issues with `streamr-docker-dev log -f engine-and-editor`.

### Error response from daemon: Get https://registry-1.docker.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)

This is a connection issue; could be DNS settings, could be firewall. For me, changing to another wlan helped.

I received this error only during `docker login`, after login I could resume using office wlan (`docker pull` works somehow differently).

## Directory structure

| File                        | Description                                                    |
|-----------------------------|----------------------------------------------------------------|
| docker-compose.yml          | Supporting services stack (MySQL, Cassandra, Redis, etc.)      |
| docker-compose.override.yml | Streamr service stack                                          |
| custom-mysql-settings.cnf   | Custom MySQL settings                                          |
| mysql\_init\_scripts        | Database dumps used to initalize MySQL databases               |
| keyspace.cql                | Keyspace definitions and demo data for Cassandra               |
| data                        | Persistance of container data                                  |

## License

This software is open source and licensed under [GPLv3](https://www.gnu.org/licenses/gpl.html).

