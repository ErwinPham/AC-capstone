//SPDX-Licencse-identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop merkleAirdop;
    BagelToken token;

    bytes32 public root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proofOne, proofTwo];
    address user;
    uint256 key;
    address gasPayer;
    uint256 constant spot = 25 * 1e18;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            merkleAirdop = new MerkleAirdrop(root, IERC20(token));
            token.mint(token.owner(), spot * 4);
            token.transfer(address(merkleAirdop), spot * 4);
        }
        (user, key) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testCanClaim() public {
        uint256 startingBalance = IERC20(token).balanceOf(user);
        assertEq(0, startingBalance);

        // user sign the message
        bytes32 digest = merkleAirdop.getMessageHash(user, spot);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);

        // gasPayer calls claim using the signed message
        vm.prank(gasPayer);
        merkleAirdop.claim(user, spot, proof, v, r, s);

        uint256 endiningBalance = IERC20(token).balanceOf(user);

        assertEq(endiningBalance - startingBalance, spot);
    }
}
