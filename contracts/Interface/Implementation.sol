// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

interface Account {
    function cast(
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32);
}
