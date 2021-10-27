//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {InstaIndex} from "./interface/Index.sol";
import {Account} from "./interface/Implementation.sol";

/*
 * @author: pradyuman-verma
 * @title: DSA sample contract implementing dsa-connect functionality
 **/
contract dsa_sample {
    address instaIndex = 0x2971AdFa57b20E5a416aE5a708A8655A9c74f723;
    address daiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    InstaIndex dsa = InstaIndex(instaIndex);
    IERC20 dai = IERC20(daiAddr);

    receive() external payable {}

    /*
     *  @param: {accountVersion} Version of dsa-account to create.
     *  @dev : User can create a dsa-account
     *  @return : returns address of dsa-account
     **/
    function accountX(uint256 accountVersion) public returns (address) {
        // 1. Creating DSA
        // accountVersion - 2
        // origin - address(0)
        address account = dsa.build(address(this), accountVersion, address(0));
        return account;
    }

    /*
     *  @param: {accountVersion} Version of dsa-account to create.
     *  @dev : transfer Eth from user account to its dsa-account
     **/
    function transferEth(uint256 accountVersion) public payable {
        // 1. creating account (wallet)
        address account = dsa.build(address(this), accountVersion, address(0));
        // console.log(_owner.balance);
        // console.log(account.balance);
        // 2. Transfering ETH to DSA
        (bool sent, ) = account.call{value: msg.value}("");
        // console.log(account.balance);
        require(sent, "Failed to send Ether");
    }

    /*
     *  @param: {accountVersion} Version of dsa-account to create.
     *  @param: {_targets} string array mentioning connectors, encoded data.
     *  @param: {_datas} encoded data containing function abi and params.
     *  @dev : deposit Eth to compound using DSA-account
     **/
    function deposit(
        uint256 accountVersion,
        string[] calldata _targets,
        bytes[] calldata _datas
    ) public payable {
        // 1. creating account (wallet)
        address account = dsa.build(address(this), accountVersion, address(0));
        // 2. transfering ETH to dsa-wallet
        (bool sent, ) = account.call{value: msg.value}("");
        // console.log(account.balance);
        require(sent, "Failed to send Ether");
        // 3. Depositing Ether to compound
        // _target = ["COMPOUND-A"]
        // _origin = address(0)
        // _datas = web3.eth.abi.encodeFunctionCall(JSON_ABI, PARAMS)
        require(_targets.length > 0, "Please provide a target");
        Account(payable(account)).cast(_targets, _datas, address(0));
    }

    /*
     *  @param: {accountVersion} Version of dsa-account to create.
     *  @param: {_targets} string array mentioning connectors, encoded data.
     *  @param: {_datas} encoded data containing function abi and params.
     *  @dev : borrow DAI from compound by putting ETH as collateral
     **/
    function Borrow(
        uint256 accountVersion,
        string[] calldata _targets,
        bytes[] calldata _datas0,
        bytes[] calldata _datas
    ) public payable {
        // 1. creating account (wallet)
        address account = dsa.build(address(this), accountVersion, address(0));
        // 2. transfering ETH to dsa-wallet
        (bool sent, ) = account.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        //3. Depositing Ether to compound
        require(_targets.length > 0, "Please provide a target");
        Account(payable(account)).cast(_targets, _datas0, address(0));
        //4. Borrow Dai from compound
        Account(payable(account)).cast(_targets, _datas, address(0));
    }

    /*
     *  @param: {accountVersion} Version of dsa-account to create.
     *  @param: {_targets} string array mentioning connectors, encoded data.
     *  @param: {_datas} encoded data containing function abi and params.
     *  @dev : withdraw DAI from DSA-account to your own account
     **/
    function Withdraw(
        uint256 accountVersion,
        string[] calldata _targets0,
        string[] calldata _targets,
        bytes[] calldata _datas0,
        bytes[] calldata _datas1,
        bytes[] calldata _datas
    ) public payable {
        // 1. creating account (wallet)
        address account = dsa.build(address(this), accountVersion, address(0));
        // 2. transfering ETH to dsa-wallet
        (bool sent, ) = account.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        //3. Depositing Ether to compound
        require(_targets.length > 0, "Please provide a target");
        Account(payable(account)).cast(_targets0, _datas0, address(0));
        //4. Borrow Dai from compound
        Account(payable(account)).cast(_targets0, _datas1, address(0));
        // 5. transfering DAI to contract
        // console.log(dai.balanceOf(account));
        // console.log(dai.balanceOf(msg.sender));
        Account(payable(account)).cast(_targets, _datas, address(0));
        // console.log(dai.balanceOf(account));
        // console.log(dai.balanceOf(msg.sender));
    }
}
