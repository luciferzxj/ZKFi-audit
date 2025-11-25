// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console2} from "../lib/forge-std/src/console2.sol";
import {ClaimVault} from "../src/ClaimVault.sol";
contract ClaimVaultScript is Script {
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;//ETH-USDT
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
            1_000_000 * 10 ** 6,
            500_000 * 10 ** 6
        );
        claimVault.transferOwnership(newOwner);
        console2.log("ZEROBASE deployed at:", address(claimVault));

        vm.stopBroadcast();
    }
}
