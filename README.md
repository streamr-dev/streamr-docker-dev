<p align="center">
  <a href="https://streamr.network">
    <img alt="Streamr" src="https://raw.githubusercontent.com/streamr-dev/streamr-docker-dev/master/readme-docker-header.png" width="1320" />
  </a>
</p>
<h1 align="left">

# Streamr development environment

This repository contains Docker compose files and command line tool `streamr_docker_dev` for setting up a local Streamr development environment. The environment consists of Streamr services and supporting (3rd party) services. The data of the services is persisted on the local disk.

## Setting up

### OS X

1. Download, install, and run [Docker Community Edition for Mac](https://store.docker.com/editions/community/docker-ce-desktop-mac).

2. Increase the amount of memory allocated to Docker VM from 2GB to something
   like 5GB or more (Docker icon -> Preferences -> Advanced). Click Apply & Restart.

3. Clone this repo: `git clone git@github.com:streamr-dev/streamr-docker-dev.git`, change into that directory `cd streamr-docker-dev`

4. Create a symlink to `streamr-docker-dev` into a suitable directory in your PATH (run from repository root):
```
ln -sf $(pwd)/streamr-docker-dev/bin.sh /usr/local/bin/streamr-docker-dev
```

### Linux

1. Install and start Docker service.

2. Clone this repo: `git clone git@github.com:streamr-dev/streamr-docker-dev.git`, change into that directory `cd streamr-docker-dev`

3. Add `streamr-docker-dev` into a suitable directory in your PATH (run from repository root), e.g.:
```
ln -sf $(pwd)/streamr-docker-dev/bin.sh /usr/local/bin/streamr-docker-dev
```

### Windows

The docker stack has not been tested in a Windows environment and is not recommended at this time.

If you know what services you need, you don't need to use the `bin.sh`, you can just use `docker-compose` directly, like so:

1. Install and start Docker service.

2. Clone this repo: `git clone git@github.com:streamr-dev/streamr-docker-dev.git`, change into that directory `cd streamr-docker-dev`

3. Bind the loopback interface to 10.200.10.1: `netsh int ip add address "Loopback" 10.200.10.1`

4. For instance, for the Ethereum environment without core-api: `docker-compose up parity-node0 parity-sidechain-node0 bridge`

## Quickstart

**Option 1**

`streamr-docker-dev start --wait `

### Interacting with the local blockchain

The local Streamr Stack is configured to interact with the local Ethereum Parity node. Transactions should be near instant.

The recommended way to interact with the blockchain is through Metamask. Here is the network configuration to add:
- Network Name: Streamr Local
- RPC URL: http://localhost:8545 (mainchain) or http://localhost:8546 (sidechain)
- ChainID: 8995 (mainchain) or 8997 (sidechain)

If you use `StreamrClient`, please configure MetaMask with the sidechain values.

### Getting ETH on the local blockchain

There are pre-filled wallets with ETH & DATA on this chain to use.

#### Available Accounts

- (0) 0xa3d1F77ACfF0060F7213D7BF3c7fEC78df847De1 (100 ETH)
- (1) 0x4178baBE9E5148c6D5fd431cD72884B07Ad855a0 (100 ETH)
- (2) 0xdC353aA3d81fC3d67Eb49F443df258029B01D8aB (100 ETH)
- (3) 0x7986b71C27B6eAAB3120a984F26511B2dcfe3Fb4 (100 ETH)
- (4) 0xa6743286b55F36AFA5F4e7e35B6a80039C452dBD (100 ETH)
- (5) 0x7B556228B0D887CfC8d895cCe27CbC79d3e55b3C (100 ETH)
- (6) 0x795063367EbFEB994445d810b94461274E4f109A (100 ETH)
- (7) 0xcA9b39e7A7063cDb845483426D4f12F1f4A44A19 (100 ETH)
- (8) 0x505D48552Ac17FfD0845FFA3783C2799fd4aaD78 (100 ETH)
- (9) 0x65416CBeF822290d9A2FC319Eb6c7f6D9Cd4a541 (100 ETH)

#### Private Keys

- (0) 0x5e98cce00cff5dea6b454889f359a4ec06b9fa6b88e9d69b86de8e1c81887da0
- (1) 0xe5af7834455b7239881b85be89d905d6881dcb4751063897f12be1b0dd546bdb
- (2) 0x4059de411f15511a85ce332e7a428f36492ab4e87c7830099dadbf130f1896ae
- (3) 0x633a182fb8975f22aaad41e9008cb49a432e9fdfef37f151e9e7c54e96258ef9
- (4) 0x957a8212980a9a39bf7c03dcbeea3c722d66f2b359c669feceb0e3ba8209a297
- (5) 0xfe1d528b7e204a5bdfb7668a1ed3adfee45b4b96960a175c9ef0ad16dd58d728
- (6) 0xd7609ae3a29375768fac8bc0f8c2f6ac81c5f2ffca2b981e6cf15460f01efe14
- (7) 0xb1abdb742d3924a45b0a54f780f0f21b9d9283b231a0a0b35ce5e455fa5375e7
- (8) 0x2cd9855d17e01ce041953829398af7e48b24ece04ff9d0e183414de54dc52285
- (9) 0x2c326a4c139eced39709b235fffa1fde7c252f3f7b505103f7b251586c35d543


#### Local DATA token contract address
0xbAA81A0179015bE47Ad439566374F2Bae098686F

### Troubleshooting

Metamask can often get stuck when transacting on many different networks. A handy trick is to "Reset Account" in Settings/Advanced. This will remove the transaction history which helps it get unstuck.

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

"Factory reset" the docker environment by removing all images and persisted data: `streamr-docker-dev factory-reset`.
**Warning: this will delete all your docker images and their state, not just ones related to the Streamr stack.**

## Accessing the Core app and Streamr API

Once the services are running, browse to [http://localhost](http://localhost) to use Core.

The API root is at `http://localhost/api/v2`.

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
- 3 x [Broker](https://github.com/streamr-dev/broker) nodes
  - 2 broker nodes + 1 storage Streamr network nodes. This creates a local and private Streamr Network.
- 3 x [Tracker](https://github.com/streamr-dev/broker)
  - Helps node discovery in the Strearm Network
- 1 x [Hub frontend](https://github.com/streamr-dev/streamr-platform/app)
  - See more detailed build instructions in the streamr-platform repo
- 1 x [TheGraph node](https://github.com/streamr-dev/network-contracts)
  - GraphQL queries at http://localhost:8000/subgraphs/name/githubname/subgraphname
  - GUI to past GraphQL queries: http://192.168.0.8:8000/subgraphs/name/githubname/subgraphname/graphql
  - An example query is:
```
{
   streams {
    id,
    metadata,
    permissions {
      id,
  		user,
  		edit,
      canDelete,
      publish,
      subscribed,
      share,
    }
  }
}
```
### Supporting services
- 1 x MySQL instance
- 1 x Apache Cassandra instance with `streamr_dev` keyspace
- 1 x [Ethereum Parity node ("mainchain")](https://github.com/streamr-dev/open-ethereum-poa)
- 1 x [Ethereum Parity node ("sidechain")](https://github.com/streamr-dev/open-ethereum-poa)
- 1 x nginx
- 1 x Postgres DB for TheGraph
- 1 x ipfs for TheGraph
- 1 x adapter for ENS queries from sidechain to mainchain

## Troubleshooting

### Metamask transactions are stuck

This is a common problem on Metamask when switching inbetween chains. Clearing the transaction history in Metamask usually fixes this issue:
Click, 'Settings', then 'Advanced', then, 'Reset Account'.

### Making image uploads to AWS work

Uploading images to AWS needs credentials to be able to access the target S3 bucket.

1. copy `.env.example` as `.env` and change the values to correct ones
(Note: `.env` file is in `.gitignore`)

2. Restart `engine-and-editor` and S3 services should work. You can debug any
   potential issues with `streamr-docker-dev log -f engine-and-editor`.

### Error response from daemon
`Get https://registry-1.docker.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)`

This is a connection issue; could be DNS settings, could be firewall. For me, changing to another wlan helped.

I received this error only during `docker login`, after login I could resume using office wlan (`docker pull` works somehow differently).

## Directory structure

| File                        | Description                                                    |
|:-----------------------------|:----------------------------------------------------------------|
| docker-compose.yml          | Supporting services stack (MySQL, Cassandra, Redis, etc.)      |
| docker-compose.override.yml | Streamr service stack                                          |
| custom-mysql-settings.cnf   | Custom MySQL settings                                          |
| mysql\_init\_scripts        | Database dumps used to initalize MySQL databases               |
| keyspace.cql                | Keyspace definitions and demo data for Cassandra               |
| data                        | Persistance of container data                                  |

## License

This software is open source and licensed under [GPLv3](https://www.gnu.org/licenses/gpl.html).

