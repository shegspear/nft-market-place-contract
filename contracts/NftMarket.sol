// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NftMarke is ERC721, ERC721URIStorage, Ownable {

    uint256 private nextTokenId;
    address public nftTokenAddress;

    uint256 public baalnce;

    error VillagePeople();
    error InsufficientBalance();
    error InsufficientFund();

    mapping (address => uint) ledger;

    constructor(address _nftTokenAddress) ERC721("Eddys", "EDXT1") Ownable(msg.sender){
        nftTokenAddress = _nftTokenAddress; 
    }

    function create(
        address _recipient,
        string memory _tokenURI
    ) public onlyOwner returns (uint256) {
        uint256 _tokenId = nextTokenId++;

        _safeMint(_recipient, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        return _tokenId;
    }

    function approveMovingMyToken(uint256 _tokenId) external {
        ERC721(nftTokenAddress).approve(address(this), _tokenId);
    }

    function sell(uint256 _tokenId) payable external {
        if(msg.sender == address(0)) {
            revert VillagePeople();
        }

        if(ERC721(nftTokenAddress).balanceOf(msg.sender) == 0) {
            revert InsufficientBalance();
        }

        if(msg.value == 0) {
            revert InsufficientFund();
        }

        ERC721(nftTokenAddress).transferFrom(msg.sender, address(this), _tokenId);

        (bool sent,) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed transfer.");

    }

    function buy(uint256 _tokenId, uint256 _amount) payable external {
        if(msg.sender == address(0)) {
            revert VillagePeople();
        }

        if(ERC721(nftTokenAddress).balanceOf(address(this)) == 0) {
            revert InsufficientBalance();
        }

        if(msg.value == 0) {
            revert InsufficientFund();
        }

        baalnce += _amount;

        ERC721(nftTokenAddress).transferFrom(address(this), msg.sender, _tokenId);
    }

    receive() payable external {}

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }



}