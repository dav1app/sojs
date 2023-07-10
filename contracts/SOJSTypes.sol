// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library SOJSTypes {
    uint256 public constant LEX_EOF = 0;
    uint256 public constant LEX_ID = 256;
    uint256 public constant LEX_INT = 257;
    uint256 public constant LEX_FLOAT = 258;
    uint256 public constant LEX_STR = 259;

    // Operators
    uint256 public constant LEX_EQUAL = 260;
    uint256 public constant LEX_TYPEEQUAL = 261;
    uint256 public constant LEX_NEQUAL = 262;
    uint256 public constant LEX_NTYPEEQUAL = 263;
    uint256 public constant LEX_LEQUAL = 264;
    uint256 public constant LEX_LSHIFT = 265;
    uint256 public constant LEX_LSHIFTEQUAL = 266;
    uint256 public constant LEX_GEQUAL = 267;
    uint256 public constant LEX_RSHIFT = 268;
    uint256 public constant LEX_RSHIFTUNSIGNED = 269;
    uint256 public constant LEX_RSHIFTEQUAL = 270;
    uint256 public constant LEX_PLUSEQUAL = 271;
    uint256 public constant LEX_MINUSEQUAL = 272;
    uint256 public constant LEX_PLUSPLUS = 273;
    uint256 public constant LEX_MINUSMINUS = 274;
    uint256 public constant LEX_ANDEQUAL = 275;
    uint256 public constant LEX_ANDAND = 276;
    uint256 public constant LEX_OREQUAL = 277;
    uint256 public constant LEX_OROR = 278;
    uint256 public constant LEX_XOREQUAL = 279;

    // Reserved words
    uint256 public constant LEX_R_LIST_START = 280;
    uint256 public constant LEX_R_IF = 280;
    uint256 public constant LEX_R_ELSE = 281;
    uint256 public constant LEX_R_DO = 282;
    uint256 public constant LEX_R_WHILE = 283;
    uint256 public constant LEX_R_FOR = 284;
    uint256 public constant LEX_R_BREAK = 285;
    uint256 public constant LEX_R_CONTINUE = 286;
    uint256 public constant LEX_R_FUNCTION = 287;
    uint256 public constant LEX_R_RETURN = 288;
    uint256 public constant LEX_R_VAR = 289;
    uint256 public constant LEX_R_TRUE = 290;
    uint256 public constant LEX_R_FALSE = 291;
    uint256 public constant LEX_R_NULL = 292;
    uint256 public constant LEX_R_UNDEFINED = 293;
    uint256 public constant LEX_R_NEW = 294;

    uint256 public constant LEX_R_LIST_END = 294;

    uint256 public constant SCRIPTVAR_UNDEFINED = 0;
    uint256 public constant SCRIPTVAR_FUNCTION = 1;
    uint256 public constant SCRIPTVAR_OBJECT = 2;
    uint256 public constant SCRIPTVAR_ARRAY = 4;
    uint256 public constant SCRIPTVAR_DOUBLE = 8; // floating point double
    uint256 public constant SCRIPTVAR_INTEGER = 16; // integer number
    uint256 public constant SCRIPTVAR_STRING = 32; // string
    uint256 public constant SCRIPTVAR_NULL = 64; // it seems null is its own data type
    uint256 public constant SCRIPTVAR_NATIVE = 128; // to specify this is a native function
    uint256 public constant SCRIPTVAR_NUMERICMASK = SCRIPTVAR_NULL |
                                                SCRIPTVAR_DOUBLE |
                                                SCRIPTVAR_INTEGER;
    uint256 public constant SCRIPTVAR_VARTYPEMASK = SCRIPTVAR_DOUBLE |
                                                SCRIPTVAR_INTEGER |
                                                SCRIPTVAR_STRING |
                                                SCRIPTVAR_FUNCTION |
                                                SCRIPTVAR_OBJECT |
                                                SCRIPTVAR_ARRAY |
                                                SCRIPTVAR_NULL;
    string public constant RETURN_VAR = "return";
    string public constant PROTOTYPE_CLASS = "prototype";
    string public constant TEMP_NAME= "";
    string public constant BLANK_DATA= "";




}