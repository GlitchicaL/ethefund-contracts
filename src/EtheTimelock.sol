// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract EtheTimelock is TimelockController {
    constructor(
        uint256 _minDelay,
        address[] memory _proposers,
        address[] memory _executors,
        address _admin
    ) TimelockController(_minDelay, _proposers, _executors, _admin) {}
}
