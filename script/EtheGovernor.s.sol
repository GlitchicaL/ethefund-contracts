// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/EtheREP.sol";
import "../src/EtheTimelock.sol";
import "../src/EtheGovernor.sol";

contract EtheGovernorDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Get EtheREP token address
        EtheREP etheREP = EtheREP(0x5FbDB2315678afecb367f032d93F642f64180aa3);

        // Get EtheTimelock address
        EtheTimelock etheTimelock = EtheTimelock(
            payable(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512)
        );

        // Deploy EtheGovernor
        EtheGovernor etheGovernor = new EtheGovernor(etheREP, etheTimelock);

        vm.stopBroadcast();
    }
}
