// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4; 

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.00025 ether;

    address payable owner; 

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
      uint256 tokenId;
      address payable seller;
      address payable owner;
      address ERC20Address;// address(0) if want native token
      uint256 price;
      bool sold;
    }


    event MarketItemCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      address ERC20Address,
      uint256 price,
      bool sold
    );


    constructor() ERC721("WEB3 DAO Tokens", "WDAO") {
      owner = payable(msg.sender);
    }

    function updateListingPrice(uint _listingPrice) public payable {
      require(owner == msg.sender, "Only marketplace owner can update listing price.");
      listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }


    function createToken(string memory tokenURI,address ERC20Address, uint256 price) public payable returns (uint) {
      _tokenIds.increment();

      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      createMarketItem(newTokenId,ERC20Address , price);

      return newTokenId;
    }

    function createMarketItem(uint256 tokenId,address ERC20Address  , uint256 price) private {

      require(price > 0, "Price must be at least 1 wei");

      require(msg.value == listingPrice, "Price must be equal to listing price");


      idToMarketItem[tokenId] =  MarketItem(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        ERC20Address,
        price,
        false
      );


      _transfer(msg.sender, address(this), tokenId);
      emit MarketItemCreated(
        tokenId,
        msg.sender,
        address(this),
        ERC20Address,
        price,
        false
      );
    }


    
    function resellToken(uint256 tokenId,address ERC20Address, uint256 price) public payable {
      // if no address is given, defualt value is address(0)
      require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      idToMarketItem[tokenId].ERC20Address = ERC20Address;
      idToMarketItem[tokenId].sold = false;
      idToMarketItem[tokenId].price = price;
      idToMarketItem[tokenId].seller = payable(msg.sender);
      idToMarketItem[tokenId].owner = payable(address(this));
      _itemsSold.decrement();

      _transfer(msg.sender, address(this), tokenId);
    }

    function createMarketSale(uint256 tokenId,address ERC20Address) public payable {
      uint price = idToMarketItem[tokenId].price;
      address payable creator = idToMarketItem[tokenId].seller;
      idToMarketItem[tokenId].owner = payable(msg.sender);
      idToMarketItem[tokenId].sold = true;
      idToMarketItem[tokenId].seller = payable(address(0));
      _itemsSold.increment();
      _transfer(address(this), msg.sender, tokenId);

      if(ERC20Address == address(0)){
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        payable(owner).transfer(listingPrice);
        payable(creator).transfer(msg.value);
      }else{
        
        require(IERC20(ERC20Address).transferFrom(msg.sender, creator, price),"Please approve the asking price in order to complete the purchase");
        payable(owner).transfer(listingPrice);
      }
    }


    function fetchMarketItems() public view returns (MarketItem[] memory) {
      uint itemCount = _tokenIds.current();
      uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
      uint currentIndex = 0;

      MarketItem[] memory items = new MarketItem[](unsoldItemCount);
      for (uint i = 0; i < itemCount; i++) {

        if (idToMarketItem[i + 1].owner == address(this)) {

          uint currentId = i + 1;

          MarketItem storage currentItem = idToMarketItem[currentId];

          items[currentIndex] = currentItem;

          currentIndex += 1;
        }
      }

      return items;
    }


    function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;


      for (uint i = 0; i < totalItemCount; i++) {
        // check if nft is mine
        if (idToMarketItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {

        if (idToMarketItem[i + 1].owner == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    function fetchItemsListed() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      
      return items;
    }
}


