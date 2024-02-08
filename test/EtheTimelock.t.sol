// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {EtheREP} from "../src/EtheREP.sol";
import {EtheTimelock} from "../src/EtheTimelock.sol";
import {EtheGovernor} from "../src/EtheGovernor.sol";

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EtheGovernorTest is Test {
    EtheTimelock public etheTimelock;

    function setUp() public {
        // Timelock
        address[] memory validAddresses = new address[](1);
        validAddresses[0] = address(this);

        etheTimelock = new EtheTimelock(
            180,
            validAddresses,
            validAddresses,
            address(this)
        );
    }

    function test_balance() public {
        uint256 value = 1 ether;

        (bool success, ) = address(etheTimelock).call{value: value}("");
        require(success);

        assertEq(address(etheTimelock).balance, value);
    }
}
