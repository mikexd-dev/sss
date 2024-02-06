// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.1/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.1/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable private _owner;

    mapping(uint256 => uint256) private _listingPrices;
    mapping(uint256 => bool) private _isListed;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can perform this action");
        _;
    }

    function createListing(uint256 tokenId, uint256 price) external {
        require(!_exists(tokenId), "Token already exists");
        require(price > 0, "Price must be greater than zero");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setListingPrice(newItemId, price);
        _setListingStatus(newItemId, true);
    }

    function removeListing(uint256 tokenId) external {
        require(msg.sender == ownerOf(tokenId), "Only the token owner can remove the listing");

        _clearListingPrice(tokenId);
        _setListingStatus(tokenId, false);
    }

    function buy(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        require(_isListed[tokenId], "Token is not listed for sale");
        require(msg.value == _listingPrices[tokenId], "Incorrect payment amount");

        address tokenOwner = ownerOf(tokenId);
        payable(tokenOwner).transfer(msg.value);
        _transfer(tokenOwner, msg.sender, tokenId);

        _clearListingPrice(tokenId);
        _setListingStatus(tokenId, false);
    }

    function setListingPrice(uint256 tokenId, uint256 price) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        require(price > 0, "Price must be greater than zero");

        _setListingPrice(tokenId, price);
    }

    function getListingPrice(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");

        return _listingPrices[tokenId];
    }

    function isListed(uint256 tokenId) external view returns (bool) {
        require(_exists(tokenId), "Token does not exist");

        return _isListed[tokenId];
    }

    function _setListingPrice(uint256 tokenId, uint256 price) private {
        _listingPrices[tokenId] = price;
    }

    function _clearListingPrice(uint256 tokenId) private {
        delete _listingPrices[tokenId];
    }

    function _setListingStatus(uint256 tokenId, bool status) private {
        _isListed[tokenId] = status;
    }
}