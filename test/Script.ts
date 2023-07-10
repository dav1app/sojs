import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("SOJS", function () {

  async function fixture() {
    const Script = await ethers.getContractFactory("Script");
    const contract = await Script.deploy();

    return { contract };
  }

  describe("SOJS", function () {
    it("Should be able to execute something", async function () {
      const { contract } = await loadFixture(fixture);
      expect(contract.main()).to.emit(contract, "returnEvent").withArgs("skabva");
    }); 
  });
});
