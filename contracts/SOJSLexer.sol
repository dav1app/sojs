// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./SOJSTypes.sol";

contract SOJSLexer {
    using Strings for uint256;

    string public input;
    uint256[] tokens;
    uint256 currCh;
    uint256 nextCh;
    uint256 tk;
    uint256 tokenStart;
    uint256 tokenEnd;
    uint256 tokenLastEnd;
    string tkStr;
    

    constructor(string memory code) {
        console.log('creating');
        input = code;
        //tokenize the whole code 
        SOJSLexerReset();

        while (currCh < bytes(input).length) {
            //get token in the current position
            SOJSLexerGetNextToken();
            //log token
            console.log('token', tkStr);
        }
        //log all tokens 
        console.log('tokens length', tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            console.log(tokens[i]);
        }
    }

    function SOJSLexerMatch(uint256 expected_tk) internal {
        require(tk == expected_tk, "Unexpected token");
        SOJSLexerGetNextToken();
    }

    function SOJSLexerReset() internal {
        currCh = 0;
        nextCh = 0;
        tk = 0;
        tokenStart = 0;
        tokenEnd = 0;
        tokenLastEnd = 0;
        tkStr = "";
        SOJSLexerGetNextCh();
        SOJSLexerGetNextToken();
    }

    function SOJSLexerGetSubString(uint256 pos) internal view returns (string memory) {
        require(pos <= tokenEnd, "Invalid position");

        bytes memory bytesInput = bytes(input);
        bytes memory subBytes = new bytes(tokenEnd - pos);

        for (uint256 i = pos; i < tokenEnd; i++) {
            subBytes[i - pos] = bytesInput[i];
        }

        return string(subBytes);
    }

    function SOJSLexerGetSubLex(uint256 lastPosition) internal returns (SOJSLexer) {
        require(lastPosition <= tokenEnd, "Invalid position");
        return new SOJSLexer(SOJSLexerGetSubString(lastPosition));
    }

    function SOJSLexerGetPosition(int256 pos) internal view returns (string memory) {
        if (pos == -1) {
            pos = int256(tokenEnd);
        }

        return string(abi.encodePacked("Line 1, Column ", uint256(pos).toString()));
    }

    function SOJSLexerGetNextCh() internal {
        bytes memory bytesInput = bytes(input);

        if (nextCh < bytesInput.length) {
            currCh = nextCh;
            nextCh++;
        } else {
            currCh = bytesInput.length;
            nextCh = bytesInput.length;
        }
    }

    function SOJSLexerGetNextToken() internal {
        bytes memory bytesInput = bytes(input);

        while (nextCh < bytesInput.length && bytesInput[nextCh] != ' ') {
            SOJSLexerGetNextCh();
        }
        tokenStart = currCh;
        tokenEnd = nextCh;
        tkStr = SOJSLexerGetSubString(tokenStart);
    }

    function isAlpha(uint256 _char) public pure returns (bool) {
        return (_char >= 65 && _char <= 90) || (_char >= 97 && _char <= 122);
    }
}
