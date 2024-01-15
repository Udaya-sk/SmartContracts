// SPDX-License-Identifier: MIT
pragma solidity >=0.7 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Contract is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 private publicPrice = 0.01 ether;
    uint256 private communityPrice = 0.001 ether;
    uint16 private maxSupply = 5;
    bool private _allowPublicSale = false;
    bool private _allowCommunitySale = false;
    mapping(address => bool) communityMembers;

    constructor(
        address initialOwner
    ) ERC721("ERC721Contract", "Web3") Ownable(initialOwner) {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function communityMint() public payable {
        require(
            communityMembers[msg.sender],
            "you do not have community membership"
        );
        require(msg.value == communityPrice, "insufficient pay amount");
        require(_allowCommunitySale, "public sale is not allowed");
        internalMint();
    }

    function addToCommunity(address[] memory members) external onlyOwner {
        for (uint i = 0; i < members.length; i++) {
            communityMembers[members[i]] = true;
        }
    }

    function publicMint() public payable {
        require(msg.value == publicPrice, "insufficient pay amount");
        require(_allowPublicSale, "public sale is not allowed");
        internalMint();
    }

    function internalMint() internal {
        require(totalSupply() < maxSupply, "sold out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function modifySale(
        bool allowPublicSale,
        bool allowCommunitySale
    ) public onlyOwner {
        _allowPublicSale = allowPublicSale;
        _allowCommunitySale = allowCommunitySale;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
