// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//deploy mocks when we are on anvil
//keep track of different addresses accross chains 
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator";

contract HelperConfig is Script {

	NetworkConfig public activeNetworkConfig;

	struct NetworkConfig{
		address priceFeed;
	}

	constructor() {
		if (block.chainid == 11155111) {
			activeNetworkConfig = getSepoliaEthConfig();
		} else {
			activeNetworkConfig = getAnvilEthConfig();
		}
	}

	function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
		NetworkConfig memory sepoliaConfig = NetworkConfig({
			priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
			});
		return sepoliaConfig;

	}

	function getAnvilEthConfig() public pure returns (NetworkConfig memory){
		
		vm.startBroadcast();
		MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
		vm.stopBroadcast();

		NetworkConfig memory anvilConfig = NetworkConfig({
			priceFeed: address(mockPriceFeed)
		});
		return anvilConfig;
	}
}