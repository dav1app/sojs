// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.0;

contract StringOperations {
    function length(string memory str) public pure returns (uint256) {
        bytes memory strBytes = bytes(str);
        return strBytes.length;
    }

    function substring(string memory str, uint256 startIndex, uint256 endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(startIndex >= 0 && startIndex < strBytes.length, "Invalid start index");
        require(endIndex > startIndex && endIndex <= strBytes.length, "Invalid end index");

        bytes memory substringBytes = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            substringBytes[i - startIndex] = strBytes[i];
        }
        
        return string(substringBytes);
    }

    function equal(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function isAllLetter(string memory str) public pure returns (bool) {
        bytes memory strBytes = bytes(str);
        for (uint i = 0; i < strBytes.length; i++) {
            bytes1 char = strBytes[i];
            uint8 charValue = uint8(char);
            if (!((charValue >= 65 && charValue <= 90) || (charValue >= 97 && charValue <= 122))) {
                return false;
            }
        }
        return true;
    }

    function concat (string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

}
