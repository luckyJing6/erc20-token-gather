// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interface/IERC20.sol";
import "../interface/IERC20Metadata.sol";
import "./Context.sol";

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

    function totalSupply() external view override returns (uint256) {
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
