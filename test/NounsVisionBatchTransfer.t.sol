// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NounsVisionBatchTransfer.sol";

contract NounsVisionBatchTransferTest is Test {
    NounsVisionBatchTransfer public batcher;
    ERC721Like public nounsVision;
    address public nounsDAO;
    address pod1 = makeAddr("pod1");
    uint256 daoBalance;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        batcher = new NounsVisionBatchTransfer();
        nounsVision = batcher.NOUNS_VISION();
        nounsDAO = batcher.NOUNS_DAO();
        daoBalance = nounsVision.balanceOf(nounsDAO);
    }

    function test_GETSTARTIDANDBATCHAMOUNT_happyCase() public {
        vm.startPrank(nounsDAO);
        nounsVision.setApprovalForAll(address(batcher), true);
        batcher.addAllowance(address(pod1), 1);
        vm.stopPrank();
        (uint256 startId, uint256 amount) = batcher.getStartIdAndBatchAmount(
            pod1
        );
        assertEq(startId, 751);
        assertEq(amount, 1);

        vm.prank(pod1);
        batcher.batchTransfer(startId, amount);

        (startId, amount) = batcher.getStartIdAndBatchAmount(pod1);
        assertEq(startId, 752);
        assertEq(amount, 0);

        vm.prank(nounsDAO);
        batcher.addAllowance(address(pod1), 10000);

        (startId, amount) = batcher.getStartIdAndBatchAmount(pod1);
        assertEq(startId, 752);
        assertEq(amount, 499);
    }

    function test_GETSTARTIDANDBATCHAMOUNT_Revert_NotEnoughOwned() public {
        (uint256 startId, ) = batcher.getStartIdAndBatchAmount(pod1);

        vm.prank(nounsDAO);
        nounsVision.setApprovalForAll(address(batcher), true);

        vm.prank(nounsDAO);
        batcher.addAllowance(address(pod1), daoBalance);

        vm.prank(pod1);
        batcher.batchTransfer(startId, daoBalance);

        vm.expectRevert(NounsVisionBatchTransfer.NotEnoughOwned.selector);
        (startId, ) = batcher.getStartIdAndBatchAmount(pod1);
    }

    function test_ADDALLOWANCE_happyCase() public {
        assertEq(batcher.allowanceFor(address(pod1)), 0);
        vm.prank(nounsDAO);
        batcher.addAllowance(pod1, 1);
        assertEq(batcher.allowanceFor(address(pod1)), 1);
    }

    function test_ADDALLOWANCE_Revert_NotNounsDAO() public {
        vm.expectRevert(NounsVisionBatchTransfer.NotNounsDAO.selector);
        batcher.addAllowance(pod1, 1);
    }

    function test_DISALLOW_happyCase() public {
        vm.prank(nounsDAO);
        batcher.addAllowance(pod1, 1);
        assertEq(batcher.allowanceFor(address(pod1)), 1);

        vm.prank(nounsDAO);
        batcher.disallow(pod1);
        assertEq(batcher.allowanceFor(address(pod1)), 0);
    }

    function test_DISALLOW_Revert_NotNounsDAO() public {
        vm.expectRevert(NounsVisionBatchTransfer.NotNounsDAO.selector);
        batcher.disallow(pod1);
    }

    function test_BATCHTRANSFER_happyCase() public {
        uint256 startId;
        uint256 amount = 50;

        vm.startPrank(nounsDAO);
        batcher.addAllowance(pod1, amount);
        nounsVision.setApprovalForAll(address(batcher), true);
        vm.stopPrank();

        (startId, ) = batcher.getStartIdAndBatchAmount(pod1);
        vm.prank(pod1);
        batcher.batchTransfer(startId, amount / 2);

        assertEq(nounsVision.ownerOf(startId), address(pod1));
        assertEq(nounsVision.ownerOf(startId - 1 + amount / 2), address(pod1));
        assertEq(nounsVision.balanceOf(pod1), amount / 2);
        assertEq(nounsVision.balanceOf(nounsDAO), daoBalance - (amount / 2));
        assertEq(batcher.allowanceFor(pod1), amount / 2);

        (startId, ) = batcher.getStartIdAndBatchAmount(pod1);
        assertEq(startId, 751 + (amount / 2));

        vm.prank(pod1);
        batcher.batchTransfer(startId, amount / 2);
        assertEq(nounsVision.balanceOf(pod1), amount);
        assertEq(nounsVision.balanceOf(nounsDAO), daoBalance - amount);
        assertEq(batcher.allowanceFor(pod1), 0);
    }

    function test_BATCHTRANSFER_Revert_NotEnoughOwned() public {
        vm.startPrank(nounsDAO);
        nounsVision.setApprovalForAll(address(batcher), true);
        batcher.addAllowance(pod1, daoBalance * 2);
        vm.stopPrank();

        (uint256 startId, ) = batcher.getStartIdAndBatchAmount(pod1);
        vm.startPrank(pod1);
        batcher.batchTransfer(startId, daoBalance - 1);

        (startId, ) = batcher.getStartIdAndBatchAmount(pod1);
        vm.expectRevert(NounsVisionBatchTransfer.NotEnoughOwned.selector);
        batcher.batchTransfer(startId, 2);
    }

    function test_BATCHTRANSFER_Revert_NotEnoughAllowance() public {
        (uint256 startId, ) = batcher.getStartIdAndBatchAmount(pod1);
        vm.expectRevert(NounsVisionBatchTransfer.NotEnoughAllowance.selector);
        vm.prank(pod1);
        batcher.batchTransfer(startId, 1);

        vm.startPrank(nounsDAO);
        nounsVision.setApprovalForAll(address(batcher), true);
        batcher.addAllowance(pod1, 1);
        vm.stopPrank();

        vm.startPrank(pod1);
        batcher.batchTransfer(startId, 1);

        vm.expectRevert(NounsVisionBatchTransfer.NotEnoughAllowance.selector);
        batcher.batchTransfer(startId, 1);
    }

    function test_BATCHTRANSFER_fuzz(
        address addr1,
        address addr2,
        uint256 amount1,
        uint256 amount2
    ) public {
        vm.assume(addr1 != address(0));
        vm.assume(addr2 != address(0));

        amount1 = bound(amount1, 1, 499);
        amount2 = bound(amount2, 1, 500 - amount1);

        (uint256 startId, ) = batcher.getStartIdAndBatchAmount(pod1);

        // NotEnoughAllowance
        vm.expectRevert(NounsVisionBatchTransfer.NotEnoughAllowance.selector);
        vm.prank(addr1);
        batcher.batchTransfer(startId, amount1);

        // NotNounsDAO
        vm.expectRevert(NounsVisionBatchTransfer.NotNounsDAO.selector);
        vm.prank(addr1);
        batcher.addAllowance(addr1, amount1);

        vm.startPrank(nounsDAO);
        nounsVision.setApprovalForAll(address(batcher), true);
        batcher.addAllowance(addr1, amount1);
        batcher.addAllowance(addr2, amount2);
        vm.stopPrank();

        // fuzzer can input the same address twice
        if (addr1 == addr2) {
            assertEq(batcher.allowanceFor(addr1), amount1 + amount2);
        } else {
            assertEq(batcher.allowanceFor(addr1), amount1);
            assertEq(batcher.allowanceFor(addr2), amount2);
        }
        vm.prank(addr1);
        batcher.batchTransfer(startId, amount1);

        (startId, ) = batcher.getStartIdAndBatchAmount(pod1);
        vm.prank(addr2);
        batcher.batchTransfer(startId, amount2);

        assertEq(batcher.allowanceFor(addr1), 0);
        assertEq(batcher.allowanceFor(addr2), 0);
    }
}
