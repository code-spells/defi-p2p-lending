//import {ethers, upgrades} from "hardhat";
//const hre = require("hardhat");
require("@nomicfoundation/hardhat-ethers");
async function main() {
  const tokenSupply = 100000;
  const decimal = 0;
  const tokenName  = "LaserToken";
  const symbol = "LT";

  const LaserToken = await ethers.getContractFactory("LToken");
  const lasertoken =  await LaserToken.deploy(tokenName,symbol,tokenSupply,decimal);

  await lasertoken.deployed();
  console.log("laser token deployment successful at : "+ lasertoken.address);

  const max_flagging = 7;
  const Governance = await ethers.getContractFactory("Governance");
  const governance = await upgrades.deployProxy(Governance,[max_flagging]);

  //await governance.deployed();
  console.log("upgradeable governance contract deployment successful at : "+ governance.address );

  const DefiPlatform = await ethers.getContractFactory("DefiPlatform");
	const defiplatform = await DefiPlatform.deploy(governance.address);
	
	//await defiplatform.deployed();
	
	console.log("DefiPlatform deployed to :", defiplatform.address);
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
