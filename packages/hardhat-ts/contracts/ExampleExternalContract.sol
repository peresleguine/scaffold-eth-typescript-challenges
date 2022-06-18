pragma solidity >=0.8.0 <0.9.0;

//SPDX-License-Identifier: MIT

contract ExampleExternalContract {
  bool public closed;
  bool public completed;

  function close() public {
    closed = true;
  }

  function complete() public payable {
    completed = true;
  }
}
