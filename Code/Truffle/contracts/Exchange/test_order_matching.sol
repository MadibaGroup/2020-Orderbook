pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;
//pragma experimental ABIEncoderV2;
//import "http://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract test{
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        //uint256 AuxPrice; //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
        uint256 Volume; //The volume is 1 for now
        
    }
    
    OrderStruct[] public BuyList;  
    OrderStruct[] public SellList;
    
    
    mapping(address => uint) internal refunds;
   
   
   
   //To make the escrow fully general, the contract does not assume a specific ERC20 token, 
    //so a single account may escrow different tokens at the same time. 
    //For each (account, token) pair, the contract tracks its balance and the time when escrow expires:
    //User (Sellers) => Token => balanace
    mapping(address => mapping(address => uint256)) public TokenBalance;
    //mapping(address => mapping(address => uint256)) public escrowExpiration;
    
    
    //User (Biders) => balance(Ether)
    mapping(address => uint256) public EtherBalance;

//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _amount) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount));
        TokenBalance[msg.sender][_token] += _amount;
        return true;
        
    }
//**************DepositEther() Function*********************//    
    
    function DepositEther() public payable returns (bool) {
        
        EtherBalance[msg.sender] += msg.value;
        return true;
        
    }     
    
//**********************************************************************    
    
    
    
    function submitBid (uint256 _price, uint256 _volume) public  returns (bool)
    {
        
        
         BuyList.push(OrderStruct({ Sender: msg.sender, Price: _price, Volume: _volume}));   
    
        return true;
    }
//**********************************************************************    
    
    function submitAsk (uint256 _price, uint256 _volume) public  returns (bool)
    {
        
        
         SellList.push(OrderStruct({ Sender: msg.sender, Price: _price, Volume: _volume}));   
    
        return true;
    }
    
    
    
//**********************************************************************       
    
    
    function BuyListpeak() public view returns (OrderStruct memory){

        return (BuyList[0]);
    }

//**********************************************************************        
    function transferToken( address _fromSeller, address _toBuyer, address _token, uint256 _numofTokens) internal
    {
        require(TokenBalance[_fromSeller][_token] >= _numofTokens,  "Insufficient balance.");

        TokenBalance[_fromSeller][_token] -= _numofTokens;
        TokenBalance[_toBuyer][_token] += _numofTokens;
    }
    
    function transferEther( address _fromBuyer, address _toSeller, address _token, uint256 _numofEthers) internal
    {
        require(EtherBalance[_fromBuyer] >= _numofEthers,  "Insufficient balance.");

        EtherBalance[_fromBuyer] -= _numofEthers;
        EtherBalance[_toSeller] += _numofEthers;
    }

//**********************************************************************            
    
    function MatchOrders(address _token) public returns (bool){
        
        uint256 BestBid;
        uint256 BestAsk;
        //uint256 MatchingPrice;
        
        if (BuyList[0].Price > SellList[0].Price)
        {
            BestBid = BuyList[0].Price;
            BestAsk = SellList[0].Price;
            //MatchingPrice = BestBid - BestAsk;
            transferToken (SellList[0].Sender, BuyList[0].Sender, _token, BuyList[0].Volume);
            transferEther (BuyList[0].Sender,SellList[0].Sender, _token, SellList[0].Price );
            
            
            
            
            
           /* 
            //Pays the difference to the miner
            refunds[block.coinbase] += BestBid - BestAsk;
             refund = refunds[block.coinbase]; 
            refunds[block.coinbase] = 0; 
            block.coinbase.transfer(refund);
        
            */
            
        }
        
        
        /*if (BuyListpeak(_AuctionID).Price == SellListpeak(_AuctionID).Price)
        {
            BestBid = BuyListpeak(_AuctionID).Price;
            BestAsk = SellListpeak(_AuctionID).Price;
            
            BestBid - BestAsk
            
            
        }*/

        
    }
    
    
    function claimTokens (address _token) public returns (bool)
    {
        //require(!_investors[msg.sender].claimed);
        require (TokenBalance[msg.sender][_token] > 0);
        uint tokensToBeClaimed = TokenBalance[msg.sender][_token] ;
        //_investors[msg.sender].claimed = true;  
        TokenBalance[msg.sender][_token] = 0;
        IERC20(_token).transfer(msg.sender, tokensToBeClaimed);
        return true;
    }
    
    function claimTokens () public returns (bool)
    {
        //require(!_investors[msg.sender].claimed);
        require (EtherBalance[msg.sender] > 0);
        uint EthersToBeClaimed = EtherBalance[msg.sender] ;
        //_investors[msg.sender].claimed = true;  
        EtherBalance[msg.sender]  = 0;
        msg.sender.transfer(EthersToBeClaimed);
        return true;
    }
    
    
    
    
    
    
}