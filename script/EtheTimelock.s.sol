// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/EtheTimelock.sol";

contract EtheTimelockDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address[] memory validAddresses = new address[](1);
        validAddresses[0] = address(this);

        EtheTimelock etheTimelock = new EtheTimelock(
            0,
            validAddresses,
            validAddresses,
            address(this)
        );

        vm.stopBroadcast();
    }
}
