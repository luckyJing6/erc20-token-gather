// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract SimpleToken is ERC20 {
    constructor() ERC20("SimpleToken", "SPT") {
        uint256 totalSupply = 100000000 * 10 ** decimals();
        _mint(_msgSender(), totalSupply);
    }
}
