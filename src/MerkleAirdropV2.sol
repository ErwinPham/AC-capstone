//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
// import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
//import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract MerkleAirdropV2 is
    Initializable,
    EIP712Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    using SafeERC20 for IERC20;
    /**
     * Error
     */

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    bytes32 private constant MESSAGE_TYPEHASHED = keccak256("Airdropclaim(address account, uint256 amount)");

    struct Airdropclaim {
        address account;
        uint256 amount;
    }

    /**
     * Event
     */
    event Claimed(address account, uint256 amount);
    event MerkleRootUpdated(bytes32 root);
    event AirdropTokenUpdated(address token);
    event AirdropPaused(address owner);
    event AirdropUnpaused(address owner);

    bytes32 private merkleRoot;
    IERC20 private airdropToken;
    address[] claimers;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant CAN_UPGRADE_ROLE = keccak256("CAN_UPGRADE_ROLE");

    // constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
    //     i_merkleRoot = merkleRoot;
    //     i_airdropToken = airdropToken;
    // }
    constructor() {
        _disableInitializers();
    }

    function grantCanUpgradeRole(address _account) external onlyOwner {
        _grantRole(CAN_UPGRADE_ROLE, _account);
    }

    function initialize(bytes32 _merkleRoot, address _airdropToken) public initializer {
        __EIP712_init("MerkleAirdrop", "1");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        merkleRoot = _merkleRoot;
        airdropToken = IERC20(_airdropToken);
    }

    function setMerkleRoot(bytes32 _newRoot) external onlyOwner {
        merkleRoot = _newRoot;
        emit MerkleRootUpdated(_newRoot);
    }

    function setAirdropToken(address _token) external onlyOwner {
        airdropToken = IERC20(_token);
        emit AirdropTokenUpdated(_token);
    }

    // function pause() external onlyOwner {
    //     _pause();
    //     emit AirdropPaused(msg.sender);
    // }

    // function unpause() external onlyOwner {
    //     _unpause();
    //     emit AirdropUnpaused(msg.sender);
    // }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
        //     revert MerkleAirdrop__InvalidSignature();
        // }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claimed(account, amount);
        airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(abi.encode(MESSAGE_TYPEHASHED, Airdropclaim({account: account, amount: amount})))
            );
    }

    function getMerkleRoot() external view returns (bytes32) {
        return merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return airdropToken;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(CAN_UPGRADE_ROLE) {}

    // reserve storage for future upgrades
    uint256[30] private __gap;

    // function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
    //     internal
    //     pure
    //     returns (bool)
    // {
    //     (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
    //     return actualSigner == account;
    // }
}
