// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     * 代币总量
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     * 查询地址代币余额
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     * 调用者向其他地址转账
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     *
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     *
     * 查询某个账号对合约的批准额度
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     *
     * Emits an {Approval} event.
     *
     * 批准/授权
     * @param spender 授权的合约地址
     * @param amount 授权金额
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     *
     * 合约通过该方法对账号进行转账
     * @param from 普通账户
     * @param to 目标地址
     * @param amount 金额
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
//
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 *
 * 中文解释：
 * 1、简单的理解就是一个抽象合约，里面封装了当前执行信息的执行上下文
 * 2、msg.sender与msg.data
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

//

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {
    // 普通账户地址 -> 余额
    mapping(address => uint) private _balances;
    // 普通账户地址 -> 合约地址 -> 授权额度
    mapping(address => mapping(address => uint)) _allowance;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function _transfor(address from, address to, uint256 amount) private {
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    /**
     * 查询账户余额
     * @param account 账户地址
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * 普通账户地址向其他地址进行转账
     * @param to 目标地址
     * @param amount 数量
     */
    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        address owner = _msgSender();
        _transfor(owner, to, amount);
        return true;
    }

    /**
     * 查询某个账号对合约的批准额度
     * @param owner 普通账户地址
     * @param spender 合约地址
     */
    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowance[owner][spender];
    }

    /**
     * 合约授权/批准
     * @param spender 合约地址
     * @param amount 数量
     */
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        address owner = _msgSender();
        _allowance[owner][spender] += amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    /**
     * 合约通过该方法对账号进行转账
     * @param from 普通账户
     * @param to 目标地址
     * @param amount 金额
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        address spender = _msgSender();
        _allowance[from][spender] -= amount;
        _transfor(from, to, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}

pragma solidity ^0.8.0;

/**
 * 1. 交易兑信息
 * 2. 添加池子，获取token
 */

error TokenPair__ApproveToken(address token);

contract TokenPair is ERC20 {
    address public factory; // 工厂合约

    address public rewardToken; // 奖励代币
    uint256 public rewardSpeed; // 每秒奖励数量

    mapping(address => uint256) public claimStartTime; // 开始时间
    mapping(address => uint256) public cacheClainAmount; // 缓存数量

    // 池子
    address public token0;
    address public token1;

    uint256 private reserve0; // token0余额
    uint256 private reserve1; // token1余额

    uint256 public rate; // token0/token1 兑换比例，不是一个好办法

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
        if(totalSupply() == 0) {
            return 0;
        }
        uint256 amount0 = balanceOf(msg.sender);
        uint256 speed = (amount0 / totalSupply()) * rewardSpeed;
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
