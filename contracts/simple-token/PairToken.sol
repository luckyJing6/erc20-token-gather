// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract PairToken is ERC20 {
    constructor() ERC20("PairToken", "PTK") {
        uint256 totalSupply = 100000000000 * 10 ** decimals();
        _mint(_msgSender(), totalSupply);
    }
}
