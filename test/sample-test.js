const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DSA-sample", function () {
  let dsaSample, dsa, owner;
  const ethAddr = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

  function set_balance(_address) {
    network.provider.send("hardhat_setBalance", [
      _address,
      ethers.utils.parseEther("10.0").toHexString(),
    ]);
  }

  beforeEach(async () => {
    dsaSample = await ethers.getContractFactory("dsa_sample");
    dsa = await dsaSample.deploy();
    [owner, add1, add2] = await ethers.getSigners();
    set_balance(owner.address);
    //console.log(owner.address);
    await dsa.deployed();
  });

  it("Should deploy successfully", async function () {
    console.log("Successfully deployed!");
  });

  it("Should build dsa", async () => {
    const tx = await dsa.accountX(owner.address, 2);
    //console.log(tx);
  });

  it("should transfer ETH to DSA", async () => {
    const tx = await dsa.transferEth(2, {
      value: ethers.utils.parseEther("1.0").toHexString(),
    });
    //console.log(tx);
  });

  it("Should deposit eth to compound", async () => {
    const spell = {
      connector: "compound",
      method: "deposit",
      args: [ethAddr, ethers.utils.parseEther("0.5"), 0, 0],
    };
    const tx = await dsa.deposit(
      2,
      ["COMPOUND-A"],
      web3.eth.abi.encodeFunctionSignature(spell),
      {
        value: ethers.utils.parseEther("1.0").toHexString(),
      }
    );
  });
});
