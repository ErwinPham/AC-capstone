// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop, IERC20} from "../src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {console} from "forge-std/console.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT = 0x222c3eef4ef2bf020d38a34e9f5b402c296b08680605a9a921533d3befb7a107;
    // 4 users, 25 Bagel tokens each
    uint256 public AMOUNT_TO_TRANSFER = 4 * (25 * 1e18);

    function run() external returns (address, BagelToken) {
        vm.startBroadcast();
        // Deploy Token
        BagelToken bagelToken = new BagelToken();
        // Deploy Proxy (Implementation: MerkleAirdrop.sol)
        address proxy = Upgrades.deployUUPSProxy(
            "MerkleAirdrop.sol", abi.encodeCall(MerkleAirdrop.initialize, (ROOT, address(bagelToken)))
        );
        console.log("Proxy deployed at:", proxy);
        // Grant Role & Transfer Token -> Proxy
        bagelToken.grantMintAndBurnRole(bagelToken.owner());
        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_TRANSFER);
        IERC20(bagelToken).transfer(address(proxy), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return (address(proxy), bagelToken);
    }
}
