const { assert } = require("chai");
const { network, ethers, getNamedAccounts } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");

developmentChains.includes(network.name)
  ? describe.skip
  : describe("FundMe Staging Tests", async function () {
      let deployer;
      let fundMe;
      const sendValue = ethers.utils.parseEther("0.07");
      beforeEach(async () => {
        deployer = (await getNamedAccounts()).deployer;
        fundMe = await ethers.getContract("FundMe", deployer);
      });

      it("allows people to fund and withdraw", async function () {
        console.log("Funding...");
        await fundMe.fund({ value: sendValue });
        console.log("Funded!");
        console.log("Withdrawing...");
        await fundMe.withdraw();
        console.log("Withdrawn!");

        const endingFundMeBalance = await fundMe.provider.getBalance(
          fundMe.address
        );
        assert.equal(endingFundMeBalance.toString(), "0");
      });
    });
