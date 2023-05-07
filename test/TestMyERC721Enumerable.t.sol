// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyERC721Enumerable.sol";

contract TestMyERC721Enumerable is Test {
    MyERC721Enumerable instance;
    address bob;
    address alice;

    function setUp() public {
        instance = new MyERC721Enumerable();
        bob = makeAddr("bob");
        alice = makeAddr("alice");
    }

    function testMint5Tokens() public {
        vm.startPrank(bob);
        // mint tokens
        instance.mint(bob, 0);
        instance.mint(bob, 1);
        instance.mint(bob, 2);
        instance.mint(bob, 3);
        instance.mint(bob, 4);

        vm.stopPrank();

        assertEq(instance.balanceOf(bob), 5);
    }

    function testMint10Tokens() public {
        vm.startPrank(bob);
        // mint tokens
        instance.mint(bob, 0);
        instance.mint(bob, 1);
        instance.mint(bob, 2);
        instance.mint(bob, 3);
        instance.mint(bob, 4);
        instance.mint(bob, 5);
        instance.mint(bob, 6);
        instance.mint(bob, 7);
        instance.mint(bob, 8);
        instance.mint(bob, 9);

        vm.stopPrank();

        assertEq(instance.balanceOf(bob), 10);
    }

    function testMint1Token() public {
        uint256 tokenId = 0;
        vm.startPrank(bob);
        // mint tokens
        instance.mint(bob, tokenId);

        vm.stopPrank();

        assertEq(instance.balanceOf(bob), 1);
    }

    function testSafeTransferFrom() public {
        uint256 tokenId = 0;

        vm.startPrank(bob);
        instance.mint(bob, tokenId);
        assertEq(instance.ownerOf(tokenId), bob);
        assertEq(instance.balanceOf(bob), 1);

        // transfer 1 token to alice
        instance.safeTransferFrom(bob, alice, tokenId);
        vm.stopPrank();

        assertEq(instance.ownerOf(tokenId), alice);
        assertEq(instance.balanceOf(bob), 0);
        assertEq(instance.balanceOf(alice), 1);
    }

    function testApprove() public {
        uint256 tokenId1 = 0;
        uint256 tokenId2 = 1;

        vm.startPrank(bob);
        instance.mint(bob, tokenId1);
        instance.mint(bob, tokenId2);
        vm.stopPrank();
        // cannot call approve if not owner or approved for all
        vm.expectRevert("ERC721: approve caller is not token owner or approved for all");
        instance.approve(address(this), tokenId1);
        vm.prank(bob);
        instance.approve(address(this), tokenId1);
        

        // check approval
        assertEq(instance.getApproved(tokenId1), address(this));
        // transfer by approved operator
        instance.safeTransferFrom(bob, alice, tokenId1);
        assertEq(instance.balanceOf(alice), 1);
        assertEq(instance.ownerOf(tokenId1), alice);

        // transfer by not approved operator
        vm.expectRevert("ERC721: caller is not token owner or approved");
        instance.safeTransferFrom(bob, alice, tokenId2);
    }

    function testSetApprovalForAll() public {
        uint256 tokenId1 = 0;
        uint256 tokenId2 = 1;

        vm.startPrank(bob);
        instance.mint(bob, tokenId1);
        instance.mint(bob, tokenId2);
        instance.setApprovalForAll(address(this), true);
        vm.stopPrank();
        // check approval
        assertTrue(instance.isApprovedForAll(bob, address(this)));

        // can call approve if approved for all
        instance.approve(alice, tokenId1);
        assertEq(instance.getApproved(tokenId1), alice);

        // transfer by approved operator
        instance.safeTransferFrom(bob, alice, tokenId1);
        instance.safeTransferFrom(bob, alice, tokenId2);
        assertEq(instance.balanceOf(alice), 2);
        assertEq(instance.balanceOf(bob), 0);
        assertEq(instance.ownerOf(tokenId1), alice);
        assertEq(instance.ownerOf(tokenId2), alice);
    }
}