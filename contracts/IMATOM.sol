pragma solidity ^0.5.2;

import './EarningToken.sol';

contract IMATOM is EarningToken {
    string public _name;
    string public _symbol;
    uint8 public _decimals;

    constructor () public {
        _name = 'IMATOM';
        _symbol = 'IMATOM';
        _decimals = 6;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }
}