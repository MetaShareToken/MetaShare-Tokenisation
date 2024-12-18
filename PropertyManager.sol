// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./PropertyToken.sol";
import "./TokenSale.sol";

contract PropertyManager {
    struct Property {
        address tokenAddress;
        address saleContractAddress;
        string propertyDetails; // Could store metadata like IPFS CID
    }

    address public admin;
    Property[] public properties;

    event PropertyListed(
        uint256 indexed propertyId,
        address tokenAddress,
        address saleContractAddress,
        string propertyDetails
    );

    constructor(address _admin) {
        require(_admin != address(0), "Admin address cannot be zero");
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    /**
     * @notice Lists a new property by deploying a token and sale contract.
     * @param name Name of the token.
     * @param symbol Symbol of the token.
     * @param totalSupply Total supply of tokens for the property.
     * @param propertyDetails Metadata or property description (e.g., IPFS CID).
     * @param usdtAddress Address of the USDT token.
     * @param tokenPrice Price of each token in USDT.
     */
    function listProperty(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        string memory propertyDetails,
        address usdtAddress,
        uint256 tokenPrice
    ) external onlyAdmin {
        require(usdtAddress != address(0), "Invalid USDT address");
        require(tokenPrice > 0, "Token price must be greater than zero");

        // Deploy the property token
        PropertyToken token = new PropertyToken(
            name,
            symbol,
            address(this),
            admin
        );

        // Mint the entire supply to the manager
        token.mint(address(this), totalSupply);

        // Deploy the token sale contract
        TokenSale saleContract = new TokenSale(
            address(token),
            usdtAddress,
            tokenPrice
        );

        // Approve the sale contract to transfer tokens
        token.approve(address(saleContract), totalSupply);

        // Store the property data
        properties.push(
            Property({
                tokenAddress: address(token),
                saleContractAddress: address(saleContract),
                propertyDetails: propertyDetails
            })
        );

        emit PropertyListed(
            properties.length - 1,
            address(token),
            address(saleContract),
            propertyDetails
        );
    }

    /**
     * @notice Returns the number of listed properties.
     */
    function getPropertyCount() external view returns (uint256) {
        return properties.length;
    }

    /**
     * @notice Fetch details of a listed property.
     * @param propertyId ID of the property.
     */
    function getProperty(
        uint256 propertyId
    ) external view returns (Property memory) {
        require(propertyId < properties.length, "Invalid property ID");
        return properties[propertyId];
    }
}
