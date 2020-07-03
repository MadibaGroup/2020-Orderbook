pragma solidity >=0.4.22;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

//The last vesrion of the call market implemented bywith linked list
//Maximum number of order the Match function can handle : 125
contract Orderbook_V27{
    uint256 public countervariable;
    SellList public SellFirst;
    BuyList public BuyFirst;
    
    uint256 public test;
    address payable callmarket = address(uint160(address(this)));

    function changetest() public {
        
        test = BuyFirst.Price();
        
    }
    constructor () public{
      SellFirst = SellList(0);
      BuyFirst = BuyList(0);
      state = States.Settled;
    }


    enum States {Opened, Closed, Settled} 
    //Opened: biddingTime, Settlement has not yet started.
    //Closed: biddingTime’s over, Settlement’s satrted and not finished yet.
    //Settled: biddingTime and Settlement are both over , which means the auction is ended and everything is wiped and settled
    
    uint256 public CreationTime;
    uint256 public NumOrders;        //Number of all the orders within the auction
    uint256 public BuyListCounter;   //the counter for BuyList which sorts the order incrementally
    uint256 public SellListCounter;  //the counter for SellList which sorts the order decrementally
    States state;
    address public Token;            //The token that is being traded in the auction



    uint256 public biddingTime = 5 minutes;

    event LogBuyList (address _sender, uint256 _price, uint256 _volume);
    event TransferToken (address _from, address _to, uint256 _numofTokens);
    event TransferEther (address _from, address _to, uint256 _numofEther);
    event TradeHappens (uint256 _BuyPrice, uint256 _SellPrice);
//**********************************************//
//***************Function Modifiers*************//
//**********************************************//
 
    //Checks if the auction should be closed or not.
    modifier CheckAuctionStage (address _token) {
        //if (Auctions[_AuctionID].isValue == false) {Auctions[_AuctionID].state = States.UnInitiallized;}
        if (now >= CreationTime + biddingTime || NumOrders == 1000) 
        {
            state = States.Closed;
            CloseMarket(_token);
            
        }
        _;
    }

//**********************************************// 
    //Checks wether the auction is at state_1 or not (Check this again! Seems to be the same thing with the one above)
    modifier AuctionAtStage (States state_1 ) { 
        require (state == state_1); 
        _;
    }
//**********************************************// 

//**********************************************//
//*********Escrow Variables and Functions*******//
//**********************************************//
    
    //To make the escrow fully general, the contract does not assume a specific ERC20 token, 
    //so a single account may escrow different tokens at the same time. 
    //For each (account, token) pair, the contract tracks its balance and the time when escrow expires:
    //User (Sellers) => Token => balanace
    mapping(address => mapping(address => uint256)) public TokenBalance;
    
    //User (Biders) => balance(Ether)
    mapping(address => uint256) public EtherBalance;

//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _numofTokens) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _numofTokens));
        TokenBalance[msg.sender][_token] += _numofTokens;
        return true;
    
    }
//**************DepositEther() Function*********************//    
    
    function DepositEther(uint256 _numofEthers) public payable returns (bool) {
        EtherBalance[msg.sender] += _numofEthers;
        return true;
        
    }

//******************** OpenMarket function ********************//
    //To open a market(auction) on an specific token, user has to call OpenMarket() function and pass the address of ERC20 token to it
    function OpenMarket(address _token) public 
    AuctionAtStage(States.Settled)
    returns (bool) {
    
        
        CreationTime = now; 
        state = States.Opened;
        NumOrders = 0;
        SellListCounter = 0;
        BuyListCounter = 0;
        Token = _token;
        
        return true;

    }

//******************** CloseMarket() function ********************//
    
    function CloseMarket(address _token) public returns (bool){
        
        state = States.Closed;
        MatchOrders(_token);
        return true;
    }
 //******************** MatchOrders() function ********************//
    function MatchOrders(address _token) public  returns (bool)
    {

        SellList selltemp;
        BuyList buytemp;
       
        while (BuyFirst.Price() >= SellFirst.Price()) //while the list is not empty
        {
                
            countervariable++;
            //emit TradeHappens (BuyFirst.Price(), SellFirst.Price());
            selltemp = SellFirst;
            buytemp = BuyFirst;

            
            TokenBalance[BuyFirst.Sender()][_token] += 1;
            EtherBalance[SellFirst.Sender()] += SellFirst.Price();

            SellFirst.deletenode(callmarket);
            BuyFirst.deletenode(callmarket);

            SellFirst =  selltemp.next();
            BuyFirst = buytemp.next();
            if (BuyFirst == BuyList(0) || SellFirst == SellList(0)) {break;}
                
            
        }
        
        // if (BuyFirst != BuyList(0))
        // {
        //     Rrefund_unexecuted_Buy_orders();
        // }
        
        // if (SellFirst != SellList(0))
        // {
        //     Rrefund_unexecuted_Sell_orders(); 
        // }
        
        state = States.Settled;
        return true;

        
    }
//******************** Rrefund_unexecuted_Buy_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "Ethers" for those trades that did not happen
    function Rrefund_unexecuted_Buy_orders () internal returns (bool) {

        while (BuyFirst != BuyList(0))
        {
            BuyList buytemp = BuyFirst;
            EtherBalance[BuyFirst.Sender()] += BuyFirst.Volume() * BuyFirst.Price();
            BuyFirst.deletenode(callmarket);
            BuyFirst = buytemp.next();
            
            
        }
        
        return true;
    }
    
    //******************** Rrefund_unexecuted_Sell_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "tokens" for those trades that did not happen
    function Rrefund_unexecuted_Sell_orders () internal returns (bool) {
        
        
        while (SellFirst != SellList(0))
        {
            SellList selltemp = SellFirst;
            TokenBalance[SellFirst.Sender()][Token] += SellFirst.Volume();
            SellFirst.deletenode(callmarket);
            SellFirst = selltemp.next();
           
            
        }
        
        return true;
    }

