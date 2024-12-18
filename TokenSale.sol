// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./PropertyToken.sol";

contract TokenSale is ReentrancyGuard {
    PropertyToken public propertyToken;
    IERC20 public usdtToken;
    uint256 public tokenPrice; // Price in USDT (e.g., 1 token = 1 USDT)

    constructor(
        address _propertyToken,
        address _usdtToken,
        uint256 _tokenPrice
    ) {
        propertyToken = PropertyToken(_propertyToken);
        usdtToken = IERC20(_usdtToken);
        tokenPrice = _tokenPrice;
    }

    /**
     * @notice Allow users to purchase property tokens.
     */
    function purchaseTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");

        uint256 cost = amount * tokenPrice;
        require(
            usdtToken.transferFrom(msg.sender, address(this), cost),
            "Payment failed"
        );

        propertyToken.mint(msg.sender, amount);
    }

    /**
     * @notice Admin can withdraw USDT funds.
     */
    function withdrawFunds(address to) external {
        require(to != address(0), "Invalid address");
        uint256 balance = usdtToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");

        usdtToken.transfer(to, balance);
    }
}
