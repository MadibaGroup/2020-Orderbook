pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

//Linkedlist implemented with mapping wrapped in a priority queue
//Maximum number of order the Match function can handle : 18

contract PQ5_Linkedlist_Mapping{
    
    constructor() public 
    {
        SellHead = 0;
        SellTail = 0;
        SellistCounter = 1;
        BuyHead = 0;
        BuyTail = 0;
        BuyListCounter = 1;

    }
    

    struct OrderStruct
    {
        address Sender;
        uint256 Price;
        uint256 Volume;     //The volume is 1 for now
        bool Exists;
        uint256 AuxPrice;   //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
        uint256 id;
        uint256 next;
        uint256 prev;
    }

    uint256 public SellHead;
    uint256 public SellTail;
    uint256 public SellistCounter;

    uint256 public BuyHead;
    uint256 public BuyTail;
    uint256 public BuyListCounter;
  
    mapping (uint256 => OrderStruct) public SellList;
    mapping (uint256 => OrderStruct) public BuyList;
    
    uint256 public test1;
    uint256 public test2;
    uint256 public test3;
    function testfunction1() public returns (uint256){
        //return BuyList[BuyList[BuyList[BuyHead].next].next].Price;
        return SellList[SellHead].Price;

    }
    function testfunction2() public returns (uint256){
        return SellList[SellHead].Price;

    }

//******************** InsertBid() function ********************//
    //A new buy order will be added in its right position in the list
    function InsertBid(address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public returns (bool)
    {
        if (BuyList[BuyHead].Exists == false)
        {
            BuyList_AddHead( _sender,  _price,  _volume,  _auxprice);
            return true;
        }
        
        
        OrderStruct memory current = BuyList[BuyHead];
        while (current.id != BuyTail &&  _price < current.Price)
        {  current = BuyList[current.next]; }  
        
        if (current.id == BuyHead && _price < current.Price)
        {
            BuyList_InsertAfter(current.id, _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
        if (current.id == BuyHead && _price > current.Price)
        {
            BuyList_InsertBefore(current.id, _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
        if (current.id == BuyTail && _price < current.Price)
        {
            BuyList_InsertAfter(current.id, _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
        if (current.id == BuyTail && _price > current.Price)
        {
            BuyList_InsertBefore(current.id,  _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
      
        BuyList_InsertBefore(current.id,  _sender, _price,  _volume,  _auxprice );
        return true;   
    }    

//******************** BuyList_InsertAfter() function ********************//
    function BuyList_InsertAfter(uint256 _prevId, address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal 
    {
        
        if (_prevId == BuyTail) {
            BuyList_AddTail(_sender,_price, _volume, _auxprice);
        }
        else{
            OrderStruct memory prevOrder = BuyList[_prevId];
            OrderStruct memory nextOrder = BuyList[prevOrder.next];
            uint256 newOrderId = BuyList_CreateObject(_sender,_price, _volume, _auxprice);
            BuyList_Link(newOrderId, nextOrder.id);
            BuyList_Link(prevOrder.id, newOrderId);  
        }
        
    }
//******************** BuyList_InsertBefore() function ********************//
    function BuyList_InsertBefore(uint256 _nextId, address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (bool)
    {
        if (_nextId == BuyHead) {
            BuyList_AddHead(_sender,_price, _volume, _auxprice);
        }
        else {
            BuyList_InsertAfter(BuyList[_nextId].prev, _sender, _price, _volume, _auxprice);
        }
        return true;
    }
    
//******************** BuyList_AddTail() function ********************//
    function BuyList_AddTail(address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (bool)
    {
        
        if (BuyHead == 0) {
            BuyList_AddHead(_sender, _price, _volume, _auxprice);
        }
        else {
            uint256 ordertId = BuyList_CreateObject(_sender, _price, _volume, _auxprice);
            BuyList_Link(BuyTail, ordertId);
            BuyList_SetTail(ordertId);
        }
        
        return true;
    }
//******************** BuyList_SetTail() function ********************//
    function BuyList_SetTail(uint256 _id) internal
    {
        BuyTail = _id;
    }
//******************** BuyList_AddHead() function ********************//
    function BuyList_AddHead(address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (uint256)
    {
        uint256 ordertId = BuyList_CreateObject(_sender, _price, _volume, _auxprice);
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
    function BuyList_CreateObject(address _sender,uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (uint256)
    {
        uint256 newId = BuyListCounter;
        BuyListCounter ++;
        OrderStruct memory order = OrderStruct(_sender, _price, _volume, true, _auxprice, newId, 0, 0);
        BuyList[order.id] = order;
        return order.id;
    }
//******************** BuyList_CreateObject() function ********************//
    function BuyList_Link(uint256 _prevId, uint256 _nextId) internal
    {
        BuyList[_prevId].next = _nextId;
        BuyList[_nextId].prev = _prevId;   
    }
//****************   BuyListMaxPrice()  *********************//
    //BuyListMaxPrice function returns the price of the highest priority element (The highest bid)
    function BuyListMaxPrice() public  returns (uint256){
        
        //require (BuyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[BuyHead].Price);
        
    }
//****************   BuyListMaxSender()  *********************//
    //BuyListMaxSender function returns the sender of the highest priority element (The highest bid)
    function BuyListMaxSender() public  returns (address){
        
        //require (BuyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[BuyHead].Sender);
        
    }
//******************** BuyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    function BuyListMaxDelete() public returns (uint256, address)
    {
        /* //require (BuyHead != 0, 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        //OrderStruct memory buytemp = BuyList[BuyHead];
        uint256 _price =  BuyList[BuyHead].Price;
        address _sender =  BuyList[BuyHead].Sender;
        //delete BuyList[BuyHead];
        BuyHead = BuyList[BuyHead].next;
        return(_price, _sender); */
        OrderStruct memory removeObject = BuyList[BuyHead];
        if (BuyTail == BuyHead)
        {
            BuyList_SetHead(0);
            BuyList_SetTail(0);
        }
        else
        {
            BuyList_SetHead(removeObject.next);
            BuyList[removeObject.next].prev = 0;
            BuyList_Link(removeObject.prev, removeObject.next);
        }
        uint256 _price =  removeObject.Price;
        address _sender = removeObject.Sender;
        delete BuyList[removeObject.id];
        return (_price,_sender);
    
    }

        
    






//****************   BuyListisEmpty()  *********************//
    //checks if the BUyList is empty
    function BuyListisEmpty() public returns (bool){
        
        if (BuyHead == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }

//*******************  InsertAsk () ***************************//
    //A new buy order will be added in its right position in the list
    function InsertAsk (address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public returns (bool)
    {
        
        if (SellList[SellHead].Exists == false)
        {
            SellList_AddHead( _sender,  _price,  _volume,  _auxprice);
            return true;
        }
        
        
        OrderStruct memory current = SellList[SellHead];
        while (current.id != SellTail &&  _price > current.Price)
        {  current = SellList[current.next]; }  
        
        if (current.id == SellHead && _price > current.Price)
        {
            SellList_InsertAfter(current.id, _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
        if (current.id == SellHead && _price < current.Price)
        {
            SellList_InsertBefore(current.id, _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
        if (current.id == SellTail && _price > current.Price)
        {
            SellList_InsertAfter(current.id, _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
        if (current.id == SellTail && _price < current.Price)
        {
            SellList_InsertBefore(current.id,  _sender, _price,  _volume,  _auxprice );
            return true;
        }
        
      
        SellList_InsertBefore(current.id,  _sender, _price,  _volume,  _auxprice );
        return true;         
    }
//******************** SellList_InsertAfter() function ********************//
    function SellList_InsertAfter(uint256 _prevId, address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (bool)
    {
        if (_prevId == SellTail) 
        {
            SellList_AddTail(_sender, _price, _volume, _auxprice);
        }
        else 
        {
            OrderStruct memory prevOrder = SellList[_prevId];
            OrderStruct memory nextOrder = SellList[prevOrder.next];
            uint256 newOrderId = SellList_CreateObject(_sender, _price, _volume, _auxprice);
            SellList_Link(newOrderId, nextOrder.id);
            SellList_Link(prevOrder.id, newOrderId);  
        }
        return true;
    }
    function SellList_InsertBefore(uint256 _nextId, address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (bool)
    {
        if (_nextId == SellHead) {
            SellList_AddHead(_sender, _price, _volume, _auxprice);
        }
        else {
            SellList_InsertAfter(SellList[_nextId].prev, _sender, _price, _volume, _auxprice);
        }
        return true;
    }
//******************** SellList_AddTail() function ********************//
    function SellList_AddTail(address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (bool)
    {
        if (SellHead == 0) {
            SellList_AddHead(_sender, _price, _volume, _auxprice);
        }
        else {
            uint256 ordertId = SellList_CreateObject(_sender, _price, _volume, _auxprice);
            SellList_Link(SellTail, ordertId);
            SellList_SetTail(ordertId);
        }
        
        return true;
    }
//******************** SellList_SetTail() function ********************//
    function SellList_SetTail(uint256 _id) internal
    {
        SellTail = _id;
    }
//******************** SellList_AddHead() function ********************//
    function SellList_AddHead(address _sender,uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (uint256)
    {
        uint256 ordertId = SellList_CreateObject(_sender, _price, _volume, _auxprice);
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
    function SellList_CreateObject(address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (uint256)
    {
        uint256 newId = SellistCounter;
        SellistCounter ++;
        OrderStruct memory order =  OrderStruct( _sender , _price, _volume, true, _auxprice, newId, 0, 0);
        SellList[order.id] = order;
        return order.id;
    }
//******************** SellList_CreateObject() function ********************//
    function SellList_Link(uint256 _prevId, uint256 _nextId) internal
    {
        SellList[_prevId].next = _nextId;
        SellList[_nextId].prev = _prevId;    
    }
//****************   SellListMaxPrice()  *********************//
    //SellListMaxPrice function returns the price of the highest priority element (The Lowest ask)
    function SellListMaxPrice() public  returns (uint256){

        //require(SellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellList[SellHead].Price);
    }
//****************   SellListMaxSender()  *********************//
    //SellListMaxSender function returns the sender of the highest priority element (The Lowest ask)
    function SellListMaxSender() public  returns (address){

        //require(SellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellList[SellHead].Sender);
    }
//*******************  minheap_delete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    function SellListMaxDelete() public returns (uint256, address)
    {
        /* //require(SellHead != 0,'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        //OrderStruct memory selltemp; 
        //selltemp = SellList[SellHead];
        uint256 _price =  SellList[SellHead].Price;
        address _sender =  SellList[SellHead].Sender;
        //delete SellList[SellHead];
        //SellList_SetHead( SellList[SellHead].next);
        SellHead = SellList[SellHead].next;
        return (_price,_sender); */
        OrderStruct memory removeObject = SellList[SellHead];
        if (SellTail == SellHead)
        {
            SellList_SetHead(0);
            SellList_SetTail(0);
        }
        else
        {
            SellList_SetHead(removeObject.next);
            SellList[removeObject.next].prev = 0;
        }
        uint256 _price =  removeObject.Price;
        address _sender =  removeObject.Sender;
        delete SellList[removeObject.id];
        return (_price,_sender);
    }

        
    
//****************   SellListisEmpty()  *********************//
    //checks if the SellList is empty
    function SellListisEmpty() public returns (bool){
        
        if (SellHead == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }











}