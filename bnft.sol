// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {KeeperCompatibleInterface} from "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "@openzeppelin/contracts@4.6.0/utils/Counters.sol";


contract ButterflyLife is ERC721, ERC721URIStorage, KeeperCompatibleInterface {
    
     using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;
 

    string[] uriData = [ 
        "https://pink-managerial-roadrunner-465.mypinata.cloud/ipfs/bafkreigfnzb3ofrxlm5xu65djecutsftlmfsw3dulwsjxrtmew2t3j4pvu",
        "https://pink-managerial-roadrunner-465.mypinata.cloud/ipfs/bafkreih7cuf3vl4rgljclqqzctynu4pfv46o4fwvlkxxxxxbtih4taw2uq",
        "https://pink-managerial-roadrunner-465.mypinata.cloud/ipfs/bafkreifaivpwz6c3pui2cksrf67qi663i5hly57nz7meibwrign7gpj5z4",
        "https://pink-managerial-roadrunner-465.mypinata.cloud/ipfs/bafkreid4vaio3vzyxuv6wojcbxgtshs6tunlmqpgq3q44ryesk2snl2tie"];

         uint256 lastTimeStamp;
         uint256 interval;

    constructor(uint256 _interval)
        ERC721("ButterflyLife", "BFL")
        
    {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }
    
    function checkUpkeep(bytes calldata /* checkData*/ ) external view override returns (bool upkeepNeeded, bytes memory performData) {
        uint256 tokenId = tokenIdCounter.current() - 1;
        bool done;
        performData = "";
        if (butterflyStage(tokenId) >= 3) {
            done = true;
        }

        upkeepNeeded = !done && ((block.timestamp - lastTimeStamp) > interval);        
        // The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;            
            uint256 tokenId = tokenIdCounter.current() - 1;
            growButterfly(tokenId);
        }
        // The performData is generated by the Keeper's call to your checkUpkeep function
    }

    function safeMint(address to)
        public
        returns (uint256)
    {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uriData[0]);
        return tokenId;
    }

    function growButterfly(uint256 _tokenId) public {
        if(butterflyStage(_tokenId) >= 3){return;}
        // Get the current stage of the butterfly and add 1
        uint256 newVal = butterflyStage(_tokenId) + 1;
        // store the new URI
        string memory newUri = uriData[newVal];
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }

    
// determine the stage of the butterfly growth.

    function butterflyStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        // Egg
        if (compareStrings(_uri, uriData[0])) {
            return 0;
        }
        // Larva
        if (
            compareStrings(_uri, uriData[1]) 
        ) {
            return 1;
        }
        //Pupa
        if (
            compareStrings(_uri, uriData[2])
        ) {
            return 2;
        }
        // Must be an Adult
        return 3;
    }

     // helper function to compare strings

    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
