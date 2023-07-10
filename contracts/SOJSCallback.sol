// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./SOJSVar.sol";

abstract contract SOJSCallback {
  function execute(SOJSVar r_var, bytes memory userdata) external virtual;
}