import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("SOJS", function () {
  async function fixture() {
    const Script = await ethers.getContractFactory("SOJSLexer");
    const contract = await Script.deploy({ gasLimit: '20000000' })

    return { contract };
  }

  describe("SOJS", function () {
    it("Should be able to assign variables", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4; 
        var b = 2;
        var c = 2132312
      `);

      expect(dump).to.include.deep.members([
        [ false, '', 0n ],
        [ true, 'a', 4n ],
        [ true, 'b', 2n ],
        [ true, 'c', 2132312n ]
      ]);

    }); 

     it("Should be able to reassign variables", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4; 
        a = 8;
      `);

      expect(dump).to.include.deep.members([
        [ false, '', 0n ],
        [ true, 'a', 8n ],
      ]);

    }); 

    it("Should be able to declare and assign variables, and reassign them", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4; 
        var b 
        var c = 2132312
        a = 8;
        b = 6;
        c = 1;
      `);

      expect(dump).to.include.deep.members([
        [ false, '', 0n ],
        [ true, 'a', 8n ],
        [ true, 'b', 6n ],
        [ true, 'c', 1n ]
      ]);
    })

    it("Should be able to not use ;", async function () {

      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4
        var b = 2
        var c = 2132312
      `);

      expect(dump).to.include.deep.members([
        [ false, '', 0n ],
        [ true, 'a', 4n ],
        [ true, 'b', 2n ],
        [ true, 'c', 2132312n ]
      ]);
    })

    it("Should be able to declare and assign to expression without;", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4 + 2
      `);

      expect(dump).to.include.deep.members([
        [ false, '', 0n ],
        [ true, 'a', 6n ],
      ]);
    })


    it("Should be able to declare and assign to expression", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4 + 2; 
      `);

      expect(dump).to.include.deep.members([
        [ false, '', 0n ],
        [ true, 'a', 6n ],
      ]);
    })


    it("Should be able to declare and assign to expression with more than 3 operations", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4 + 2 + 6; 
        var b = 6 + 4 + 2
        var c = 6 + 4 + 2 + 1
        var d
        d = 6 + 4 + 2 + 1;
      `);

      expect(dump).to.deep.equal([
        [ false, '', 0n ],
        [ true, 'a', 12n ],
        [ true, 'b', 12n ],
        [ true, 'c', 13n ],
        [ true, 'd', 13n ],
      ]);
    })

    it("Should be able to declare and assign to expression with more than 3 operations", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 4  
        var b = 6
        var c = a + b
      `);

      expect(dump).to.deep.equal([
        [ false, '', 0n ],
        [ true, 'a', 4n ],
        [ true, 'b', 6n ],
        [ true, 'c', 10n ],
      ]);
    })

    it("Should be able to suport multiple operators and identifiers", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 8
        a = 4  
        var b = 6 + 2;
        var c = a + b + 6
      `);

      expect(dump).to.deep.equal([
        [ false, '', 0n ],
        [ true, 'a', 4n ],
        [ true, 'b', 8n ],
        [ true, 'c', 18n ],
      ]);
    })

    it("Should be able to suport mixed opeations and identifiers", async function () {
      const { contract } = await loadFixture(fixture);
      const dump = await contract.script(`
        var a = 8
        a = 10  
        var b = 6 ;
        var c = a - b - 1 + 1
      `);

      expect(dump).to.deep.equal([
        [ false, '', 0n ],
        [ true, 'a', 10n ],
        [ true, 'b', 6n ],
        [ true, 'c', 4n ],
      ]);
    })

    it("Should throw EOF", async function () {
      const { contract } = await loadFixture(fixture);

      await expect(contract.script(`
        var a = 
      `)).to.be.revertedWith("Uncaught SyntaxError: Unexpected token 'eof'");
    })

    it("Should throw Unexpected VAR", async function () {
      const { contract } = await loadFixture(fixture);

      await expect(contract.script(`
        var a = var = b
      `)).to.be.revertedWith("Uncaught SyntaxError: Unexpected token 'var'");
    })

    it("Should throw Unexpected semicolon", async function () {
      const { contract } = await loadFixture(fixture);

      await expect(contract.script(`
        var a = ;
      `)).to.be.revertedWith("Uncaught SyntaxError: Unexpected token ';'");
    })

    it("Should throw missing declaration", async function () {
      const { contract } = await loadFixture(fixture);

      await expect(contract.script(`
        a + 1;
      `)).to.be.revertedWith("Uncaught ReferenceError: 'a' is not defined");
    })
  })

  describe("Lexer Only", function () {
   //TODO: create lexer tests
  })
})