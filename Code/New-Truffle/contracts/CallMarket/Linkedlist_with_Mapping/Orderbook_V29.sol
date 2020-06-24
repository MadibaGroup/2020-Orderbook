pragma solidity >=0.4.22;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

// The last vesrion of the call market qith by linkedlist that is implemented by mapping
//Maximum number of order the Match function can handle : 250
contract Orderbook_V29 {

    function changetest() public
    {
        test = BuyList[BuyHead].Price;
        //if (BuyList[BuyHead].Price > SellList[SellHead].Price) {test= 10;}
    }

    uint256 public test;
   


    struct Order
    {
      uint256 id;
      uint256 next;
      uint256 prev;
      uint256 Price;
      uint256 Volume;
      address Sender;
    }

    uint256 public countervariable;

    
    uint256 public SellHead;
    uint256 public SellTail;
    uint256 public SellistCounter;

    uint256 public BuyHead;
    uint256 public BuyTail;
    uint256 public BuyListCounter;
  
    mapping (uint256 => Order) public SellList;
    mapping (uint256 => Order) public BuyList;
    
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
    uint256 public buytest;
    uint256 public selltest;
    
    enum States {Opened, Closed, Settled} 
    //Opened: biddingTime, Settlement has not yet started.
    //Closed: biddingTime’s over, Settlement’s satrted and not finished yet.
    //Settled: biddingTime and Settlement are both over , which means the auction is ended and everything is wiped and settled
    
    uint256 public CreationTime;
    uint256 public NumOrders;        //Number of all the orders within the auction
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
    function OpenMarket(address _token) public  AuctionAtStage(States.Settled) returns (bool) {

        CreationTime = now; 
        state = States.Opened;
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
    
        while (BuyList[BuyHead].Price >= SellList[SellHead].Price) //while the list is not empty
        {
            countervariable++;
            //emit TradeHappens (BuyFirst.Price(), SellFirst.Price());
            selltemp = SellList[SellHead];
            buytemp =  BuyList[BuyHead];
 
            TokenBalance[buytemp.Sender][_token] += 1;
            EtherBalance[selltemp.Sender] += selltemp.Price;

            //delete BuyList[BuyHead];
            //delete SellList[SellHead];
            if (selltemp.next == 0 || buytemp.next == 0) {break;}
            SellHead = selltemp.next;
            BuyHead = buytemp.next;
            
        }
        // if (BuyList[BuyHead].next != 0)
        // {
        //     BuyHead = BuyList[BuyHead].next;
        //     //Rrefund_unexecuted_Buy_orders();
        // }
        
        // if (SellList[SellHead].next != 0)
        // {
        //    SellHead = SellList[SellHead].next; 
            //Rrefund_unexecuted_Sell_orders(); 
        // }
        
        state = States.Settled;
        return true;    
    }
//******************** Rrefund_unexecuted_Buy_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "Ethers" for those trades that did not happen
    // function Rrefund_unexecuted_Buy_orders () internal returns (bool) {

    //     while (BuyList[BuyHead].next != 0)
    //     {
    //       Order memory buytemp = BuyList[BuyHead];
            //EtherBalance[buytemp.Sender] += 1 * buytemp.Price;

    //         BuyHead = buytemp.next;
            
    //     }
        
    //     return true;
    // }
    
    // //******************** Rrefund_unexecuted_Sell_orders function ********************//
    // //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "tokens" for those trades that did not happen
    // function Rrefund_unexecuted_Sell_orders () internal returns (bool) {
        
        
    //     while (SellList[SellHead].next != 0)
    //     {
    //         Order memory selltemp = SellList[SellHead];
    //         TokenBalance[selltemp.Sender][Token] += selltemp.Volume;
    //         
    //         SellHead = selltemp.next;
           
            
    //     }
        
    //     return true;
    // }

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
    //must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint256 _price, uint256 _volume) public returns (bool)
    {
        require (EtherBalance[msg.sender] >= _volume * _price , 'There is not enough Ether in the account');
        
       if (BuyListInsert(_price, _volume))
        {
            NumOrders++;
            EtherBalance[msg.sender] -= _volume * _price;
        }
        return true;
    }
//******************** submitask() function ********************//
    //must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint256 _price, uint256 _volume ) public  returns (bool)
    {
        require(TokenBalance[msg.sender][Token] >= _volume, 'There is not enough tokens in the account');
        
        if (SellListInsert(_price, _volume))
        {   
            NumOrders++;
            TokenBalance[msg.sender][Token] -= _volume;
        }
        return true;
    }                                                                                                                                                                                              

//*****************************************************************//
//*******************  BuyList Functions  ************************//
//*****************************************************************//
//******************** BuyListInsert() function ********************//    
    function BuyListInsert(uint256 _price, uint256 _volume) public returns (bool)
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
    function BuyList_InsertAfter(uint256 _prevId, uint256 _price, uint256 _volume) internal returns (bool)
    {
        if (_prevId == BuyTail) 
        {
            BuyList_AddTail(_price, _volume);
        }
        else 
        {
        Order memory prevOrder = BuyList[_prevId];
        Order memory nextOrder = BuyList[prevOrder.next];
        uint256 newOrderId = BuyList_CreateObject(_price, _volume);
        BuyList_Link(newOrderId, nextOrder.id);
        BuyList_Link(prevOrder.id, newOrderId);  
        }
        return true;
    }
    
//******************** BuyList_AddTail() function ********************//
    function BuyList_AddTail(uint256 _price, uint256 _volume) internal returns (uint256)
    {
        uint256 ordertId = BuyList_CreateObject(_price, _volume);
        BuyList_Link(BuyTail, ordertId);
        BuyList_SetTail(ordertId);
        return ordertId;
    }
//******************** BuyList_SetTail() function ********************//
    function BuyList_SetTail(uint256 _id) internal
    {
        BuyTail = _id;
    }
//******************** BuyList_AddHead() function ********************//
    function BuyList_AddHead(uint256 _price, uint256 _volume) internal returns (uint256)
    {
        uint256 ordertId = BuyList_CreateObject(_price, _volume);
        BuyList_Link(ordertId, BuyHead);
        BuyList_SetHead(ordertId);
        if (BuyTail == 0) BuyList_SetTail(ordertId);
        return ordertId;
    }
//******************** BuyList_SetHead() function ********************//
    function BuyList_SetHead(uint256 _id) internal
    {
        BuyHead = _id;
    }      
    
//******************** BuyList_CreateObject() function ********************//
    function BuyList_CreateObject(uint256 _price, uint256 _volume) internal returns (uint256)
    {
        uint256 newId = BuyListCounter;
        BuyListCounter += 1;
        Order memory order = Order( newId, 0, 0, _price, _volume, msg.sender);
        BuyList[order.id] = order;
        return order.id;
    }
//******************** BuyList_CreateObject() function ********************//
    function BuyList_Link(uint256 _prevId, uint256 _nextId) internal
    {
        BuyList[_prevId].next = _nextId;
        BuyList[_nextId].prev = _prevId;   
    }

//*****************************************************************//
//*******************  SellList Functions  ************************//
//*****************************************************************//  
    
//******************** SellListInsert() function ********************//    
    function SellListInsert(uint256 _price, uint256 _volume) public returns (bool)
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
    function SellList_InsertAfter(uint256 _prevId, uint256 _price, uint256 _volume) internal returns (bool)
    {
        if (_prevId == SellTail) 
        {
            SellList_AddTail(_price, _volume);
        }
        else 
        {
            Order memory prevOrder = SellList[_prevId];
            Order memory nextOrder = SellList[prevOrder.next];
            uint256 newOrderId = SellList_CreateObject(_price, _volume);
            SellList_Link(newOrderId, nextOrder.id);
            SellList_Link(prevOrder.id, newOrderId);  
        }
        return true;
    }
    
//******************** SellList_AddTail() function ********************//
    function SellList_AddTail(uint256 _price, uint256 _volume) internal returns (uint256)
    {
        uint256 ordertId = SellList_CreateObject(_price, _volume);
        SellList_Link(SellTail, ordertId);
        SellList_SetTail(ordertId);
        return ordertId;
    }
//******************** SellList_SetTail() function ********************//
    function SellList_SetTail(uint256 _id) internal
    {
        SellTail = _id;
    }
//******************** SellList_AddHead() function ********************//
    function SellList_AddHead(uint256 _price, uint256 _volume) internal returns (uint256)
    {
        uint256 ordertId = SellList_CreateObject(_price, _volume);
        SellList_Link(ordertId, SellHead);
        SellList_SetHead(ordertId);
        if (SellTail == 0) SellList_SetTail(ordertId);
        return ordertId;
    }
//******************** SellList_SetHead() function ********************//
    function SellList_SetHead(uint256 _id) internal
    {
        SellHead = _id;
    }      
//******************** SellList_CreateObject() function ********************//
    function SellList_CreateObject(uint256 _price, uint256 _volume) internal returns (uint256)
    {
        uint256 newId = SellistCounter;
        SellistCounter += 1;
        Order memory order = Order( newId, 0, 0, _price, _volume, msg.sender);
        SellList[order.id] = order;
        return order.id;
    }
//******************** SellList_CreateObject() function ********************//
    function SellList_Link(uint256 _prevId, uint256 _nextId) internal
    {
        SellList[_prevId].next = _nextId;
        SellList[_nextId].prev = _prevId;    
    }






}
    
    
    