//******************** claimTokens() & claimEther() ********************//
    //traders can claim their tokens or ethers uisng the following two functions

    function claimTokens (address _token, uint256 _numofTokens ) public returns (bool)
    {
        require (TokenBalance[msg.sender][_token] > _numofTokens, 'There is not enough tokens in the account');
        uint256 tokensToBeClaimed = _numofTokens ;
        TokenBalance[msg.sender][_token] -= tokensToBeClaimed;
        IERC20(_token).transfer(msg.sender, tokensToBeClaimed);
        return true;
    }
//******************************************************//      
    function claimEther (uint256 _numofEthers) public returns (bool)
    {
        require (EtherBalance[msg.sender] > _numofEthers, 'There is not enough Ethers in the account');
        uint256 EthersToBeClaimed = _numofEthers ;
        EtherBalance[msg.sender] -= EthersToBeClaimed;
        msg.sender.transfer(EthersToBeClaimed);
        return true;
    }    

//******************** submitBid() function ********************//

    //The Bidder must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint256 _price, uint256 _volume) public returns (bool)
    {
        require (EtherBalance[msg.sender] >= _volume * _price , 'There is not enough Ether in the account');
        
       if (BuyListInsert(_price, _volume, msg.sender))
        {
            NumOrders++;
            EtherBalance[msg.sender] -= _volume * _price;
        }
    
        return true;
    }

//******************** submitask() function ********************//

    //The Bidder must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint256 _price, uint256 _volume ) public  returns (bool)
    {
        require(TokenBalance[msg.sender][Token] >= _volume, 'There is not enough tokens in the account');
        
        if (SellListInsert(_price, _volume, msg.sender))
        {   
            NumOrders++;
            TokenBalance[msg.sender][Token] -= _volume;
        }

        return true;

    }                                                                                                                                                                                              

//*****************************************************************//
//*******************  SellList Functions  ************************//
//*****************************************************************//



//******************** SellListInsert() function ********************//
    function SellListInsert(uint256 _price, uint256 _volume, address _sender) public returns (bool)
    {
        SellList newitem = new SellList (_price, _volume, _sender);
        SellList current = SellFirst; 
        SellList previous = SellList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != SellList(0) && _price >= current.Price()) //The linkedlist is sorted in an ascending order (increasing)
        {
            previous = current;
            current = current.next();
            // we only exit this loop if we find the position to insert our data;
        } 
        //now if we have to check if we have to insert the node to the begining of the list:
        if (previous == SellList(0)) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            SellFirst = newitem; 
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
            previous.addNew(newitem);
        }
        
        //and in all cases regardless of if it's a first node or not, we must say we have to say the node next to our new node is current
        
        newitem.addNew(current);
        return true;
    }            

//*****************************************************************//
//*******************  BuyList Functions  ************************//
//*****************************************************************//


//******************** BuyListInsert() function ********************//
    function BuyListInsert(uint256 _price, uint256 _volume, address _sender) public returns (bool)
    {
        BuyList newitem = new BuyList (_price, _volume, _sender);
        BuyList current = BuyFirst; 
        BuyList previous = BuyList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != BuyList(0) && _price <= current.Price()) //The linkedlist is sorted in an descending order (descreasing)
        {
            previous = current;
            current = current.next();
            // we only exit this loop if we find the position to insert our data;
        } 
        //now if we have to check if we have to insert the node to the begining of the list:
        if (previous == BuyList(0)) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            BuyFirst = newitem; 
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
            previous.addNew(newitem);
        }
        
        //and in all cases regardless of if it's a first node or not, we must say we have to say the node next to our new node is current
        
        newitem.addNew(current);
        return true;
    } 

    
}
//*****************************************************************//
//*******************  SellList Contract  ************************//
//*****************************************************************//
contract SellList {
    SellList public next;
    uint256 public Price;
    address public Sender;
    uint256 public Volume;
    
    constructor(uint256 _price, uint256 _volume, address _sender) public {
        
        Price = _price;
        Sender = _sender;
        Volume = _volume;
        next = SellList(0);
    }

    function addNew(SellList _askorder) public {
        
        next = _askorder;
       
    }
   
    
    // function replacedata ( uint256 _price) public {
    //     Price = _price;
    
    // }
    function deletenode (address payable _callmarket) public {

        selfdestruct(_callmarket);
        
    
    }
}   

//*****************************************************************//
//*******************  BuyList Contract  ************************//
//*****************************************************************//    
    
contract BuyList {
    BuyList public next;
    uint256 public Price;
    address public Sender;
    uint256 public Volume;
    
    constructor(uint256 _price, uint256 _volume, address _sender) public {
        
        Price = _price;
        Volume = _volume;
        Sender = _sender;
        next = BuyList(0);
    }

    function addNew(BuyList _bidorder) public {
        
        next = _bidorder;
       
    }
   
    
    // function replacedata ( uint256 _price) public {
    //     Price = _price;
        
    // }

    function deletenode (address payable _callmarket) public {
        selfdestruct(_callmarket);
    }
}      
    
    
    
    
    
    
    
    