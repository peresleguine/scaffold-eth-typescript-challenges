pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool openForWithdraw = false;

  event Stake(address, uint256);

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), 'The staking is completed');
    _;
  }

  modifier notClosed() {
    require(!exampleExternalContract.closed(), 'The staking is closed');
    _;
  }

  modifier notOpenForWithdraw() {
    require(!openForWithdraw, 'The staking period is over and the contract is open for withdrawal');
    _;
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable notCompleted notClosed notOpenForWithdraw {
    require(this.timeLeft() > 0, 'The staking period is over');
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public notCompleted notClosed notOpenForWithdraw {
    require(this.timeLeft() == 0, 'The staking is in progress');
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function
      if (address(this).balance == 0) {
        exampleExternalContract.close();
      } else {
        openForWithdraw = true;
      }
    }
  }

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  function withdraw() public notCompleted notClosed {
    require(openForWithdraw, 'Not open for withdraw');
    require(balances[msg.sender] > 0, 'You have nothing to withdraw');
    uint256 value = balances[msg.sender];
    payable(msg.sender).transfer(value);
    balances[msg.sender] -= value;
    if (address(this).balance == 0) {
      openForWithdraw = false;
      exampleExternalContract.close();
    }
  }

  // TODO: Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
