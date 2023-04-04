// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interface/IPROXY.sol";

contract UUPS1 is IPROXY {
    address public owner;
    address public implementation;
    uint256 public number;

    function setNumber(uint256 _num) external override returns (bool) {
        number= _num + 1;
        return true;
    }
}
