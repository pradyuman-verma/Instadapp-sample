//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "./interface/Index.sol";
import "./interface/Implementation.sol";

contract dsa_sample {
    InstaIndex dsa = InstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);

    receive() external payable {}

    function accountX(
        address _owner,
        uint256 accountVersion,
        address _origin
    ) public returns (address) {
        //1. Creating DSA
        // _owner - address of the owner
        // accountVersion - 2
        // origin - address(0)
        address account = dsa.build(_owner, accountVersion, _origin);
        return account;
    }

    function transferEth(address _account, uint256 _amount) public {
        //2. Transfering ETH to DSA
        (bool sent, ) = _account.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function deposit(
        address payable _account,
        string[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) public {
        //3. Depositing Ether to compound
        // _target = ["0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"]
        // _origin = address(0)
        // _datas = encode of spell
        require(_targets.length > 0, "Please provide a target");
        InstaImplementationM1(_account).cast(_targets, _datas, _origin);
    }

    function Borrow(
        address payable _account,
        string[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) public {
        //4. Borrow Dai from compound
        require(_targets.length > 0, "Please provide a target");
        InstaImplementationM1(_account).cast(_targets, _datas, _origin);
    }

    function Withdraw() public {}
}
