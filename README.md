# AVNU contract lib

This repository is a collection of Cairo components and functions that are used by AVNU contracts.

The repository includes the following components:
- [Ownable](src/components/ownable.cairo): a component that allows to manage ownership of a contract
- [Upgradable](src/components/upgradable.cairo): a component that allows upgrade the contract code
- [Whitelist](src/components/whitelist.cairo): a component that allows to manage a whitelist of addresses

It includes the following interfaces:
- [erc20](src/interfaces/erc20.cairo): an interface that allows to interact with ERC20 tokens

And finally, it includes the following functions:
- [muldiv](src/math/muldiv.cairo): a function that allows to multiply two numbers and divide the result by a third number

## Getting started

This repository is using [Scarb](https://docs.swmansion.com/scarb/) to install, test, build contracts

```shell
# Format
scarb fmt

# Run the tests
scarb test

# Build contracts
scarb build
```
