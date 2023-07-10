// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
contract SOJSException {
    string public text;

    constructor(string memory exceptionText) {
        text = exceptionText;
    }
}