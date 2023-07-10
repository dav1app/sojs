// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./SOJSLexer.sol";
import "./SOJSTypes.sol";
import "./SOJSException.sol";
import "./SOJSCallback.sol";
import "hardhat/console.sol";

contract SOJS {
  event log(string);

  function execute(string calldata code) public {
    SOJSLexer lexer = new SOJSLexer(code);
    console.log('lexer', address(lexer));
  }

  // function statement(bool execute) {

  // }

}