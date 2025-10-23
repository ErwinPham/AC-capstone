// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {MerkleAirdropV2} from "../../src/MerkleAirdropV2.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

library Deployed {
    function airdrop() external returns (address) {
        if (block.chainid == 11155111) {
            return 0x32Fa0b80620D3439cA16dA7DBa95dCb73cD64eCD; //proxy address
        }
    }

    function token() external returns (address) {
        if (block.chainid == 11155111) {
            return 0xEeE1A3C2f55cca4178C9D17233Bc484136A48351;
        }
    }
}

contract UpgradeMerkle is Script {
    function run() public {
        vm.startBroadcast();
        Options memory opts;
        opts.referenceContract = "MerkleAirdrop.sol";
        Upgrades.upgradeProxy(Deployed.airdrop(), "MerkleAirdropV2.sol", "", opts);
        vm.stopBroadcast();
    }
}

