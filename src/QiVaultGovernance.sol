// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IQiVault.sol";
import "openzeppelin-contracts/governance/TimelockController.sol";

contract QiVaultGovernance is TimelockController {
  mapping (bytes4 => bool) allowlistFunctions;
  mapping (bytes4 => bool) blocklistFunctions;

  constructor(address[] memory _owners) TimelockController(12 hours, _owners, _owners) {
    // These functions can be called without a timelock:
    allowlistFunctions[IQiVault.setGainRatio.selector] = true;
    allowlistFunctions[IQiVault.setDebtRatio.selector] = true;
    allowlistFunctions[IQiVault.setStabilityPool.selector] = true;
    allowlistFunctions[IQiVault.setMinCollateralRatio.selector] = true;
    allowlistFunctions[IQiVault.setTreasury.selector] = true;

    // transferToken(address to, address token, uint256 amountToken)
    blocklistFunctions[0xf5537ede] = true;
  }

  function execute(
    address target,
    uint256 value,
    bytes calldata payload,
    bytes32 predecessor,
    bytes32 salt
  ) public payable override onlyRoleOrOpenRole(EXECUTOR_ROLE) {
    bytes4 sighash = bytes4(payload[:4]);

    require(!blocklistFunctions[sighash], "QiVaultGovernance: fn blocked");

    if (allowlistFunctions[sighash]) {
      (bool success, ) = target.call{value: value}(payload);
      require(success, "TimelockController: underlying transaction reverted");
    } else {
      super.execute(target, value, payload, predecessor, salt);
    }
  }
}
