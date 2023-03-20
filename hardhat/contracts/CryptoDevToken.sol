// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable{

    uint256 public constant tokenPrice = 0.001 ether;
    uint256 public constant tokensPerNFT = 10 * 10**18;
    uint256 public constant maxTotalSupply =10000 *10**18;
    ICryptoDevs CryptoDevsNFT;
    mapping(uint256 => bool) tokenIdsClaimed;

    constructor(address _crytpoDevsContract) ERC20("Crypto Dev Token","CD"){
        CryptoDevsNFT = ICryptoDevs(_crytpoDevsContract);
    } 

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value>=_requiredAmount, "Ether Sent is incorrect");
        uint256 amountAfter = amount * 10**18;
        require((totalSupply()+amountAfter)<=maxTotalSupply, 
        "Total supply will exceed maximum supply");

        _mint(msg.sender, amountAfter);
    }

    function claim() public{
        address sender = msg.sender;
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        require(balance>0, "You don't own any Crypto Devs NFT");
        uint256 amount = 0;
        
        for(uint256 index = 0; index<balance ; index++){
            uint256 _tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, index); 
            if(!tokenIdsClaimed[_tokenId]){
                tokenIdsClaimed[_tokenId] = true;
                amount+=1;
            }
        }
        require(amount > 0, "You have already claimed all the tokens");
        _mint(msg.sender, amount * tokensPerNFT);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
      }

    receive() external payable{}
    fallback() external payable{}
}