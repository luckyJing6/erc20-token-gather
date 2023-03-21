// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenPair.sol";

/**
 * 1. 创建交易兑，设置兑率
 */

contract TokenPairFactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public pairsList;

    address public immutable owner;
    address public rewardToken;
    uint256 public rewardSpeed;

    event EPairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256 pairsLength
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPair(
        address token0,
        address token1,
        uint256 rate
    ) external returns (address pair) {
        require(token0 != token1, "identical address");
        require(token0 != address(0), "token0 zero address");
        require(token1 != address(0), "token1 zero address");

        TokenPair tokenPair = new TokenPair();

        pair = address(tokenPair);
        tokenPair.init(token0, token1, rate);
        tokenPair.setRewardToken(rewardToken, rewardSpeed);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        pairsList.push(pair);

        emit EPairCreated(token0, token1, pair, pairsList.length);
    }

    function setRewardInfo(address _token) public onlyOwner {
        rewardToken = _token;
    }

    function setRewardSpeed(uint256 _speed) public onlyOwner {
        rewardSpeed = _speed;
    }

    function setRewardInfo(address _token, uint256 _speed) public onlyOwner {
        rewardToken = _token;
        rewardSpeed = _speed;
    }
}
