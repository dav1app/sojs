// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./SOJS.sol";
import "./SOJSLexer.sol";
import "./SOJSTypes.sol";
import "./SOJSException.sol";
import "./SOJSCallback.sol";

contract Script {
  function main() public {
    SOJS sojs = new SOJS();
    sojs.execute("var a = 1;");
  }
}