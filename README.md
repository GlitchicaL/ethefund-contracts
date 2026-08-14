## Ethefund Contracts

Ethefund is a grant DAO on Ethereum focused on supporting various projects. The following repository is for the smart contracts.

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
