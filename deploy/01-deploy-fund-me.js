const { network } = require("hardhat");
const {
  networkConfig,
  developmentChains
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  const isDevChain = developmentChains.includes(network.name);

  let ethUsdPriceFeedAddress;
  if (isDevChain) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }

  log(`Deploying contract to ${network.name}...`);
  const args = [ethUsdPriceFeedAddress];
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1
  });

  if (!isDevChain && process.env.ETHERSCAN_API_KEY) {
    log("Verifying...");
    await verify(fundMe.address, args);
  }
  log("------------------------------------------");
};

module.exports.tags = ["all", "fundme"];
