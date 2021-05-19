pragma solidity ^0.7.0;


import "./Inbox.sol";

contract Payment {

    IInbox public inbox;
    constructor( address _inbox) public  {
      
        inbox = IInbox(_inbox);
    }
   
    
    function depositEther(address _destAddress) public payable
    {   
        inbox.depositEth{value: msg.value}(_destAddress);

    }

    
}

