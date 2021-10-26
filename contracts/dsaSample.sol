//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

import "hardhat/console.sol";

// main contract is at last - go check there

/**
 * @title InstaIndex
 * @dev Main Contract For DeFi Smart Accounts. This is also a factory contract, Which deploys new Smart Account.
 * Also Registry for DeFi Smart Accounts.
 */

interface AccountInterface {
    function version() external view returns (uint256);

    function enable(address authority) external;

    function cast(
        address[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32[] memory responses);
}

interface ListInterface {
    function init(address _account) external;
}

contract AddressIndex {
    event LogNewMaster(address indexed master);
    event LogUpdateMaster(address indexed master);
    event LogNewCheck(uint256 indexed accountVersion, address indexed check);
    event LogNewAccount(
        address indexed _newAccount,
        address indexed _connectors,
        address indexed _check
    );

    // New Master Address.
    address private newMaster;
    // Master Address.
    address public master;
    // List Registry Address.
    address public list;

    // Connectors Modules(Account Module Version => Connectors Registry Module Address).
    mapping(uint256 => address) public connectors;
    // Check Modules(Account Module Version => Check Module Address).
    mapping(uint256 => address) public check;
    // Account Modules(Account Module Version => Account Module Address).
    mapping(uint256 => address) public account;
    // Version Count of Account Modules.
    uint256 public versionCount;

    /**
     * @dev Throws if the sender not is Master Address.
     */
    modifier isMaster() {
        require(msg.sender == master, "not-master");
        _;
    }

    /**
     * @dev Change the Master Address.
     * @param _newMaster New Master Address.
     */
    function changeMaster(address _newMaster) external isMaster {
        require(_newMaster != master, "already-a-master");
        require(_newMaster != address(0), "not-valid-address");
        require(newMaster != _newMaster, "already-a-new-master");
        newMaster = _newMaster;
        emit LogNewMaster(_newMaster);
    }

    function updateMaster() external {
        require(newMaster != address(0), "not-valid-address");
        require(msg.sender == newMaster, "not-master");
        master = newMaster;
        newMaster = address(0);
        emit LogUpdateMaster(master);
    }

    /**
     * @dev Change the Check Address of a specific Account Module version.
     * @param accountVersion Account Module version.
     * @param _newCheck The New Check Address.
     */
    function changeCheck(uint256 accountVersion, address _newCheck)
        external
        isMaster
    {
        require(_newCheck != check[accountVersion], "already-a-check");
        check[accountVersion] = _newCheck;
        emit LogNewCheck(accountVersion, _newCheck);
    }

    /**
     * @dev Add New Account Module.
     * @param _newAccount The New Account Module Address.
     * @param _connectors Connectors Registry Module Address.
     * @param _check Check Module Address.
     */
    function addNewAccount(
        address _newAccount,
        address _connectors,
        address _check
    ) external isMaster {
        require(_newAccount != address(0), "not-valid-address");
        versionCount++;
        require(
            AccountInterface(_newAccount).version() == versionCount,
            "not-valid-version"
        );
        account[versionCount] = _newAccount;
        if (_connectors != address(0)) connectors[versionCount] = _connectors;
        if (_check != address(0)) check[versionCount] = _check;
        emit LogNewAccount(_newAccount, _connectors, _check);
    }
}

contract CloneFactory is AddressIndex {
    /**
     * @dev Clone a new Account Module.
     * @param version Account Module version to clone.
     */
    function createClone(uint256 version) internal returns (address result) {
        bytes20 targetBytes = bytes20(account[version]);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    /**
     * @dev Check if Account Module is a clone.
     * @param version Account Module version.
     * @param query Account Module Address.
     */
    function isClone(uint256 version, address query)
        external
        view
        returns (bool result)
    {
        bytes20 targetBytes = bytes20(account[version]);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
            )
            mstore(add(clone, 0xa), targetBytes)
            mstore(
                add(clone, 0x1e),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}

contract InstaIndex is CloneFactory {
    event LogAccountCreated(
        address sender,
        address indexed owner,
        address indexed account,
        address indexed origin
    );

    /**
     * @dev Create a new DeFi Smart Account for a user and run cast function in the new Smart Account.
     * @param _owner Owner of the Smart Account.
     * @param accountVersion Account Module version.
     * @param _targets Array of Target to run cast function.
     * @param _datas Array of Data(callData) to run cast function.
     * @param _origin Where Smart Account is created.
     */
    function buildWithCast(
        address _owner,
        uint256 accountVersion,
        address[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (address _account) {
        _account = build(_owner, accountVersion, _origin);
        if (_targets.length > 0)
            AccountInterface(_account).cast{value: msg.value}(
                _targets,
                _datas,
                _origin
            );
    }

    /**
     * @dev Create a new DeFi Smart Account for a user.
     * @param _owner Owner of the Smart Account.
     * @param accountVersion Account Module version.
     * @param _origin Where Smart Account is created.
     */
    function build(
        address _owner,
        uint256 accountVersion,
        address _origin
    ) public returns (address _account) {
        require(
            accountVersion != 0 && accountVersion <= versionCount,
            "not-valid-account"
        );
        _account = createClone(accountVersion);
        ListInterface(list).init(_account);
        AccountInterface(_account).enable(_owner);
        emit LogAccountCreated(msg.sender, _owner, _account, _origin);
    }

    /**
     * @dev Setup Initial things for InstaIndex, after its been deployed and can be only run once.
     * @param _master The Master Address.
     * @param _list The List Address.
     * @param _account The Account Module Address.
     * @param _connectors The Connectors Registry Module Address.
     */
    function setBasics(
        address _master,
        address _list,
        address _account,
        address _connectors
    ) external {
        require(
            master == address(0) &&
                list == address(0) &&
                account[1] == address(0) &&
                connectors[1] == address(0) &&
                versionCount == 0,
            "already-defined"
        );
        master = _master;
        list = _list;
        versionCount++;
        account[versionCount] = _account;
        connectors[versionCount] = _connectors;
    }
}

contract Variables {
    // Auth Module(Address of Auth => bool).
    mapping(address => bool) internal _auth;
    // enable beta mode to access all the beta features.
    bool internal _beta;
}

/**
 * @title InstaAccountV2.
 * @dev DeFi Smart Account Wallet.
 */

interface ConnectorsInterface {
    function isConnectors(string[] calldata connectorNames)
        external
        view
        returns (bool, address[] memory);
}

contract Constants is Variables {
    // InstaIndex Address.
    address internal immutable instaIndex;
    // Connectors Address.
    address public immutable connectorsM1;

    constructor(address _instaIndex, address _connectors) {
        connectorsM1 = _connectors;
        instaIndex = _instaIndex;
    }
}

contract InstaImplementationM1 is Constants {
    constructor(address _instaIndex, address _connectors)
        Constants(_instaIndex, _connectors)
    {}

    function decodeEvent(bytes memory response)
        internal
        pure
        returns (string memory _eventCode, bytes memory _eventParams)
    {
        if (response.length > 0) {
            (_eventCode, _eventParams) = abi.decode(response, (string, bytes));
        }
    }

    event LogCast(
        address indexed origin,
        address indexed sender,
        uint256 value,
        string[] targetsNames,
        address[] targets,
        string[] eventNames,
        bytes[] eventParams
    );

    receive() external payable {}

    /**
     * @dev Delegate the calls to Connector.
     * @param _target Connector address
     * @param _data CallData of function.
     */
    function spell(address _target, bytes memory _data)
        internal
        returns (bytes memory response)
    {
        require(_target != address(0), "target-invalid");
        assembly {
            let succeeded := delegatecall(
                gas(),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize()

            response := mload(0x40)
            mstore(
                0x40,
                add(response, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    /**
     * @dev This is the main function, Where all the different functions are called
     * from Smart Account.
     * @param _targetNames Array of Connector address.
     * @param _datas Array of Calldata.
     */
    function cast(
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    )
        external
        payable
        returns (
            bytes32 // Dummy return to fix instaIndex buildWithCast function
        )
    {
        uint256 _length = _targetNames.length;
        require(
            _auth[msg.sender] || msg.sender == instaIndex,
            "1: permission-denied"
        );
        require(_length != 0, "1: length-invalid");
        require(_length == _datas.length, "1: array-length-invalid");

        string[] memory eventNames = new string[](_length);
        bytes[] memory eventParams = new bytes[](_length);

        (bool isOk, address[] memory _targets) = ConnectorsInterface(
            connectorsM1
        ).isConnectors(_targetNames);

        require(isOk, "1: not-connector");

        for (uint256 i = 0; i < _length; i++) {
            bytes memory response = spell(_targets[i], _datas[i]);
            (eventNames[i], eventParams[i]) = decodeEvent(response);
        }

        emit LogCast(
            _origin,
            msg.sender,
            msg.value,
            _targetNames,
            _targets,
            eventNames,
            eventParams
        );
    }
}

/* Contract starts here */

contract dsa_sample {
    address instaIndex = 0x2971AdFa57b20E5a416aE5a708A8655A9c74f723;
    InstaIndex dsa = InstaIndex(instaIndex);

    receive() external payable {}

    function accountX(uint256 accountVersion) public returns (address) {
        //1. Creating DSA
        // accountVersion - 2
        // origin - address(0)
        address account = dsa.build(address(this), accountVersion, address(0));
        return account;
    }

    function transferEth(uint256 accountVersion) public payable {
        address account = dsa.build(address(this), accountVersion, address(0));
        //console.log(_owner.balance);
        //console.log(account.balance);
        //2. Transfering ETH to DSA
        (bool sent, ) = account.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function deposit(
        uint256 accountVersion,
        string[] calldata _targets,
        bytes[] calldata _datas
    ) public payable {
        address account = dsa.build(address(this), accountVersion, address(0));
        (bool sent, ) = account.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        //3. Depositing Ether to compound
        // _target = ["COMPOUND-A"]
        // _origin = address(0)
        // _datas = encode of spell
        require(_targets.length > 0, "Please provide a target");
        InstaImplementationM1(payable(account)).cast(
            _targets,
            _datas,
            address(0)
        );
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
