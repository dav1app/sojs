require('dotenv').config();
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import deploy from "./scripts/deploy";

const MUMBAI_URL = process.env.MUMBAI_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;

if(!MUMBAI_URL || !PRIVATE_KEY || !POLYGONSCAN_API_KEY) {
	throw new Error("Please set your MUMBAI_URL, PRIVATE_KEY and POLYGONSCAN_API_KEY in a .env file");
}

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  defaultNetwork: "testnet",
	networks: {
		hardhat: {},
		testnet: {
			url: MUMBAI_URL,
			accounts: [PRIVATE_KEY],
      gas: 2100000,
      gasPrice: 8000000000,
		},
	}
}
  
export default config;
