pragma solidity >=0.4.22;

//import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract Orderbook_V28 {

  struct Order
  {
    uint id;
    uint next;
    uint prev;
    uint Price;
  }

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
  }
  uint public buytest;
  uint public selltest;
  function testfunction () public{
    //buytest = SellList[SellList[SellHead].next].Price;
    buytest = BuyList[SellHead].Price;
  }

//*****************************************************************//
//*******************  BuyList Functions  ************************//
//*****************************************************************//
//******************** BuyListInsert() function ********************//    

  function BuyListInsert(uint _price) public returns (bool)
  {
        
    Order memory current = BuyList[BuyHead];
    while (current.id !=0 && _price <= current.Price) //The linkedlist is sorted in an desceding order (decreasing)
    {
      current = BuyList[current.next];
      // we only exit this loop if we find the position to insert our data;
    }  
    if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
    {
      BuyList_AddHead(_price);
    }
    else //the node next to the privious is no longer the current but it's our new node
    {
      BuyList_InsertAfter(current.prev, _price);           
    }
    return true; 
           
  }
    
//******************** BuyList_InsertAfter() function ********************//
  function BuyList_InsertAfter(uint256 _prevId, uint _price) internal returns (bool)
  {
    if (_prevId == BuyTail) 
    {
      BuyList_AddTail(_price);
    }
    else 
    {
      Order memory prevOrder = BuyList[_prevId];
      Order memory nextOrder = BuyList[prevOrder.next];
      uint newOrderId = BuyList_CreateObject(_price);
      BuyList_Link(newOrderId, nextOrder.id);
      BuyList_Link(prevOrder.id, newOrderId);  
    }
    return true;
    }
    
//******************** BuyList_AddTail() function ********************//
  function BuyList_AddTail(uint _price) internal returns (uint)
  {
    uint ordertId = BuyList_CreateObject(_price);
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
  function BuyList_AddHead(uint _price) internal returns (uint)
  {
    uint256 ordertId = BuyList_CreateObject(_price);
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
  function BuyList_CreateObject(uint _price) internal returns (uint)
  {
    uint256 newId = BuyListCounter;
    BuyListCounter += 1;
    Order memory order = Order( newId, 0, 0, _price);
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
  function SellListInsert(uint _price) public returns (bool)
  {
        
    Order memory current = SellList[SellHead];
    while (current.id !=0 && _price >= current.Price) //The linkedlist is sorted in an ascending order (increasing)
    {
      current = SellList[current.next];
      // we only exit this loop if we find the position to insert our data;
    }  
    if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
    {
      SellList_AddHead(_price);
    }
    else //the node next to the privious is no longer the current but it's our new node
    {
      SellList_InsertAfter(current.prev, _price);           
    }
    return true; 
           
  }
    
//******************** SellList_InsertAfter() function ********************//
  function SellList_InsertAfter(uint256 _prevId, uint _price) internal returns (bool)
  {
    if (_prevId == SellTail) 
    {
      SellList_AddTail(_price);
    }
    else 
    {
      Order memory prevOrder = SellList[_prevId];
      Order memory nextOrder = SellList[prevOrder.next];
      uint newOrderId = SellList_CreateObject(_price);
      SellList_Link(newOrderId, nextOrder.id);
      SellList_Link(prevOrder.id, newOrderId);  
    }
    return true;
    }
    
//******************** SellList_AddTail() function ********************//
  function SellList_AddTail(uint _price) internal returns (uint)
  {
    uint ordertId = SellList_CreateObject(_price);
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
  function SellList_AddHead(uint _price) internal returns (uint)
  {
    uint256 ordertId = SellList_CreateObject(_price);
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
  function SellList_CreateObject(uint _price) internal returns (uint)
  {
    uint256 newId = SellistCounter;
    SellistCounter += 1;
    Order memory order = Order( newId, 0, 0, _price);
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
    
    
    