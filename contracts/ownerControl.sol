// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Contract {
  string public name;

  // Random Remix Test Wallet
  address constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

  constructor(string memory _name){
    name = _name;
  }

  function setName(string memory _newName) external {
    require(msg.sender == owner, "Only the contract owner can change the name");
    name = _newName;
  }
}