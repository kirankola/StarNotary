// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {
    constructor() ERC721("StarNotary", "STAR") {}
    struct Star {
        string name;
    }

    // Kiran Task 1: Add a name and a symbol for your starNotary tokens
    // name: Token name
    // symbol: Symbol to token
    //string public name = "Your Star";
    //string public symbol = "USTR"; 

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;


    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return payable(x); //added payable call to update new version of solidity 0.8 version.
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transfer(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        // Kiran: corrected _transferFrom to transferFrom function.
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
           _make_payable(msg.sender).transfer(msg.value - starCost); //corrected return to function  _make_payable(msg.sender)
        }
    }
    // Kiran: Task 1 function - lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo (uint256 _tokenId) public view returns (string memory) {
        Star memory _star = tokenIdToStarInfo[_tokenId];
        return _star.name;
    }

    // Kiran: Task 1 function - exchangeStars
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        require((ownerOf(_tokenId1) == msg.sender) || (ownerOf(_tokenId2) == msg.sender), "You can't exchange a Star you don't own.");
        //require(starsForSale[_tokenId1] == 0, "The Star you are trying to exchange should not be up for sale");
        //require(starsForSale[_tokenId2] == 0, "The Star the user is trying to exchange should not be up for sale");
        address _user1 = ownerOf(_tokenId1);
        address _user2 = ownerOf(_tokenId2);
        _transfer(_user2, _user1, _tokenId2);
        _transfer(_user1, _user2, _tokenId1);
    }

    // Kiran: Task 1 function - transferStar
    function transferStar(address _to1, uint256 _tokenId) public {
        //1. Check if the sender is the ownerOf(_tokenId)
        //2. Use the transferFrom(from, to, tokenId); function to transfer the Star
        require(ownerOf(_tokenId) == msg.sender, "You can't transfer a Star you don't own.");
        //require(starsForSale[_tokenId] == 0, "The Star you are trying to exchange should not be up for sale");
        transferFrom(msg.sender, _to1, _tokenId);
    }
}