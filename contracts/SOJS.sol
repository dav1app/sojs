// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "hardhat/console.sol";

contract SOJSLexer {

    struct Token {
        string _name;
        string _literal;
        uint256 _type;
        bool _exists;
    }

    struct Pointer {
        Token _token;
        string _identifier;
        uint256 _value;
    }
    
    mapping(string => Token) public fromLiteral;
    mapping(uint256 => Token) public fromType;
    mapping(string => Token) public fromName;

    struct Memory {
        bool _exists;
        string _identifier;
        uint256 _value;
    }

    constructor() {
        twm("SOJS_EOF","eof", 0);
        twm("SOJS_IDENTIFIER","id", 256);
        twm("SOJS_VAR","var", 289);
        twm("SOJS_ASSIGN","=", 260);
        twm("SOJS_INTEGER","", 257);
        twm("SOJS_SEMICOLON",";", 59);
        twm("SOJS_SUMOPERATOR","+", 43);
        twm("SOJS_RETURN","return", 45);
    }

    function script(string calldata code) public view returns (Memory[] memory){
        return run(lex(code));
    }

    function lex (string calldata code) public view returns (Pointer[] memory){
        uint256 dataPos = 0; //cursor 
        string memory tkStr = "";
        uint dataEnd = bytes(code).length;
        uint256 iterations = 0;
        Pointer[] memory stack = new Pointer[](1000);  //Set the max stack size
        uint256 stackIndex = 0;

        while (dataPos < dataEnd) {
            iterations++;
            bytes1 currChar = getCharAtIndex(code, dataPos);

            //  Ignore if chat is whitespace 
            if(isWhiteSpace(currChar)) {
                dataPos++;
                continue;
            }

            //if it is alphabetic, it might be a reserved word or an identifier
            if(isAlpha(currChar)) {
                while(isAlpha(currChar) || isNumeric(currChar)) {
                    currChar = getCharAtIndex(code, dataPos);
                    if (isWhiteSpace(currChar) || isBreaker(currChar)) break;
                    tkStr = string.concat(tkStr, bytes1ToString(currChar));
                    dataPos++;
                }
                
                // TODO: Check for reserved words

                 Pointer memory r;

                if(fromLiteral[tkStr]._exists) {
                    // is a reserved word
                     r = Pointer(fromLiteral[tkStr], "", 0);
                } else {
                    //is an identifier
                     r = Pointer(fromLiteral["id"], tkStr, 0);
                }

                stack[stackIndex] = r;
                stackIndex++;

            // if it is a number, it might be a Number or a Float
            } else if (isNumeric(currChar)) {
                while (isNumeric(currChar)) {
                    currChar = getCharAtIndex(code, dataPos);
                    if (isWhiteSpace(currChar) || isBreaker(currChar)) break;
                    tkStr = string.concat(tkStr, bytes1ToString(currChar));
                    dataPos++;
                }

                Pointer memory r = Pointer(fromName["SOJS_INTEGER"], tkStr, stringToUint(tkStr));
                stack[stackIndex] = r;
                stackIndex++;

            } else {
                Pointer memory r;
                if(fromLiteral[bytes1ToString(currChar)]._exists) {
                    r = Pointer(fromLiteral[bytes1ToString(currChar)], "", 0);
                    stack[stackIndex] = r;
                    stackIndex++;
                }

                dataPos++;
            } 
            tkStr = "";
        }

        stack[stackIndex] = Pointer(fromName["SOJS_EOF"], "", 0);
        stackIndex++;

        return stackSlice(stack, stackIndex);
    }


    function run(Pointer[] memory stack) public view returns (Memory[] memory){
        uint256 stackIndex = 0;
        uint256 stackLength = stack.length;
        Memory[] memory memorySpace = new Memory[](5);
        uint256 memorySpaceFreeIndex = 1;
        uint256 i = 0;

        while (stackIndex < stackLength) {
            if(currentStackTokenIs(stack[stackIndex], "SOJS_EOF")){
                break;
            }

            if(currentStackTokenIs(stack[stackIndex], "SOJS_VAR")) {
                Pointer memory nextStackItem = stack[stackIndex + 1];
                require( currentStackTokenIs(nextStackItem, "SOJS_IDENTIFIER"), "Identifier expected.");  //mandatory identifier
                
                Memory memory currentVar = findInMemorySpace(memorySpace, nextStackItem._identifier);
                

                require( currentVar._exists == false, string.concat("Reasigning variable:", nextStackItem._identifier));  //identifier not defined
                memorySpace[memorySpaceFreeIndex] = Memory (
                    true,
                    nextStackItem._identifier,
                    0
                ); 
                memorySpaceFreeIndex++;
            }

            if(currentStackTokenIs(stack[stackIndex], "SOJS_ASSIGN")) {
                Pointer memory leftHand = stack[stackIndex - 1];
                Pointer memory rightHand = stack[stackIndex + 1];
                require( currentStackTokenIs(leftHand, "SOJS_IDENTIFIER"), "Identifier expected.");  //mandatory identifier
                require( currentStackTokenIs(rightHand, "SOJS_INTEGER"), "Integer expected.");  //mandatory number
                uint256 memoryLocation = findMemorySpaceIndex(memorySpace, leftHand._identifier, 0);

                require( memoryLocation != 0 , "Variable not defined");

                memorySpace[memoryLocation] = Memory (
                    true,
                    leftHand._identifier,
                    rightHand._value
                );
                
                uint256 rightPadding = 0;
                while (true) {
                    uint256 paddedPointer = stackIndex + rightPadding;
                    if (
                        currentStackTokenIs(stack[paddedPointer], "SOJS_SEMICOLON") || 
                        currentStackTokenIs(stack[paddedPointer], "SOJS_RETURN") ||
                        currentStackTokenIs(stack[paddedPointer], "SOJS_VAR") ||
                        currentStackTokenIs(stack[paddedPointer], "SOJS_EOF") 
                    ) {
                        break;
                    }   
                    uint256 padding = stackIndex + rightPadding;
                    if(currentStackTokenIs(stack[padding], "SOJS_SUMOPERATOR")) {
                        stackIndex++;
                        require( currentStackTokenIs(stack[padding + 1], "SOJS_INTEGER"), "Integer expected."); 
                        uint256 result = memorySpace[memoryLocation]._value + stack[padding +1]._value;
                        memorySpace[memoryLocation] = Memory (
                            true,
                            leftHand._identifier,
                            result
                        );
                        
                    }
                    rightPadding++;
    
                }
                stackIndex++;
                
            }
            stackIndex++;
            i++;
        }

        return memorySlice(memorySpace, memorySpaceFreeIndex);

    }

    function currentStackTokenIs(Pointer memory pointer, string memory name) public pure returns (bool) {
        return comparteStrings(pointer._token._name, name);
    }

    function findInMemorySpace(Memory[] memory memorySpace, string memory identifier) public pure returns (Memory memory) {
        uint256 memorySpaceIndex = 1;
        uint256 memorySpaceLength = memorySpace.length;

        while (memorySpaceIndex < memorySpaceLength) {
            if(comparteStrings(memorySpace[memorySpaceIndex]._identifier, identifier)) {
                return memorySpace[memorySpaceIndex];
            }
            memorySpaceIndex++;
        }

        return Memory (
            false,
            "",
            0
        );
    }

    function findMemorySpaceIndex(Memory[] memory memorySpace, string memory identifier, uint256 defaultIndex) public pure returns (uint256) {
        uint256 memorySpaceIndex = 1;
        uint256 memorySpaceLength = memorySpace.length;

        while (memorySpaceIndex < memorySpaceLength) {
            if(comparteStrings(memorySpace[memorySpaceIndex]._identifier, identifier)) {
                return memorySpaceIndex;
            }
            memorySpaceIndex++;
        }

        return defaultIndex;
    }

    function comparteStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function isAlpha(bytes1 _char) public pure returns (bool) {
        return (_char >= bytes1("A") && _char <= bytes1("Z")) || (_char >= bytes1("a") && _char <= bytes1("z"));
    }

    function isNumeric(bytes1 _char) public pure returns (bool) {
        return _char >= bytes1("0") && _char <= bytes1("9");
    }


    function isWhiteSpace(bytes1 _char) public pure returns (bool) {
        return _char ==  bytes1(" ") || _char ==  bytes1("\n") || _char ==  bytes1("\t");
    }

    function isBreaker(bytes1 _char) public pure returns (bool) {
        return _char ==  bytes1(";") || isWhiteSpace(_char);
    }

    function getSubstring( string calldata input, uint start, uint end) internal pure returns (string memory) {
        bytes calldata strBytes = bytes(input);
        return string(strBytes[start:end]);
    }

    function getCharAtIndex(string memory input, uint256 index) internal pure returns (bytes1) {
        bytes memory strBytes = bytes(input);
        if(index < strBytes.length){
            return strBytes[index];
        } else {
            return 0x00; // TODO: Get EOF straight
        }
    }

    function bytes1ToString(bytes1 data) internal pure returns (string memory) {
        bytes memory byteArray = new bytes(1);
        byteArray[0] = data;
        
        return string(byteArray);
    }

    function stringToUint(string memory s) public pure returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }


    function stringToBytes32(string memory input) public pure returns (bytes32) {
        require(bytes(input).length <= 32, "String too long");

        bytes32 result;
        assembly {
            result := mload(add(input, 32))
        }

        return result;
    }

    function bytes32toInteger(bytes32 _bytes32) public pure returns (uint256) {
        return uint256(_bytes32);
    }

    function twm(string memory _name, string memory _literal, uint _type) public {
        Token memory n = Token(_name, _literal, _type, true);
        fromLiteral[_literal] = n;
        fromType[_type] = n;
        fromName[_name] = n;
    }

    function stackSlice(Pointer[] memory arr, uint256 n) public pure returns (Pointer[] memory) {
        require(n <= arr.length, "N exceeds array length");

        Pointer[] memory result = new Pointer[](n);
        for (uint256 i = 0; i < n; i++) {
            result[i] = arr[i];
        }

        return result;
    }

    function memorySlice(Memory[] memory arr, uint256 n) public pure returns (Memory[] memory) {
        require(n <= arr.length, "N exceeds array length");

        Memory[] memory result = new Memory[](n);
        for (uint256 i = 0; i < n; i++) {
            result[i] = arr[i];
        }

        return result;
    }
}
