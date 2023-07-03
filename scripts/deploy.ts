import { ethers } from "hardhat";
async function main() {

  const dynamicTypesContract = await ethers.deployContract("DynamicTypes");

  const deployed = await dynamicTypesContract.waitForDeployment();

  console.log(
    "DynamicTypes deployed to:", deployed.target
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
