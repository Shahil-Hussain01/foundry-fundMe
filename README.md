## Foundry

1. Create a new project using foundry run "forge init"
2. "forge test" it will run the test
3. "forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit" to install chainlink contracts
4. "forge build" or "forge compile" it will compile the smart contract
5. "forge coverage --fork-url $SEPOLIA_RPC_URL" it will show how many line of code are covered in test
6. "forge coverage"
7. "forge snapshot --mt testWithdrawWithMultipleFunders" this will snapshot the gas used on that test in the .gas-snapshot file
8. "forge inspect FundMe storageLayout" it will show the exact layout of storage in fundMe
9. "anvil" and then deploy the contract in anvil "forge script script/DeployFundMe.s.sol --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast" now take the contract address and run the command "cast storage 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 <index>" example "cast storage 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 2"
   **Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

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

### Anvil

```shell
$ anvil
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
