// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.0;
import "./StringOperations.sol";

contract JSLexer {
    StringOperations strop;

    enum TokenType {
        Undefined,
        Identifier,
        Keyword,
        Operator,
        Delimiter,
        Literal
    }

    enum CharType {
        Letter,
        Number,
        Symbol,
        Break,
        Other
    }
    
    struct Token {
        TokenType tokenType;
        string value;
    }

    Token[] public availableTokens;
    uint256 public maxTokenSize;

    string[] private identifiers;
    string[] private keywords;
    string[] private operators;
    string[] private delimiters;
    string[] private specialDelimiters;
    string[] private literalDelimiters;
    
    constructor() {
        strop = new StringOperations();
        initializeTokens();
    }

    function initializeTokens() private {
        maxTokenSize = 10;

        availableTokens.push(Token(TokenType.Operator, "+"));
        availableTokens.push(Token(TokenType.Operator, "-"));
        availableTokens.push(Token(TokenType.Operator, "*"));
        availableTokens.push(Token(TokenType.Operator, "/"));
        availableTokens.push(Token(TokenType.Operator, "%"));
        availableTokens.push(Token(TokenType.Operator, "==="));
        availableTokens.push(Token(TokenType.Operator, "=="));
        availableTokens.push(Token(TokenType.Operator, "="));
        availableTokens.push(Token(TokenType.Operator, "!"));
        availableTokens.push(Token(TokenType.Operator, "!="));
        availableTokens.push(Token(TokenType.Operator, "!=="));
        availableTokens.push(Token(TokenType.Operator, ">"));
        availableTokens.push(Token(TokenType.Operator, "<"));
        availableTokens.push(Token(TokenType.Operator, ">="));
        availableTokens.push(Token(TokenType.Operator, "<="));
        availableTokens.push(Token(TokenType.Operator, "&&"));
        availableTokens.push(Token(TokenType.Operator, "||"));
        availableTokens.push(Token(TokenType.Operator, "++"));
        availableTokens.push(Token(TokenType.Operator, "--"));
        availableTokens.push(Token(TokenType.Operator, "+="));
        availableTokens.push(Token(TokenType.Operator, "-="));
        availableTokens.push(Token(TokenType.Operator, "*="));
        availableTokens.push(Token(TokenType.Operator, "/="));
        availableTokens.push(Token(TokenType.Operator, "%="));
        availableTokens.push(Token(TokenType.Operator, "<<"));
        availableTokens.push(Token(TokenType.Operator, ">>"));
        availableTokens.push(Token(TokenType.Operator, ">>>"));

        availableTokens.push(Token(TokenType.Delimiter, "{"));
        availableTokens.push(Token(TokenType.Delimiter, "}"));
        availableTokens.push(Token(TokenType.Delimiter, "("));
        availableTokens.push(Token(TokenType.Delimiter, ")"));
        availableTokens.push(Token(TokenType.Delimiter, ";"));
        availableTokens.push(Token(TokenType.Delimiter, ","));
        availableTokens.push(Token(TokenType.Delimiter, "."));

        availableTokens.push(Token(TokenType.Keyword, "var"));
        availableTokens.push(Token(TokenType.Keyword, "let"));
        availableTokens.push(Token(TokenType.Keyword, "const"));
        availableTokens.push(Token(TokenType.Keyword, "function"));
        availableTokens.push(Token(TokenType.Keyword, "if"));
        availableTokens.push(Token(TokenType.Keyword, "else"));
        availableTokens.push(Token(TokenType.Keyword, "for"));
        availableTokens.push(Token(TokenType.Keyword, "while"));
        availableTokens.push(Token(TokenType.Keyword, "switch"));
        availableTokens.push(Token(TokenType.Keyword, "case"));
        availableTokens.push(Token(TokenType.Keyword, "return"));
        availableTokens.push(Token(TokenType.Keyword, "break"));
        availableTokens.push(Token(TokenType.Keyword, "continue"));
        availableTokens.push(Token(TokenType.Keyword, "null"));
        availableTokens.push(Token(TokenType.Keyword, "undefined"));
        availableTokens.push(Token(TokenType.Keyword, "true"));
        availableTokens.push(Token(TokenType.Keyword, "false"));
        availableTokens.push(Token(TokenType.Keyword, "new"));
        availableTokens.push(Token(TokenType.Keyword, "delete"));
        availableTokens.push(Token(TokenType.Keyword, "typeof"));

        availableTokens.push(Token(TokenType.Literal, "\""));
        availableTokens.push(Token(TokenType.Literal, "'"));
        availableTokens.push(Token(TokenType.Literal, "`"));
    }
    
    
  function tokenize(string memory input) public view returns (Token[] memory) {
      uint256 inputLength = strop.length(input);
      Token[] memory tokens = new Token[](inputLength);
      uint256 tokenCount = 0;
      uint256 currentIndex = 0;

      while (currentIndex < inputLength) {
          CharType currentCharType;
          TokenType currentTokenType;
          
          string memory currentChar = strop.substring(input, currentIndex, currentIndex + 1);

          //get current char type
          currentCharType = getCharType(currentChar);

          // ignore if it is a space
          if(currentCharType == CharType.Break){
            currentIndex++;
            continue;
          }

          // iterate over symbol until it changes its type
          string memory currentToken = "";

          while (currentCharType == getCharType(currentChar)) {
              currentToken = strop.concat(currentToken, currentChar);
              currentIndex++;
              if (currentIndex >= inputLength) {
                  break;
              }
              currentChar = strop.substring(input, currentIndex, currentIndex + 1);
          }

          currentTokenType = getTokenType(currentToken);

          if( currentTokenType == TokenType.Undefined){
            if (tokenCount > 0) {
                if (
                  tokens[tokenCount - 1].tokenType == TokenType.Literal ||
                  tokens[tokenCount - 1].tokenType == TokenType.Identifier ||
                  tokens[tokenCount - 1].tokenType == TokenType.Keyword
                ) {
                    currentTokenType = TokenType.Identifier;
                } else {
                    currentTokenType = TokenType.Literal; 
                }
            }
          }

          // add token  and token type to tokens array
          tokens[tokenCount].tokenType = currentTokenType;
          tokens[tokenCount].value = currentToken;
          tokenCount++;
      }
      
      assembly {
          mstore(tokens, tokenCount)
      }
      
      return tokens;
  }

    function getTokenType(string memory input) public view returns (TokenType){
        for(uint i=0; i<availableTokens.length; i++){
            if(strop.equal(availableTokens[i].value, input)){
                return availableTokens[i].tokenType;
            }
        }
        
        return TokenType.Undefined;
    }

    function getCharType(string memory input) public pure returns (CharType){
        bytes memory inputBytes = bytes(input);
        uint8 charValue = uint8(inputBytes[0]);
        if ((charValue >= 65 && charValue <= 90) || (charValue >= 97 && charValue <= 122)) {
            return CharType.Letter;
        } else if (charValue >= 48 && charValue <= 57) {
            return CharType.Number;
        } else if (charValue == 32 || charValue == 10 || charValue == 13 || charValue == 9) {
            return CharType.Break;
        } else {
            return CharType.Symbol;
        }
    }

}
