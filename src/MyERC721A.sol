// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "ERC721A/ERC721A.sol";

contract MyERC721A is ERC721A {
    constructor() ERC721A("MyERC721A", "ME721A") {}

    function mint(address to, uint256 quantity) public {
        _safeMint(to, quantity);
    }
}