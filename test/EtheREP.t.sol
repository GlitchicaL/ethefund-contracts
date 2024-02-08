// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {EtheREP} from "../src/EtheREP.sol";

contract EtheREPTest is Test {
    EtheREP public etherep;

    function setUp() public {
        etherep = new EtheREP();
    }

    function test_totalSupply() public {
        assertEq(etherep.totalSupply(), 1000000 ether);
    }

    function test_balance() public {
        // We initially have the totalSupply
        assertEq(etherep.balanceOf(address(this)), 1000000 ether);
    }

    function test_votes() public {
        // Initially we have 0 votes.
        assertEq(etherep.getVotes(address(this)), 0 ether);
    }

    function test_delegate() public {
        // We delegate ourselves
        etherep.delegate(address(this));
        assertEq(etherep.getVotes(address(this)), 1000000 ether);
    }

    function test_transfer() public {
        etherep.transfer(address(1), 10000 ether);
        assertEq(etherep.balanceOf(address(1)), 10000 ether);
    }

    function test_transferAndDelegate() public {
        uint256 votes = 10000 ether;

        etherep.transfer(address(1), votes);
        assertEq(etherep.balanceOf(address(1)), votes);

        vm.prank(address(1));

        etherep.delegate(address(1));
        assertEq(etherep.getVotes(address(1)), votes);
    }

    function test_multipleDelegates() public {
        uint256 votes = 10000 ether;
        uint256 amountOfDelegates = 10;

        for (uint160 i = 1; i <= amountOfDelegates; i++) {
            etherep.transfer(address(i), votes);

            vm.prank(address(i));

            etherep.delegate(address(i));
            assertEq(etherep.getVotes(address(i)), votes);
        }
    }
}
