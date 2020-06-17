pragma solidity >=0.4.22;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

//Call market with linked list which is implemented by mapping (with all functionalities and not just testing)

contract Orderbook_V29 {

function changetest() public{

    //test = BuyList[BuyHead.next].Price;
    if (BuyList[BuyHead].Price > SellList[SellHead].Price) {test= 10;}
}

    uint public test;



    struct Order
    {
      uint id;
      uint next;
      uint prev;
      uint Price;
      uint Volume;
      address Sender;
    }

    uint public countervariable;

    
    uint public SellHead;
    uint public SellTail;
    uint public SellistCounter;

    uint public BuyHead;
    uint public BuyTail;
    uint public BuyListCounter;
  
    mapping (uint => Order) public SellList;
    mapping (uint => Order) public BuyList;
    
    constructor() public 
    {
      SellHead = 0;
      SellTail = 0;
      SellistCounter = 1;
      BuyHead = 0;
      BuyTail = 0;
      BuyListCounter = 1;
      
      state = States.Settled;
    }
    uint public buytest;
    uint public selltest;
    //function testfunction () public{
      //buytest = SellList[SellList[SellHead].next].Price;
      //buytest = BuyList[SellHead].Price;
    //}
  enum States {Opened, Closed, Settled} 
    //Opened: biddingTime, Settlement has not yet started.
    //Closed: biddingTime’s over, Settlement’s satrted and not finished yet.
    //Settled: biddingTime and Settlement are both over , which means the auction is ended and everything is wiped and settled
    
    uint256 public CreationTime;
    uint256 public NumOrders;        //Number of all the orders within the auction
    //uint256 public BuyListCounter;   //the counter for BuyList which sorts the order incrementally
    //uint256 public SellListCounter;  //the counter for SellList which sorts the order decrementally
    States state;
    address public Token;            //The token that is being traded in the auction



    uint public biddingTime = 5 minutes;

    event LogBuyList (address _sender, uint _price, uint _volume);
    event TransferToken (address _from, address _to, uint256 _numofTokens);
    event TransferEther (address _from, address _to, uint256 _numofEther);
    event TradeHappens (uint256 _BuyPrice, uint _SellPrice);

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
    mapping(address => mapping(address => uint)) public TotalTokenBalance;
    mapping(address => mapping(address => uint)) public AvailableTokenBalance;
    //mapping(address => mapping(address => uint256)) public escrowExpiration;
    
    //User (Biders) => balance(Ether)
    mapping(address => uint) public TotalEtherBalance;
    mapping(address => uint) public AvailableEtherBalance;

//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _numofTokens) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _numofTokens));
        TotalTokenBalance[msg.sender][_token] += _numofTokens;
        AvailableTokenBalance[msg.sender][_token] += _numofTokens;
        return true;
    
    }
//**************DepositEther() Function*********************//    
    
    function DepositEther(uint256 _numofEthers) public payable returns (bool) {
        TotalEtherBalance[msg.sender] += _numofEthers;
        AvailableEtherBalance[msg.sender] += _numofEthers;
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
        //SellListCounter = 0;
        //BuyListCounter = 0;
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
  
        Order memory buytemp; 
        Order memory selltemp; 
        //SellList selltemp;
        //BuyList buytemp;
        //uint numerofeth;
        //uint numoftoken;
        while (BuyList[BuyHead].Price >= SellList[SellHead].Price) //while the list is not empty
         {
                
             countervariable++;
        //             //emit TradeHappens (BuyFirst.Price(), SellFirst.Price());
             selltemp = SellList[SellHead];
             buytemp =  BuyList[BuyHead];
        //             //numerofeth = SellFirst.Price();
        //             //numoftoken = BuyFirst.Volume();

             TotalTokenBalance[selltemp.Sender][_token] -= 1;
             TotalTokenBalance[buytemp.Sender][_token] += 1;
                     //AvailableTokenBalance[BuyFirst.Sender()][_token] += numoftoken;

             TotalEtherBalance[buytemp.Sender] -= selltemp.Price;
             TotalEtherBalance[selltemp.Sender] += selltemp.Price;
        //             //AvailableEtherBalance[SellFirst.Sender()] += numerofeth;

                
        //     //address(SellFirst).delegatecall(abi.encode(keccak256("deletenode(callmarket)")));
        //     //address(BuyFirst).delegatecall(abi.encode(keccak256("deletenode(callmarket)")));
        //     SellFirst.deletenode(callmarket);
        //     BuyFirst.deletenode(callmarket);
            //delete BuyList[BuyHead];
            //delete SellList[SellHead];
            if (selltemp.next == 0 || buytemp.next == 0) {break;}
            SellHead = selltemp.next;
            //SellList[SellHead] = SellList[selltemp.next];
            BuyHead = buytemp.next;
            //BuyList[BuyHead] = BuyList[buytemp.next];
       
                
            
         }
        
        
        
        
        
        state = States.Settled;
        return true;

        
    }
