// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PropertyToken is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public fundingWallet;

    constructor(
        string memory name,
        string memory symbol,
        address admin,
        address _fundingWallet
    ) ERC20(name, symbol) {
        grantRole(DEFAULT_ADMIN_ROLE, admin);
        grantRole(ADMIN_ROLE, admin);
        fundingWallet = _fundingWallet;
    }

    /**
     * @notice Mint tokens to a specific address (Admin or Minter Only).
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @notice Allow admin to update the funding wallet.
     */
    function updateFundingWallet(
        address newFundingWallet
    ) external onlyRole(ADMIN_ROLE) {
        require(newFundingWallet != address(0), "Invalid address");
        fundingWallet = newFundingWallet;
    }

    /**
     * @notice Withdraw USDT or other tokens sent to this contract.
     */
    function withdrawFunds(address tokenAddress) external onlyRole(ADMIN_ROLE) {
        require(tokenAddress != address(0), "Invalid token address");
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No balance to withdraw");
        token.transfer(fundingWallet, balance);
    }
}
