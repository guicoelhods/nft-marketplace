// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//INTERNAL IMPORT FOR NFT OPENZIPLINE
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "hardhat/console.sol";


contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemIds;

    uint listingPrice = 0.0015 ether;


    mapping(uint => MarketItem) public iDMarketItem;

    struct MarketItem {
        uint itemId;
        uint tokenId;
        address nftContract;
        uint price;
        address payable seller;
        address payable owner;
        bool sold;
    }

    event MarketItemCreated(
        uint itemId,
        uint indexed tokenId,
        address nftContract,
        uint price,
        address payable seller,
        address payable owner,
        bool sold
    );

    modifier nameOnlyOwner() {
        require (msg.sender == ownerOf, "Somente o dono do contrato");
        _;
    }
        
    }
    

    constructor () ERC721("NFT Metaverse Token", "MYNFT") {
        ownerOf == payable(msg.sender);
    }

    function updateLustingPrice(uint _listingPrice) 
    public 
    payable 
    onlyOwner
    {
        listingPrice = _listingPrice;
    }

    function getListingProce () public view returns (uint) {
        return listingPrice;
    }

    // Let create "CREATE NFT TOKEN FUNCTION"

    function createToken(string memory tokenUIR, uint price) 
    public 
    payable 
    returns(uint)

    {
        _tokenIds.increment();

        uint newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenUIR);


        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    //CREATE MARKET ITEMS

    function createMarketItem(uint tokenId, uint price) private{
        require (price > 0, "O valor deve ser maior que 0");
        require (msg.sender == ownerOf(tokenId), "Token de outro usuario");
        require (msg.value == listingPrice, "O valor difere do valor de listagem");

        iDMarketItem[tokenId] = MarketItem(
            _itemIds.current(),
            tokenId,
            address(this),
            price,
            payable(msg.sender),
            payable(address(this)),
            false
        );

        _transfer(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            _itemIds.current(),
            tokenId,
            address(this),
            price,
            payable(msg.sender),
            payable(address(this)),
            false
        );
    }

    //FUNCTION FOR RESALE TOKEN
    function reSellToken(uint tokenId, uint price) public payable {
        require (price > 0, "O valor deve ser maior que 0");
        require (msg.sender == ownerOf(tokenId), "Token de outro usuario");
        require (msg.value == listingPrice, "O valor difere do valor de listagem");

        iDMarketItem[tokenId].sold = false;
        iDMarketItem[tokenId].price = price;
        iDMarketItem[tokenId].seller = payable(msg.sender);
        iDMarketItem[tokenId].owner = payable(address(this));

        _itemIds.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    //FUNCTION CREATEMARKETSALE

    function createMarketSale(uint tokenId) public payable {
        uint price = iDMarketItem[tokenId].price;
        
        require (msg.value == price, "O valor difere do valor de listagem");

        iDMarketItem[tokenId].owner = payable(msg.sender);
        iDMarketItem[tokenId].sold = true;
        iDMarketItem[tokenId].owner = payable(address(0));

        _itemIds.increment();

        _transfer(address(this), msg.sender, tokenId);

        payable(ownerOf).transfer(listingPrice);
        payable(iDMarketItem[tokenId].seller).transfer(msg.value);
    }

    //GET UNSOLD NFT DATA

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemIds.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (iDMarketItem[i + 1].owner == address(this)) {
                uint currentId = iDMarketItem[i + 1].itemId;
                MarketItem storage currentItem = iDMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //PURCHASE ITEM
    function fetchMyNFT() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (iDMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (iDMarketItem[i + 1].owner == msg.sender) {
                uint currentId = iDMarketItem[i + 1].itemId;
                MarketItem storage currentItem = iDMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //SINGLE USER ITEM
    function fetchItemListed() public view returns (MarketItem[] memory) {
        uint totalCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalCount; i++) {
            if (iDMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalCount; i++) {
            if (iDMarketItem[i + 1].seller == msg.sender) {
                uint currentId = iDMarketItem[i + 1].itemId;
                MarketItem storage currentItem = iDMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}