//******************** submitBid() function ********************//

    //The Bidder must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint _price, uint _volume) public returns (bool)
    {
        require (AvailableEtherBalance[msg.sender] >= _volume * _price );
        
       if (BuyListInsert(_price, _volume))
        {
            //BuyCounter++;
            NumOrders++;
            AvailableEtherBalance[msg.sender] -= _volume * _price;
        }
    
        return true;
    }

//******************** submitask() function ********************//

    //The Bidder must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint _price, uint _volume ) public  returns (bool)
    {
        require( AvailableTokenBalance[msg.sender][Token] >= _volume);
        
        if (SellListInsert(_price, _volume))
        {   
            //SellCounter++;
            NumOrders++;
            AvailableTokenBalance[msg.sender][Token] -= _volume;
        }

        return true;

    }                                                                                                                                                                                              


//*****************************************************************//
//*******************  BuyList Functions  ************************//
//*****************************************************************//
//******************** BuyListInsert() function ********************//    
    function BuyListInsert(uint _price, uint _volume) public returns (bool)
    {
      Order memory current = BuyList[BuyHead];
      while (current.id !=0 && _price <= current.Price) //The linkedlist is sorted in an desceding order (decreasing)
      {
        current = BuyList[current.next];
        // we only exit this loop if we find the position to insert our data;
      }  
      if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
      {
        BuyList_AddHead(_price, _volume);
      }
      else //the node next to the privious is no longer the current but it's our new node
      {
        BuyList_InsertAfter(current.prev, _price, _volume );           
      }
      return true; 
           
    }
    
//******************** BuyList_InsertAfter() function ********************//
  function BuyList_InsertAfter(uint256 _prevId, uint _price, uint _volume) internal returns (bool)
  {
    if (_prevId == BuyTail) 
    {
      BuyList_AddTail(_price, _volume);
    }
    else 
    {
      Order memory prevOrder = BuyList[_prevId];
      Order memory nextOrder = BuyList[prevOrder.next];
      uint newOrderId = BuyList_CreateObject(_price, _volume);
      BuyList_Link(newOrderId, nextOrder.id);
      BuyList_Link(prevOrder.id, newOrderId);  
    }
    return true;
    }
    
//******************** BuyList_AddTail() function ********************//
  function BuyList_AddTail(uint _price, uint _volume) internal returns (uint)
  {
    uint ordertId = BuyList_CreateObject(_price, _volume);
    BuyList_Link(BuyTail, ordertId);
    BuyList_SetTail(ordertId);
    return ordertId;
  }
//******************** BuyList_SetTail() function ********************//
  function BuyList_SetTail(uint _id) internal
  {
    BuyTail = _id;
  }
