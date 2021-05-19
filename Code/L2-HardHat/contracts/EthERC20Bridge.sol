// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.7.0;


interface EthERC20Bridge {



function initialize(address _inbox, address _l2TemplateERC20, address _l2ArbTokenBridgeAddress) external;

function registerCustomL2Token(address l2CustomTokenAddress, uint256 maxSubmissionCost, uint256 maxGas, uint256 gasPriceBid, address refundAddress) external returns(uint256);

function fastWithdrawalFromL2(address liquidityProvider, bytes memory liquidityProof, address initialDestination, address erc20, uint256 amount, uint256 exitNum, uint256 maxFee) external;

function withdrawFromL2(uint256 exitNum, address erc20, address initialDestination, uint256 amount) external;

function deposit(address erc20, address destination, uint256 amount, uint256 maxSubmissionCost, uint256 maxGas, uint256 gasPriceBid, bytes memory callHookData) external returns(uint256);

function calculateL2TokenAddress(address erc20) external returns(address);



}

