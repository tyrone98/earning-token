pragma solidity ^0.5.2;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title Mintable contract
 */
interface IMintable {
    function mint(address to, uint256 value, string calldata from) external returns (bool);
    function burn(uint256 value, string calldata to) external returns (bool);

    event Burn(address indexed owner, uint256 value, string from);
    event Mint(address indexed owner, uint256 value, string to);
}
