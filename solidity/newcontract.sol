// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Doramo is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("FSNT", "MTK") {

    }

    struct AssetStruct {
        uint256 assetNft;
        uint256 assetValue;
        uint256 assetNumberShares;
        uint256 assetIncome;
        uint256 assetYield;
        uint256 assetRiskRating;
        string currency;
        uint256 assetNumberSharesSold;
        address assetOwner;
        bytes32 assetIpfsAddr;
    }

    // wallet address 
    mapping(address => bool) public walletExists;

    // Mapping of bytes32 to AssetStruct
    mapping(bytes32 => AssetStruct) public ipfsassets;

    // nft mapping to assets
    mapping(uint256 => AssetStruct) public nftassets;

    address[] public wallets;

    mapping(address => uint256[]) public walletNfts;


    // Mapping of wallet address to bytes32 for ipfs record
    mapping(address => bytes32[]) public assetsByOwner;

    function getWallets() public view returns (address[] memory) {
        return wallets;
    }

    function safeMint(
        string memory uri,
        bytes32 _ipfsAddr,
        uint256 _assetValue,
        uint256 _assetNumberShares,
        uint256 _assetIncome,
        uint256 _assetYield,
        uint256 _assetRiskRating,
        string memory _currency,
        uint256 _assetNumberSharesSold,
        address _assetOwner
    )
     public  {

        require(
            ipfsassets[_ipfsAddr].assetNft == 0,
            "Asset with this IPFS address already exists"
        );

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
  
        AssetStruct memory newAsset = AssetStruct({
            assetNft: tokenId,
            assetValue: _assetValue,
            assetNumberShares: _assetNumberShares,
            assetIncome: _assetIncome,
            assetYield: _assetYield,
            assetRiskRating: _assetRiskRating,
            currency: _currency,
            assetNumberSharesSold: _assetNumberSharesSold,
            assetOwner: _assetOwner,
            assetIpfsAddr: _ipfsAddr
        });

        // Store the new asset in the assets mapping
        ipfsassets[_ipfsAddr] = newAsset;

        nftassets[tokenId]=newAsset;

        // Store the IPFS address in the assetsByOwner mapping
        if (!WalletHasAsset(msg.sender, _ipfsAddr)) {
            assetsByOwner[msg.sender].push(_ipfsAddr);
            walletNfts[msg.sender].push(tokenId);

        }
        

        if (!walletExists[msg.sender]) {
            wallets.push(msg.sender);
            walletExists[msg.sender] = true;
        }
 
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

     //   _safeMint(address(this), tokenId);

        // Then, set the token URI
     //   _setTokenURI(tokenId, uri);

        // Finally, transfer the token to the caller
     //   safeTransferFrom(address(this), msg.sender, tokenId);

    }

function listAllNFTVals() public view returns (uint256[] memory) {
    uint256 totalNFTs = _tokenIdCounter.current();
    uint256[] memory nfts = new uint256[](totalNFTs);

    for (uint256 i = 0; i < totalNFTs; i++) {
        nfts[i] = i;
    }

    return nfts;
}

function WalletHasAsset(address wallet, bytes32 _ipfsAddr) private view returns (bool) {
    bytes32[] storage walletAssets = assetsByOwner[wallet];
    for (uint256 i = 0; i < walletAssets.length; i++) {
        if (walletAssets[i] == _ipfsAddr) {
            return true;
        }
    }
    return false;
}

function getAssetsByOwner(address walletAddress) public view returns (bytes32[] memory) {
   
   return assetsByOwner[walletAddress];
     
}
    
function getAssetsByWallet(address _wallet) public view returns (uint256[] memory) {
    return walletNfts[_wallet];
}

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) onlyOwner {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
