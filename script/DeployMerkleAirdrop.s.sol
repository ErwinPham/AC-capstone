// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop, IERC20} from "../src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {console} from "forge-std/console.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT = 0x222c3eef4ef2bf020d38a34e9f5b402c296b08680605a9a921533d3befb7a107;
    // 4 users, 25 Bagel tokens each
    uint256 public AMOUNT_TO_TRANSFER = 4 * (25 * 1e18);

    // Deploy the airdrop contract and bagel token contract
    // function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
    //     vm.startBroadcast();
    //     BagelToken bagelToken = new BagelToken();
    //     MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(bagelToken));
    //     // Send Bagel tokens -> Merkle Air Drop contract
    //     bagelToken.mint(bagelToken.owner(), AMOUNT_TO_TRANSFER);
    //     IERC20(bagelToken).transfer(address(airdrop), AMOUNT_TO_TRANSFER);
    //     vm.stopBroadcast();
    //     return (airdrop, bagelToken);
    // }

    // function run() external returns (MerkleAirdrop, BagelToken) {
    //     return deployMerkleAirdrop();
    // }

    function run() external returns (address, BagelToken) {
        BagelToken bagelToken = new BagelToken();
        MerkleAirdrop airdropV1 = new MerkleAirdrop();
        bytes memory initData = abi.encodeWithSelector(MerkleAirdrop.initialize.selector, ROOT, IERC20(bagelToken));
        ERC1967Proxy proxy = new ERC1967Proxy(address(airdropV1), initData);
        MerkleAirdrop(address(proxy)).initialize(ROOT, address(bagelToken));
        bagelToken.grantMintAndBurnRole(address(proxy));
        return (address(proxy), bagelToken);
    }
}