//******************** BuyList_AddHead() function ********************//
  function BuyList_AddHead(uint _price, uint _volume) internal returns (uint)
  {
    uint256 ordertId = BuyList_CreateObject(_price, _volume);
    BuyList_Link(ordertId, BuyHead);
    BuyList_SetHead(ordertId);
    if (BuyTail == 0) BuyList_SetTail(ordertId);
    return ordertId;
  }
//******************** BuyList_SetHead() function ********************//
  function BuyList_SetHead(uint _id) internal
  {
    BuyHead = _id;
  }      
    
//******************** BuyList_CreateObject() function ********************//
  function BuyList_CreateObject(uint _price, uint _volume) internal returns (uint)
  {
    uint256 newId = BuyListCounter;
    BuyListCounter += 1;
    Order memory order = Order( newId, 0, 0, _price, _volume, msg.sender);
    BuyList[order.id] = order;
    return order.id;
  }
//******************** BuyList_CreateObject() function ********************//
  function BuyList_Link(uint _prevId, uint _nextId) internal
  {
    BuyList[_prevId].next = _nextId;
    BuyList[_nextId].prev = _prevId;
        
  }

//*****************************************************************//
//*******************  SellList Functions  ************************//
//*****************************************************************//  
    
//******************** SellListInsert() function ********************//    
  function SellListInsert(uint _price, uint _volume) public returns (bool)
  {
        
    Order memory current = SellList[SellHead];
    while (current.id !=0 && _price >= current.Price) //The linkedlist is sorted in an ascending order (increasing)
    {
      current = SellList[current.next];
      // we only exit this loop if we find the position to insert our data;
    }  
    if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
    {
      SellList_AddHead(_price, _volume);
    }
    else //the node next to the privious is no longer the current but it's our new node
    {
      SellList_InsertAfter(current.prev, _price, _volume);           
    }
    return true; 
           
  }
    
//******************** SellList_InsertAfter() function ********************//
  function SellList_InsertAfter(uint256 _prevId, uint _price, uint _volume) internal returns (bool)
  {
    if (_prevId == SellTail) 
    {
      SellList_AddTail(_price, _volume);
    }
    else 
    {
      Order memory prevOrder = SellList[_prevId];
      Order memory nextOrder = SellList[prevOrder.next];
      uint newOrderId = SellList_CreateObject(_price, _volume);
      SellList_Link(newOrderId, nextOrder.id);
      SellList_Link(prevOrder.id, newOrderId);  
    }
    return true;
    }
    
//******************** SellList_AddTail() function ********************//
  function SellList_AddTail(uint _price, uint _volume) internal returns (uint)
  {
    uint ordertId = SellList_CreateObject(_price, _volume);
    SellList_Link(SellTail, ordertId);
    SellList_SetTail(ordertId);
    return ordertId;
  }
//******************** SellList_SetTail() function ********************//
  function SellList_SetTail(uint _id) internal
  {
    SellTail = _id;
  }
//******************** SellList_AddHead() function ********************//
  function SellList_AddHead(uint _price, uint _volume) internal returns (uint)
  {
    uint256 ordertId = SellList_CreateObject(_price, _volume);
    SellList_Link(ordertId, SellHead);
    SellList_SetHead(ordertId);
    if (SellTail == 0) SellList_SetTail(ordertId);
    return ordertId;
  }
//******************** SellList_SetHead() function ********************//
  function SellList_SetHead(uint _id) internal
  {
    SellHead = _id;
  }      
    
//******************** SellList_CreateObject() function ********************//
  function SellList_CreateObject(uint _price, uint _volume) internal returns (uint)
  {
    uint256 newId = SellistCounter;
    SellistCounter += 1;
    Order memory order = Order( newId, 0, 0, _price, _volume, msg.sender);
    SellList[order.id] = order;
    return order.id;
  }
//******************** SellList_CreateObject() function ********************//
  function SellList_Link(uint _prevId, uint _nextId) internal
  {
    SellList[_prevId].next = _nextId;
    SellList[_nextId].prev = _prevId;
        
  }






}
    
    
    