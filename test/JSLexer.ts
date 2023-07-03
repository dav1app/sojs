import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("JSLexer", function () {

  async function fixture() {
    const JSLexer = await ethers.getContractFactory("JSLexer");
    const contract = await JSLexer.deploy();

    return { contract };
  }

  describe("Lexer", function () {
    it("Should be able to parse JS code", async function () {
      const { contract } = await loadFixture(fixture);
      console.log(await contract.tokenize(`
        const a = 1 
        const b = 2 

        function sum(a,b){
          return a+b
        }      
      `))
    });
  });
});
