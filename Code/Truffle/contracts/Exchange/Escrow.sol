//pragma solidity >=0.4.22 <0.6.0;
pragma solidity ^0.6.0;

//import './DappToken.sol';

import "http://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
//import "http://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";


//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";


//import "http://github.com/theabyssportal/DAICO-Smart-Contract/blob/master/token/IERC20Token.sol";

contract Escrow{
    
    uint256 public escrowTime;

    /*constructor(uint256 _escrowTime) public {
        escrowTime = _escrowTime;
    }*/
    
    //To make the escrow fully general, the contract does not assume a specific ERC20 token, 
    //so a single account may escrow different tokens at the same time. 
    //For each (account, token) pair, the contract tracks its balance and the time when escrow expires:
    //User => Token => balanace
    mapping(address => mapping(address => uint256)) public escrowBalance;
    mapping(address => mapping(address => uint256)) public escrowExpiration;
    
    function deposit(address _token, uint256 _amount) public {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount));
        escrowBalance[msg.sender][_token] += _amount;
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*DappToken token = DappToken(0xD04a9B31144d28E3A36C4eBCb99b9c79763f71f0);
    // User => Token => Balance
    mapping(address => mapping(address => uint256)) public escrowBalance; 
    uint256 public x;
    //address public x;
    
    //function deposit (address _tokenAddr, uint256 _amount) public returns (bool){
        function deposit (uint256 _amount) public payable returns (bool){
        //require ()
        //IERC20 tok = ERC20Token(_tokenAddr);
        //require(IERC20(_tokenAddr).approve(address(this), _amount));
        //IERC20(_tokenAddr).transferFrom (msg.sender, address(this), _amount);
        //x = address(this);
        //x = ERC20(_tokenAddr).balanceOf(msg.sender);
        //escrowBalance[msg.sender][_tokenAddr] += x ;
        //escrowBalance[msg.sender][_tokenAddr] += _amount;
        
        //token.transfer(address(this), _amount);
        token.transferFrom (msg.sender, address(this), _amount);

    }*/
    
    
    

}    