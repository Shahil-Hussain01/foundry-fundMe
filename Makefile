# Makefile is used as a shortcuts 

-include .env

build:; forge build
# here we need to run the command "make build" to run the command "forge build"

deploy-sepolia:; forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast
# here we need to run the command "make deploy-sepolia" to run the command "forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast"

# here we verify our contract also in etherscan. now we can intract with our contract in etherscan.