//SPDX-Licencse-identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop merkleAirdop;
    BagelToken token;

    bytes32 public root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proofOne, proofTwo];
    uint256 public AMOUNT_TO_TRANSFER = 4 * (25 * 1e18);

    address user = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;
    address fakeUser = makeAddr("fake user");
    uint256 public AMOUNT_TO_CLAIM = 25000000000000000000;

    function setUp() public {
        token = new BagelToken();
        bytes memory initData = abi.encodeWithSelector(MerkleAirdrop.initialize.selector, root, IERC20(token));
        address proxy = Upgrades.deployUUPSProxy(
            "MerkleAirdrop.sol", abi.encodeCall(MerkleAirdrop.initialize, (root, address(token)))
        );
        merkleAirdop = MerkleAirdrop(proxy);
        token.grantMintAndBurnRole(token.owner());
        token.mint(token.owner(), AMOUNT_TO_TRANSFER);
        IERC20(token).transfer(address(proxy), AMOUNT_TO_TRANSFER);
    }

    function testUserInWhiteListCanClaim() public {
        uint256 startingBalance = IERC20(token).balanceOf(user);
        assertEq(0, startingBalance);

        vm.prank(user);
        merkleAirdop.claim(user, AMOUNT_TO_CLAIM, proof);

        uint256 endiningBalance = IERC20(token).balanceOf(user);
        console.log("haizzz:");
        assertEq(endiningBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testUserNotInWhiteListCanNotClaim() public {
        vm.prank(fakeUser);
        vm.expectRevert();
        merkleAirdop.claim(fakeUser, AMOUNT_TO_CLAIM, proof);
    }

    function testClaimedCheck() public {
        vm.prank(user);
        merkleAirdop.claim(user, AMOUNT_TO_CLAIM, proof);
        merkleAirdop.getClaimedCheck(user);
    }
}
