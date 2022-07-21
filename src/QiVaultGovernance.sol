// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IQiVault.sol";
import "openzeppelin-contracts/governance/TimelockController.sol";

contract QiVaultGovernance is TimelockController {
  mapping (bytes4 => bool) allowlistFunctions;

  constructor(address[] memory _owners) TimelockController(12 hours, _owners, _owners) {
    // These functions can be called without a timelock:
    allowlistFunctions[IQiVault.setGainRatio.selector] = true;
    allowlistFunctions[IQiVault.setDebtRatio.selector] = true;
    allowlistFunctions[IQiVault.setStabilityPool.selector] = true;
    allowlistFunctions[IQiVault.setMinCollateralRatio.selector] = true;
    allowlistFunctions[IQiVault.setTreasury.selector] = true;
  }

  function execute(
    address target,
    uint256 value,
    bytes calldata payload,
    bytes32 predecessor,
    bytes32 salt
  ) public payable override onlyRoleOrOpenRole(EXECUTOR_ROLE) {
    if (isAllowlistFunction(bytes4(payload[:4]))) {
      (bool success, ) = target.call{value: value}(payload);
      require(success, "TimelockController: underlying transaction reverted");
    } else {
      super.execute(target, value, payload, predecessor, salt);
    }
  }

  function isAllowlistFunction(bytes4 sighash) view internal returns (bool) {
    return allowlistFunctions[sighash];
  }
}
