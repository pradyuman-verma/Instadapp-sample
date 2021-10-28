const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DSA-sample", function () {
  let dsaSample, dsaWrapper, owner;
  const daiAddr = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const ethAddr = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

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
        { internalType: "address", name: "token", type: "address" },
        { internalType: "uint256", name: "amt", type: "uint256" },
        { internalType: "address payable", name: "to", type: "address" },
        { internalType: "uint256", name: "getId", type: "uint256" },
        { internalType: "uint256", name: "setId", type: "uint256" },
      ],
      name: "withdraw",
      outputs: [
        { internalType: "string", name: "_eventName", type: "string" },
        { internalType: "bytes", name: "_eventParam", type: "bytes" },
      ],
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

  it("Should Deploy successfully", async () => {
    console.log("Deployed Successfully");
  });

  it("Should create DSA, transfer Eth to dsa-wallet, deposit eth to compound and, borrow DAI from compound, withdraw DAI from compound in single transaction", async () => {
    const params = [
      ["ETH-A", `${ethers.utils.parseEther("0.5")}`, "0", "0"],
      ["DAI-A", `${ethers.utils.parseEther("0.5")}`, "0", "0"],
      [daiAddr, `5000000000`, owner.address, "0", "0"],
    ];

    const [deposit_calldata, borrow_calldata, withdraw_calldata] = [
      web3.eth.abi.encodeFunctionCall(jsonABI[0], params[0]),
      web3.eth.abi.encodeFunctionCall(jsonABI[1], params[1]),
      web3.eth.abi.encodeFunctionCall(jsonABI[2], params[2]),
    ];

    const tx = await dsaWrapper.accountX(
      2,
      ["COMPOUND-A", "COMPOUND-A", "BASIC-A"],
      [deposit_calldata, borrow_calldata, withdraw_calldata],
      {
        value: ethers.utils.parseEther("1.0").toHexString(),
      }
    );
  });
});
