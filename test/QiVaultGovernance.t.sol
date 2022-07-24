// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/QiVaultGovernance.sol";

contract QiVaultGovernanceTest is Test {
  QiVaultGovernance governanceContract;

  address MULTISIG = 0x1d8a6b7941ef1349c1b5E378783Cd56B001EcfBc;
  address WMATIC_VAULT = 0x305f113ff78255d4F8524c8F50C7300B91B10f6A;

  function setUp() public {
    address[] memory owners = new address[](1);
    owners[0] = MULTISIG;
    governanceContract = new QiVaultGovernance(owners);

    vm.prank(MULTISIG);
    IQiVault(WMATIC_VAULT).transferOwnership(address(governanceContract));
  }

  function testMultisigIsNoLongerOwner() public {
    vm.prank(MULTISIG);
    vm.expectRevert("Ownable: caller is not the owner");
    IQiVault(WMATIC_VAULT).changeEthPriceSource(address(1));
  }

  function testAllowlistFunction() public {
    vm.prank(MULTISIG);

    governanceContract.execute(
      WMATIC_VAULT,
      0,
      abi.encodeWithSelector(
        IQiVault.setGainRatio.selector,
        123
      ),
      bytes32(""),
      bytes32("")
    );

    assertEq(IQiVault(WMATIC_VAULT).gainRatio(), 123);
  }

  function testBlocklistFunction() public {
    vm.prank(MULTISIG);

    vm.expectRevert("QiVaultGovernance: fn blocked");

    governanceContract.execute(
      WMATIC_VAULT,
      0,
      abi.encodeWithSelector(
        IQiVault.transferToken.selector,
        address(0),
        address(0),
        1
      ),
      bytes32(""),
      bytes32("")
    );
  }

  function testTimelockFunctionCannotBeExecutedImmediately() public {
    vm.prank(MULTISIG);
    vm.expectRevert("TimelockController: operation is not ready");

    governanceContract.execute(
      WMATIC_VAULT,
      0,
      abi.encodeWithSelector(
        IQiVault.changeEthPriceSource.selector,
        address(1)
      ),
      bytes32(""),
      bytes32("")
    );
  }

  function testTimelockFunctionCanBeExecutedAfterDelay() public {
    address newPriceSource = address(1);

    vm.prank(MULTISIG);
    governanceContract.schedule(
      WMATIC_VAULT,
      0,
      abi.encodeWithSelector(
        IQiVault.changeEthPriceSource.selector,
        newPriceSource
      ),
      bytes32(""),
      bytes32(""),
      12 hours
    );

    vm.warp(block.timestamp + 12 hours);

    vm.prank(MULTISIG);
    governanceContract.execute(
      WMATIC_VAULT,
      0,
      abi.encodeWithSelector(
        IQiVault.changeEthPriceSource.selector,
        newPriceSource
      ),
      bytes32(""),
      bytes32("")
    );

    assertEq(IQiVault(WMATIC_VAULT).ethPriceSource(), newPriceSource);
  }

  function testOnlyMultisigAllowed() public {
    vm.expectRevert("AccessControl: account 0xb4c79dab8f259c7aee6e5b2aa729821864227e84 is missing role 0xd8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e63");

    governanceContract.execute(
      WMATIC_VAULT,
      0,
      abi.encodeWithSelector(
        IQiVault.setGainRatio.selector,
        123
      ),
      bytes32(""),
      bytes32("")
    );
  }
}
