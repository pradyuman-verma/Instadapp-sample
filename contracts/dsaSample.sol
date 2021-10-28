//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import {InstaIndex} from "./interface/Index.sol";
// import {Account} from "./interface/Implementation.sol";

interface InstaIndex {
    function build(
        address _owner,
        uint256 _accountVersion,
        address _origin
    ) external returns (address _account);
}

interface Account {
    function cast(
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32);
}

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
     *  @param: {_targets} string array mentioning connectors, encoded data.
     *  @param: {_datas} encoded data containing function abi and params.
     *  @dev : create DSA, transfer Eth to dsa-wallet, 
               deposit eth to compound, borrow DAI from compound and, 
               withdraw DAI from compound in single transaction
     **/
    function accountX(
        uint256 accountVersion,
        string[] calldata _targets,
        bytes[] calldata _datas
    ) public payable {
        address account = dsa.build(address(this), accountVersion, address(0));
        require(_targets.length > 0, "Please provide a target");
        require(_datas.length > 0, "Please provide a data");
        Account(payable(account)).cast{value: msg.value}(
            _targets,
            _datas,
            address(0)
        );
    }
}
