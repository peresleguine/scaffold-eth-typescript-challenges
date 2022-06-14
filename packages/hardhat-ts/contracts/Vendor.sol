pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken public yourToken;

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  modifier withoutZeroTransfers(uint256 value) {
    require(value > 0, 'The amount should be greater than zero.');
    _;
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable withoutZeroTransfers(msg.value) {
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amountOfTokens) public withoutZeroTransfers(amountOfTokens) {
    yourToken.transferFrom(msg.sender, address(this), amountOfTokens);
    payable(msg.sender).transfer(amountOfTokens / tokensPerEth);
  }
}
