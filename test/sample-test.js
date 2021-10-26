const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DSA-sample", function () {
  let dsaSample, dsaWrapper, owner;
  const ethAddr = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

  const paras = [
    ["ETH-A", `${ethers.utils.parseEther("0.5")}`, "0", "0"],
    ["DAI-A", `${ethers.utils.parseEther("0.5")}`, "0", "0"],
  ];

  const jsonABI = [
    {
      inputs: [
        { internalType: "string", name: "tokenId", type: "string" },
        { internalType: "uint256", name: "amt", type: "uint256" },
        { internalType: "uint256", name: "getId", type: "uint256" },
        { internalType: "uint256", name: "setId", type: "uint256" },
      ],
      name: "deposit",
      outputs: [],
      stateMutability: "payable",
      type: "function",
    },
    {
      inputs: [
        { internalType: "string", name: "tokenId", type: "string" },
        { internalType: "uint256", name: "amt", type: "uint256" },
        { internalType: "uint256", name: "getId", type: "uint256" },
        { internalType: "uint256", name: "setId", type: "uint256" },
      ],
      name: "borrow",
      outputs: [],
      stateMutability: "payable",
      type: "function",
    },
    {
      inputs: [
        { internalType: "string", name: "tokenId", type: "string" },
        { internalType: "uint256", name: "amt", type: "uint256" },
        { internalType: "uint256", name: "getId", type: "uint256" },
        { internalType: "uint256", name: "setId", type: "uint256" },
      ],
      name: "withdraw",
      outputs: [],
      stateMutability: "payable",
      type: "function",
    },
  ];

  function set_balance(_address) {
    network.provider.send("hardhat_setBalance", [
      _address,
      ethers.utils.parseEther("10.0").toHexString(),
    ]);
  }

  beforeEach(async () => {
    dsaSample = await ethers.getContractFactory("dsa_sample");
    dsaWrapper = await dsaSample.deploy();
    [owner, add1, add2] = await ethers.getSigners();
    set_balance(owner.address);
    //console.log(owner.address);
    await dsaWrapper.deployed();
  });

  it("Should deploy successfully", async function () {
    console.log("Successfully deployed!");
  });

  it("Should build dsa", async () => {
    const tx = await dsaWrapper.accountX(2);
    //console.log(tx);
  });

  it("should transfer ETH to DSA", async () => {
    const tx = await dsaWrapper.transferEth(2, {
      value: ethers.utils.parseEther("1.0").toHexString(),
    });
    //console.log(tx);
  });

  it("Should deposit eth to compound", async () => {
    const tx = await dsaWrapper.deposit(
      2,
      ["COMPOUND-A"],
      [web3.eth.abi.encodeFunctionCall(jsonABI[0], paras[0])],
      {
        value: ethers.utils.parseEther("1.0").toHexString(),
      }
    );
  });

  it("Should borrow DAI from compound", async () => {
    const tx = await dsaWrapper.Borrow(
      2,
      ["COMPOUND-A"],
      [web3.eth.abi.encodeFunctionCall(jsonABI[0], paras[0])],
      [web3.eth.abi.encodeFunctionCall(jsonABI[1], paras[1])],
      {
        value: ethers.utils.parseEther("1.0").toHexString(),
      }
    );
  });

  it("Should withdraw DAI to contract", async () => {
    const tx = await dsaWrapper.Withdraw(
      2,
      ["COMPOUND-A"],
      [web3.eth.abi.encodeFunctionCall(jsonABI[0], paras[0])],
      [web3.eth.abi.encodeFunctionCall(jsonABI[1], paras[1])],
      {
        value: ethers.utils.parseEther("1.0").toHexString(),
      }
    );
  });
});
