// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
//import {MerkleAirdropV2} from "../src/MerkleAirdropV2.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

library Deployed {
    function airdrop() external returns (address) {
        if (block.chainid == 11155111) {
            return 0xaF9d097708206104bD5f9Cbad49B850bCb844A64; //proxy address
        }
    }

    function token() external returns (address) {
        if (block.chainid == 11155111) {
            return 0x67ED9707d1E1386b473988b1E9e87FB6ea46E45B;
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

