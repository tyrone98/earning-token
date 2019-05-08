pragma solidity ^0.5.2;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './IMintable.sol';

contract EarningToken is IERC20 , IMintable, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping( address => uint256 )) private _allowed;

    uint256 constant RATE_DECIMAL = 10 ** 8;

    uint256 private _totalShadow;
    uint256 private _exchangeRate = 1 * RATE_DECIMAL; //initial exchange rate is 1.0

    event DistributeEarning(uint256 value);

    function balanceOf(address who) external view returns (uint256) {
        return _calculateValue(_balances[who]);
    }

    function totalSupply() external view returns (uint256) {
        return _calculateValue(_totalShadow);
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint value) external returns (bool) {
        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function distributeEarning(uint256 value) external onlyOwner returns (bool) {
        require(_totalShadow != 0, 'total shadow is zero');

        _exchangeRate = _exchangeRate.add(value.mul(RATE_DECIMAL).div(_totalShadow));

        emit DistributeEarning(value);

        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), 'transfer to the zero address');

        uint256 shadowValue = _calculateShadow(value);

        _balances[from] = _balances[from].sub(shadowValue);
        _balances[to] = _balances[to].add(shadowValue);

        emit Transfer(from, to, value);
    }

    function _calculateShadow(uint256 value) internal view returns (uint256) {
        return value.mul(RATE_DECIMAL).div(_exchangeRate);
    }

    function _calculateValue(uint256 shadow) internal view returns (uint256) {
        return shadow.mul(_exchangeRate).div(RATE_DECIMAL);
    }

    function mint(address to, uint256 value, string calldata from) external onlyOwner returns (bool) {
        require(to != address(0), 'mint to the zero address');

        uint256 shadowValue = _calculateShadow(value);

        _totalShadow = _totalShadow.add(shadowValue);
        _balances[to] = _balances[to].add(shadowValue);

        emit Transfer(address(0), to, value);
        emit Mint(to, value, from);

        return true;
    }

    function burn(uint256 value, string calldata to) external returns (bool) {
        address from = msg.sender;

        require(from != address(0), 'burn from the zero address');

        uint256 shadowValue = _calculateShadow(value);

        _totalShadow = _totalShadow.sub(shadowValue);
        _balances[from] = _balances[from].sub(shadowValue);

        emit Transfer(from, address(0), value);
        emit Burn(from, value, to);

        return true;
    }
}