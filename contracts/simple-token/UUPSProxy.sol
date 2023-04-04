// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interface/IPROXY.sol";

/**
 * 可升级代理合约(非通用，通用则是要fallback统一处理)
 * 1. 代理地址，部署者，状态变量
 * 2. 读写状态变量的方法
 */

contract UUPSProxy is IPROXY {
    address public owner;
    address public implementation;
    uint256 public number;

    event EUpgrade(address indexed imple, uint256 ts);

    constructor(address _implementation) {
        owner = msg.sender;
        implementation = _implementation;
    }

    modifier onlyowner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    function upgrade(address newImplementation) external onlyowner {
        require(implementation != newImplementation);
        implementation = newImplementation;
        emit EUpgrade(implementation, block.timestamp);
    }

    function setNumber(uint256 _num) external override returns (bool) {
        implementation.delegatecall(
            abi.encodeWithSignature("setNumber(uint256)", _num)
        );
        return true;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}
