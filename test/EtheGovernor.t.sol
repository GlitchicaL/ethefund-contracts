// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {EtheREP} from "../src/EtheREP.sol";
import {EtheTimelock} from "../src/EtheTimelock.sol";
import {EtheGovernor} from "../src/EtheGovernor.sol";

import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EtheGovernorTest is Test {
    EtheREP public etherep;
    EtheTimelock public etheTimelock;
    EtheGovernor public etheGovernor;

    /**
     * Steps:
     * - Deploy ERC20Votes
     * - Deploy Timelock
     * - Deploy Governor
     */
    function setUp() public {
        // Token
        etherep = new EtheREP();

        // Timelock
        address[] memory proposers = new address[](1);
        proposers[0] = address(10);

        address[] memory executors = new address[](1);
        executors[0] = address(10);

        etheTimelock = new EtheTimelock(
            1 days,
            proposers,
            executors,
            address(this)
        );

        (bool success, ) = address(etheTimelock).call{value: 1 ether}("");
        assertTrue(success);

        // Governor
        etheGovernor = new EtheGovernor(etherep, etheTimelock);

        // Grant Governor proposer role
        etheTimelock.grantRole(
            etheTimelock.PROPOSER_ROLE(),
            address(etheGovernor)
        );

        // Grant Governor executor role
        etheTimelock.grantRole(
            etheTimelock.EXECUTOR_ROLE(),
            address(etheGovernor)
        );
    }

    // --- Helper Functions --- //

    function setDelegates() public {
        uint256 votes = 10000 ether;
        uint256 amountOfDelegates = 5;

        for (uint160 i = 1; i <= amountOfDelegates; i++) {
            address delegatee = address(i);
            etherep.transfer(delegatee, votes);

            vm.prank(delegatee);

            etherep.delegate(delegatee);
            assertEq(etherep.getVotes(delegatee), votes);
        }
    }

    function setVote(address _voter, uint256 _id, uint8 _stance) public {
        vm.prank(_voter);
        etheGovernor.castVote(_id, _stance);
    }

    // --- Unit Tests --- //

    function test_hasRole() public {
        assertTrue(
            etheTimelock.hasRole(
                etheTimelock.PROPOSER_ROLE(),
                address(etheGovernor)
            )
        );

        assertTrue(
            etheTimelock.hasRole(
                etheTimelock.EXECUTOR_ROLE(),
                address(etheGovernor)
            )
        );

        assertTrue(
            etheTimelock.hasRole(etheTimelock.EXECUTOR_ROLE(), address(10))
        );

        assertFalse(
            etheTimelock.hasRole(etheTimelock.EXECUTOR_ROLE(), address(100))
        );
    }

    function test_proposals() public returns (uint256) {
        // Transfer ETH
        address[] memory targets = new address[](1);
        targets[0] = address(1000);

        uint256[] memory values = new uint256[](1);
        values[0] = 1 ether;

        bytes[] memory data = new bytes[](1);
        data[0] = "";

        string memory description = "Proposal #1: Give grant to charity";

        uint256 id = etheGovernor.propose(targets, values, data, description);

        IGovernor.ProposalState state = etheGovernor.state(id);

        assertTrue(state == IGovernor.ProposalState.Pending);

        return id;
    }

    function test_castVote() public {
        setDelegates();
        uint256 id = test_proposals();

        vm.roll(block.number + (etheGovernor.votingDelay() + 1));

        IGovernor.ProposalState state = etheGovernor.state(id);
        assertTrue(state == IGovernor.ProposalState.Active);

        vm.prank(address(1));
        etheGovernor.castVote(id, 1);
        assertTrue(etheGovernor.hasVoted(id, address(1)));
    }

    function test_successful_state() public {
        setDelegates();
        uint256 id = test_proposals();

        vm.roll(block.number + (etheGovernor.votingDelay() + 1));

        IGovernor.ProposalState state = etheGovernor.state(id);

        setVote(address(1), id, 1);
        setVote(address(2), id, 1);
        setVote(address(3), id, 1);
        setVote(address(4), id, 1);
        setVote(address(5), id, 0);

        vm.roll(block.number + (etheGovernor.votingPeriod() + 1));

        state = etheGovernor.state(id);
        assertTrue(state == IGovernor.ProposalState.Succeeded);
    }

    function test_defeated_state() public {
        setDelegates();
        uint256 id = test_proposals();

        vm.roll(block.number + (etheGovernor.votingDelay() + 1));

        IGovernor.ProposalState state = etheGovernor.state(id);

        setVote(address(1), id, 1);
        setVote(address(2), id, 1);
        setVote(address(3), id, 0);
        setVote(address(4), id, 0);
        setVote(address(5), id, 0);

        vm.roll(block.number + (etheGovernor.votingPeriod() + 1));

        state = etheGovernor.state(id);
        assertTrue(state == IGovernor.ProposalState.Defeated);
    }

    function test_execution() public {
        // Setup delegates...
        setDelegates();
        uint256 id = test_proposals();

        // Setup voting...
        vm.roll(block.number + (etheGovernor.votingDelay() + 1));

        IGovernor.ProposalState state = etheGovernor.state(id);

        setVote(address(1), id, 1);
        setVote(address(2), id, 1);
        setVote(address(3), id, 1);
        setVote(address(4), id, 1);
        setVote(address(5), id, 0);

        vm.roll(block.number + (etheGovernor.votingPeriod() + 1));

        state = etheGovernor.state(id);
        assertTrue(state == IGovernor.ProposalState.Succeeded);
        assertTrue(etheGovernor.proposalEta(id) == 0);
        assertTrue(etheGovernor.proposalNeedsQueuing(id));

        // Setup queuing...
        address[] memory targets = new address[](1);
        targets[0] = address(1000);

        uint256[] memory values = new uint256[](1);
        values[0] = 1 ether;

        bytes[] memory data = new bytes[](1);
        data[0] = "";

        bytes32 description = keccak256("Proposal #1: Give grant to charity");

        vm.prank(address(10));
        etheGovernor.queue(targets, values, data, description);

        state = etheGovernor.state(id);
        assertTrue(state == IGovernor.ProposalState.Queued);
        assertTrue(etheGovernor.proposalEta(id) == 86401 seconds);
        assertTrue(address(1000).balance == 0 ether);

        // Setup execution...
        vm.warp(block.timestamp + etheGovernor.proposalEta(id));
        vm.prank(address(10));
        etheGovernor.execute(targets, values, data, description);

        state = etheGovernor.state(id);
        assertTrue(state == IGovernor.ProposalState.Executed);
        assertTrue(address(1000).balance == 1 ether);
    }
}
