// What is the purpose of this helper contract?
// 1. To deploy mocks when we are on a local Anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local Anvil, we deploy mocks
    // Otherwise, grab the existing address from the live network
    

    NetworkConfig public activeNetworkConfig;       // State variable that can be used for whichever function I want.
    uint8 public constant DECIMALS = 8;             // To have magic numbers such as these as constant variables is extremely useful and should be practiced. Number values as constants.
    int256 public constant INITIAL_PRICE = 2000e8;



    struct NetworkConfig {
        // The struct will create a new typt that will be used in this mock contract
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {    // If the chain ID equals that of Sepolia go to it - otherwise go to the Anvil chain
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }


    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // What we will need:
        // Price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });

        return sepoliaConfig;
    }


    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // What we will need:
        // Price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });

        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // What we will need:
        // Price feed address

        // 1. Deploy the mocks
        // 2. Return the mockk address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }


}
