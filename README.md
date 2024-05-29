## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Start Anvil

```shell
$ anvil
```

### Deploy Locally

```shell
forge script script/EtheREP.s.sol:EtheREPDeploy --fork-url http://localhost:8545 --broadcast
```

```shell
forge script script/EtheTimelock.s.sol:EtheTimelockDeploy --fork-url http://localhost:8545 --broadcast
```

```shell
forge script script/EtheGovernor.s.sol:EtheGovernorDeploy --fork-url http://localhost:8545 --broadcast
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
