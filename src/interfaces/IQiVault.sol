// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IQiVault {
  function setGainRatio(uint256 _gainRatio) external;
  function setDebtRatio(uint256 _debtRatio) external;
  function transferToken(address to, address token, uint256 amountToken) external;
  function changeEthPriceSource(address ethPriceSourceAddress) external;
  function setTokenPeg(uint256 _tokenPeg) external;
  function setStabilityPool(address _pool) external;
  function setMinCollateralRatio(uint256 minimumCollateralPercentage) external;
  function setClosingFee(uint256 amount) external;
  function setOpeningFee(uint256 amount) external;
  function setTreasury(uint256 _treasury) external;
  function transferToken(uint256 amountToken) external;
  function setBaseURI(string memory baseURI) external;
}
