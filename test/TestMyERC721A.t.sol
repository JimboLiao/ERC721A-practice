// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyERC721A.sol";

contract TestMyERC721A is Test {
    error TransferCallerNotOwnerNorApproved();
    error ApprovalCallerNotOwnerNorApproved();

    MyERC721A instance;
    address bob;
    address alice;

    function setUp() public {
        instance = new MyERC721A();
        bob = makeAddr("bob");
        alice = makeAddr("alice");
    }

    function testMint5Tokens() public {
        uint256 quantity = 5;
        vm.prank(bob);
        instance.mint(bob, quantity);

        assertEq(instance.balanceOf(bob), quantity);
    }

    function testMint10Tokens() public {
        uint256 quantity = 10;
        vm.prank(bob);
        instance.mint(bob, quantity);

        assertEq(instance.balanceOf(bob), quantity);
    }

    function testMint1Token() public {
        uint256 quantity = 1;
        vm.prank(bob);
        instance.mint(bob, quantity);
        
        assertEq(instance.ownerOf(0), bob);
        assertEq(instance.balanceOf(bob), quantity);
    }


    function testSafeTransferFrom() public {
        vm.startPrank(bob);
        instance.mint(bob, 3);
        assertEq(instance.ownerOf(0), bob);
        assertEq(instance.ownerOf(1), bob);
        assertEq(instance.ownerOf(2), bob);
        assertEq(instance.balanceOf(bob), 3);

        // transfer 1 token to alice
        instance.safeTransferFrom(bob, alice, 1);
        vm.stopPrank();

        // check ownership and balance
        assertEq(instance.ownerOf(0), bob);
        assertEq(instance.ownerOf(1), alice);
        assertEq(instance.ownerOf(2), bob);
        assertEq(instance.balanceOf(bob), 2);
        assertEq(instance.balanceOf(alice), 1);
    }

    function testApprove() public {
        vm.prank(bob);
        instance.mint(bob, 2);
        // cannot call approve if not owner or approved for all
        vm.expectRevert(ApprovalCallerNotOwnerNorApproved.selector);
        instance.approve(address(this), 0);
        vm.prank(bob);
        instance.approve(address(this), 0);

        // check approval
        assertEq(instance.getApproved(0), address(this));

        // transfer by approved operator
        instance.safeTransferFrom(bob, alice, 0);
        assertEq(instance.balanceOf(alice), 1);
        assertEq(instance.ownerOf(0), alice);

        // transfer by not approved operator
        vm.expectRevert(TransferCallerNotOwnerNorApproved.selector);
        instance.safeTransferFrom(bob, alice, 1);
    }

    function testSetApprovalForAll() public {
        vm.startPrank(bob);
        instance.mint(bob, 2);
        instance.setApprovalForAll(address(this), true);
        vm.stopPrank();
        // check approval
        assertTrue(instance.isApprovedForAll(bob, address(this)));

        // can call approve if approved for all
        instance.approve(alice, 0);
        assertEq(instance.getApproved(0), alice);

        // transfer by approved operator
        instance.safeTransferFrom(bob, alice, 0);
        instance.safeTransferFrom(bob, alice, 1);
        assertEq(instance.balanceOf(alice), 2);
        assertEq(instance.balanceOf(bob), 0);
        assertEq(instance.ownerOf(0), alice);
        assertEq(instance.ownerOf(1), alice);
    }


    // test gas usage if you have minted lots of tokens, then transfer your last token
    function testGasSafeTransferFromMyLastToken() public {
        uint256 quantity = 20;
        vm.startPrank(bob);
        instance.mint(bob, quantity);
        instance.safeTransferFrom(bob, alice, quantity-1);
        vm.stopPrank();
    }

    // test gas usage if you have minted lots of tokens, then transfer your first token
    function testGasSafeTransferFromMyFirstToken() public {
        uint256 quantity = 20;
        vm.startPrank(bob);
        instance.mint(bob, quantity);
        instance.safeTransferFrom(bob, alice, 0);
        vm.stopPrank();
    }

}