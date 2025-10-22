// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {MerkleAirdropV2} from "../src/MerkleAirdropV2.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UpgradeMerkle is Script {
    address mostRecentlyDeployedProxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
    address mostRecentlyDeployedToken = DevOpsTools.get_most_recent_deployment("BagelToken", block.chainid);

    function run() external returns (address) {
        vm.startBroadcast();
        MerkleAirdropV2 airdropV2 = new MerkleAirdropV2();
        vm.stopBroadcast();
        address proxy = upgrade(mostRecentlyDeployedProxy, address(airdropV2));
        return proxy;
    }

    function upgrade(address proxyAddress, address newAirdrop) public returns (address) {
        bytes32 ROOT = 0x222c3eef4ef2bf020d38a34e9f5b402c296b08680605a9a921533d3befb7a107;

        vm.startBroadcast();
        MerkleAirdrop proxy = MerkleAirdrop(payable(proxyAddress));
        bytes memory initData =
            abi.encodeWithSelector(MerkleAirdrop.initialize.selector, ROOT, IERC20(mostRecentlyDeployedToken));
        proxy.upgradeToAndCall(address(newAirdrop), initData);
        vm.stopBroadcast();
        return address(proxy);
    }
}
