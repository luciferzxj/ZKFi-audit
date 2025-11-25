// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console2} from "../lib/forge-std/src/console2.sol";
import {ClaimVault} from "../src/ClaimVault.sol";
contract ClaimVaultScript is Script {
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;//BSC-USDT
    address signer = address(0x5Ca1f99E5E07EB2Bf91bd49bF6B42B955267B1c5);
    address newOwner = address(0xffff);
    function run() public {
        // Setup
        uint256 privateKey = vm.envUint("PRIVATE_KEY_MAIN"); //Main
        vm.startBroadcast(privateKey);

        ClaimVault claimVault = new ClaimVault(
            address(USDT),
            signer,
            1 hours,
            1000_000 ether,
            500_000 ether
        );
        claimVault.transferOwnership(newOwner);
        console2.log("ZEROBASE deployed at:", address(claimVault));

        vm.stopBroadcast();
    }
}