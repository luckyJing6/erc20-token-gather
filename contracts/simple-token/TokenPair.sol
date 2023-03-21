// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "../interface/IERC20.sol";

/**
 * 1. 交易兑信息
 * 2. 添加池子，获取token
 */

error TokenPair__ApproveToken(address token);

contract TokenPair is ERC20 {
    address public factory; // 工厂合约

    address public rewardToken; // 奖励代币
    uint256 public rewardSpeed; // 每秒奖励数量

    mapping(address => uint256) claimStartTime; // 开始时间
    mapping(address => uint256) cacheClainAmount; // 缓存数量

    // 池子
    address public token0;
    address public token1;

    uint256 private reserve0; // token0余额
    uint256 private reserve1; // token1余额

    uint256 private rate; // token0/token1 兑换比例，不是一个好办法

    event EAddLiquidity(address indexed sender, uint amount0, uint amount1);
    event ERemoveLiquidity(address indexed sender, uint amount);

    modifier onlyOwner() {
        require(msg.sender == factory, "only factory");
        _;
    }

    constructor() ERC20("TokenPair", "TLP") {
        factory = msg.sender;
    }

    modifier verifyRate(uint256 amount0, uint256 amount1) {
        require(amount0 / amount1 == rate, "rage error");
        _;
    }

    /**
     * 初始化池子，仅调用一次
     * @param _token0 token0
     * @param _token1 token1
     */
    function init(
        address _token0,
        address _token1,
        uint256 _rate
    ) external onlyOwner {
        require(msg.sender == factory, "factory error");
        token0 = _token0;
        token1 = _token1;
        rate = _rate;
    }

    function setRewardToken(
        address _rewardToken,
        uint256 _rewardSpeed
    ) external onlyOwner {
        rewardToken = _rewardToken;
        rewardSpeed = _rewardSpeed;
    }

    /**
     * 添加流动性,获得token
     * @param amount0 token0数量
     * @param amount1 token1数量
     */
    function addLiquidity(
        uint256 amount0,
        uint256 amount1
    ) public verifyRate(amount0, amount1) returns (uint liquidity) {
        IERC20 iToken0 = IERC20(token0);
        IERC20 iToken1 = IERC20(token1);
        
        // 转移代币
        iToken0.transferFrom(msg.sender, address(this), amount0);
        iToken1.transferFrom(msg.sender, address(this), amount1);

        // 创建当前代币，临时处理，最佳办法采用uniswap的算法
        _mint(msg.sender, amount0);

        // 设置获取当前的奖励存入缓存，重新设置奖励时间
        _setClaimCatch(block.timestamp);

        emit EAddLiquidity(msg.sender, amount0, amount1);
        return amount0;
    }

    /**
     * 设置缓存领取数量
     * @param time 时间
     */
    function _setClaimCatch(uint256 time) internal {
        uint cvalue = getClaimValue();
        cacheClainAmount[msg.sender] = cvalue;
        claimStartTime[msg.sender] = time;
    }

    /**
     * 移除所有流动性(后面可以扩展移除对应数量的方法)
     */
    function removeLiquidityAll() public {
        uint256 amount0 = balanceOf(msg.sender);
        uint256 amount1 = amount0 * rate;
        // 销毁代币
        _burn(msg.sender, amount0);
        // 还原代币
        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);

        // 设置缓存
        _setClaimCatch(0);

        emit ERemoveLiquidity(msg.sender, amount0);
    }

    function getSpeed() public view returns (uint256) {
        uint256 amount0 = balanceOf(msg.sender);
        uint256 totalValue = balanceOf(address(this));
        uint256 speed = (amount0 / totalValue) * rewardSpeed;
        return speed;
    }

    function getClaimValue() public view returns (uint256) {
        if (
            claimStartTime[msg.sender] > 0 || cacheClainAmount[msg.sender] > 0
        ) {
            // 缓存数量
            uint256 cvalue = cacheClainAmount[msg.sender];
            // 当前速度的数量
            uint256 diffTime = block.timestamp - claimStartTime[msg.sender];
            uint256 value = getSpeed() * diffTime;
            return value + cvalue;
        }
        return 0;
    }

    /**
     * 领取奖励
     */
    function claim() public {
        require(
            claimStartTime[msg.sender] > 0 || cacheClainAmount[msg.sender] > 0,
            "need addLiquidity"
        );
        uint256 rvalue = getClaimValue();
        // 清空数量
        cacheClainAmount[msg.sender] = 0;
        claimStartTime[msg.sender] = block.timestamp;
        // 转账
        IERC20(rewardToken).transfer(msg.sender, rvalue);
    }
}
