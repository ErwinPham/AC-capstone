//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/*
 *  @title: AC Capstone - Upgradeable Airdrop Project
 *  @author Huy Pham
 *  @notice This contract implements an upgradeable Merkle Airdrop mechanism using OpenZeppelin’s UUPS proxy standard.
 *  @dev
 *  - The contract is upgradeable using the UUPS pattern.
 *  - Initialization replaces the constructor to set up the contract.
 *  - Access control and ownership are managed through `OwnableUpgradeable` and `AccessControlUpgradeable`.
 *  - It uses a Merkle proof system to securely verify eligible claimants without storing all addresses on-chain.
 *
 * Main Features:
 *  - Claim tokens by providing a valid Merkle proof.
 *  - Prevents double-claiming using internal state tracking.
 *  - Supports upgradeability via `UUPSUpgradeable`.
 *  - Only the contract owner can update implementation or perform administrative actions.
 *
 * Security Notes:
 *  - Always call the `initialize()` function after deployment through the proxy.
 *  - Do not deploy or interact directly with the implementation contract.
 */

contract MerkleAirdrop is
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

    /**
     * Event
     */
    event Claimed(address account, uint256 amount);
    event MerkleRootUpdated(bytes32 root);
    event AirdropTokenUpdated(address token);

    /**
     * Variables
     */
    bytes32 private constant MESSAGE_TYPEHASHED = keccak256("Airdropclaim(address account, uint256 amount)");
    bytes32 private constant CAN_UPGRADE_ROLE = keccak256("CAN_UPGRADE_ROLE");
    bytes32 private merkleRoot;
    IERC20 private airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    struct Airdropclaim {
        address account;
        uint256 amount;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                        INITIALIZATION                                                      //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function initialize(bytes32 _merkleRoot, address _airdropToken) public initializer {
        __EIP712_init("MerkleAirdrop", "1");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(CAN_UPGRADE_ROLE, _msgSender());

        merkleRoot = _merkleRoot;
        airdropToken = IERC20(_airdropToken);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                               PUBLIC AND EXTERNAL FUNCTIONS                                                //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function grantCanUpgradeRole(address _account) external onlyOwner {
        _grantRole(CAN_UPGRADE_ROLE, _account);
    }

    /*
    * @notice This function will be called by user who was legit in Merkle tree.
    * @param account: The address of user.
    * @param amount: The amount of to claim.
    * @param merkleProof: The Proof was used to prove that the address of user that was legit.
    */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claimed(account, amount);
        airdropToken.safeTransfer(account, amount);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                      GETTER FUNCTIONS                                                      //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function getMerkleRoot() external view returns (bytes32) {
        return merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return airdropToken;
    }

    function getClaimedCheck(address user) external view returns (bool) {
        return s_hasClaimed[user];
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                      UPGRADE FUNCTIONS                                                     //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(CAN_UPGRADE_ROLE) {}

    // reserve storage for future upgrades
    uint256[45] private __gap;
}
