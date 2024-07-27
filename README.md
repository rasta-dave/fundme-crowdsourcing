# FundMe - A Crowd-Sourcing Smart Contract

FundMe is a decentralized crowd-sourcing application built on Ethereum using Solidity. This smart contract allows users to contribute funds, which only the contract owner can withdraw. The contract also uses Chainlink's Price Feed to set a minimum funding amount in USD.

## Features

- **Secure Funding**: Only the owner of the contract can withdraw the funds.
- **Minimum Contribution**: Enforces a minimum contribution amount in USD using Chainlink's Price Feed.
- **Gas Optimization**: Includes a gas-optimized withdraw function.

## Prerequisites

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Foundry](https://getfoundry.sh/)


## Quickstart

```
git clone https://github.com/rasta-dave/FundMe-Crowdsourcing
cd FundMe-Crowdsourcing
make
```


## Usage

### Fund the Contract

Users can fund the contract by sending ETH directly to it or by calling the `fund` function.

### Withdraw Funds

Only the owner of the contract can withdraw funds using the `withdraw` or `cheaperWithdraw` function.
