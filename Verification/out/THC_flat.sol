// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


//  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄       ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄
// ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌     ▐░░▌      ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
//  ▀▀▀▀█░█▀▀▀▀ ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀      ▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌
//      ▐░▌     ▐░▌       ▐░▌▐░▌               ▐░▌▐░▌    ▐░▌▐░▌       ▐░▌          ▐░▌▐░▌       ▐░▌
//      ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░▌               ▐░▌ ▐░▌   ▐░▌▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌
//      ▐░▌     ▐░░░░░░░░░░░▌▐░▌               ▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
//      ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌▐░▌               ▐░▌   ▐░▌ ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌
//      ▐░▌     ▐░▌       ▐░▌▐░▌               ▐░▌    ▐░▌▐░▌▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌
//      ▐░▌     ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄      ▐░▌     ▐░▐░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌
//      ▐░▌     ▐░▌       ▐░▌▐░░░░░░░░░░░▌     ▐░▌      ▐░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌
//       ▀       ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀       ▀        ▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀



// import "./contracts/lifecycle/Pausable.sol";



// mint id 0 at 10bnb
// mint id 1-500 at 0.3 bnb
//NOTE: In remix, send wei, 0.4 BNB = 400000000000000000


contract THC_NAZA is ERC721, Ownable {

    //Tracks numTokens minted
    uint256 public numTokens = 0;

    //Random number generation
    uint256 public nonce;
    uint256[] public indices;

    //Supply
    uint256 public constant THC_NAZA_SUPPLY = 2;

    //Prices
    //0.3 BNB
    uint256 immutable _price = 300000000000000000;
    //10 BNB
    uint256 immutable _priceGenesis = 10000000000000000000;

    //TokenId counter
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdentifiers;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;


    //Constructor
    constructor() ERC721("TranshumanCoin", "THC") {
        _baseURIextended = "https://gateway.pinata.cloud/ipfs/QmYipxb1MvM6DF4NcVRzGMhxPRyWDXWXAwneGGovi4Khdp/THC_NAZA_";
        // uint tokenId = 0;
        // string memory baseURI_ = _baseURIextended;
    }


    // Base URI
    string private _baseURIextended;


    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIextended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        string memory filetype = ".json";

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI, filetype));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId, filetype));
    }


    /**
        * @dev Mints 1 Genesis NFT for 10BNB
    */
    function mintGenesis(address _to) external payable {
        require(_priceGenesis < msg.value, "Ether value sent is not correct");
        ++numTokens;
        _safeMint(_to, 0);
        _setTokenURI(0,"0");
    }


    /**
        * @dev Mints 1 NFT for 0.3 BNB
    */
    function mintNFT() external payable {
        ++numTokens;
        // require(totalSupply() < MAX_NFT_SUPPLY, "Sale has already ended");
        require(_price < msg.value, "Ether value sent is not correct");

        // Incrementing ID to create new tokenn
        // _tokenIdentifiers.increment();
        // uint256 newRECIdentifier = _tokenIdentifiers.current();

        // uint tokenId = 0;
        // string memory _tokenURI = "hello";
        // string memory tokenURITest = "hello";
        // _safeMint(msg.sender, 0);
        // string memory id = uint2str(tokenId);
        // _setTokenURI(0,id);
        // ++tokenId;

        // Incrementing ID to create new tokenn
        _tokenIdentifiers.increment();
        // _safeMint(msg.sender, tokenId);
        // uint256 newRECIdentifier = _tokenIdentifiers.current();
        uint256 newRECIdentifier = _tokenIdentifiers.current();
        // _safeMint(msg.sender, newRECIdentifier);
        //   _setTokenURI(newRECIdentifier, tokenURI(1));


        //RNG
        // uint256 newRECIdentifier = uint(blockhash(block.number - 1)) % THC_NAZA_SUPPLY - numTokens;

        //TODO - REVIEW we use tokenID twice.. but token ID should match URI anyways
        _safeMint(msg.sender, newRECIdentifier);
        string memory uid = uint2str(newRECIdentifier);
        _setTokenURI(newRECIdentifier, uid);
    }



    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }


    /**
    * @dev Withdraw BNB from this contract (Callable by owner)
    */
    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        address payable ownerAddress = payable(msg.sender);
        ownerAddress.transfer(balance);
    }

    // /**
    // * @dev Pause
    // */
    // function pauser() external virtual onlyOwner {
    //     super._pause();
    // }


    // /**
    // * @dev Unpause
    // */
    // function unpause() external virtual onlyOwner {
    //     super._unpause();
    // }
}









    // function randomIndex() internal returns (uint) {
    //     uint totalSize = THC_NAZA_SUPPLY - numTokens;
    //     uint index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
    //     uint value = 0;
    //     if (indices[index] != 0) {
    //         value = indices[index];
    //     } else {
    //         value = index;
    //     }

    //     if (indices[totalSize - 1] == 0) {

    //         indices[index] = totalSize - 1;
    //     } else {
    //         indices[index] = indices[totalSize - 1];
    //     }
    //     nonce++;
    //     return value;
    // }


//         /**
//      * @dev Set the base URI
//      */
//     function setBaseURI(string memory baseURI_) external onlyOwner() {
//         _baseURIextended = baseURI_;
//     }
// }




    // function _mint(address _to) public {
    //     // uint id = randomIndex();
    //     numTokens = numTokens + 1;
    //     string memory tokenURITest = "hello";
    //     // uint256 idtest = 0;
    //     // _mint(_to, id);
    //     // _setTokenURI(id,"0");
    //     // _setTokenURI(idtest, tokenURITest);
    //     // ++id;
    //     // return id;
    //     // Incrementing ID to create new tokenn
    //     _tokenIdentifiers.increment();
    //     // _mint(_to, tokenId);
    //     uint256 newRECIdentifier = _tokenIdentifiers.current();
    //     // _setTokenURI(id, uint2str(newRECIdentifier));
    // }



// constructor() ERC1155("https://gateway.pinata.cloud/ipfs/QmS7vBvBqbdcUm3zx3cwkUc9hiFp4eqSW7xGoB5Wv6dzzj/THC_NAZA_={id}.json") {
//     _mint(msg.sender, 1, 100, "" );
// }



