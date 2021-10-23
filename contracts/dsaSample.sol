//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "./interface/Index.sol";

contract dsa_sample {
    InstaIndex dsa = InstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);

    receive() external payable {}

    function accountX(
        address _owner,
        uint256 accountVersion,
        address _origin,
        uint256 _amount,
        address[] calldata _targets,
        bytes[] calldata _datas
    ) public {
        //1. Creating DSA
        address account = dsa.build(_owner, accountVersion, _origin);

        //2. Transfering ETH to DSA
        (bool sent, ) = account.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        //3. Depositing Ether to compound
        // _target = ["0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"]
        // _origin = address(0)

        if (_targets.length > 0)
            AccountInterface(account).cast{value: _amount}(
                _targets,
                _datas,
                _origin
            );

        //4. Borrow Dai from compound
    }
}
