//pragma solidity >=0.4.22;
pragma solidity 0.5.12;

//Linkedlist implemented with mapping wrapped in a priority queue

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
    
    

//******************** InsertBid() function ********************//
    //A new buy order will be added in its right position in the list
    function InsertBid(address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public returns (bool)
    {
       OrderStruct memory current = BuyList[BuyHead];
        while (current.id !=0 && _auxprice <= current.AuxPrice) //The linkedlist is sorted in an desceding order (decreasing)
        {
            current = BuyList[current.next];
            // we only exit this loop if we find the position to insert our data;
        }  
        if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            BuyList_AddHead(_sender, _price, _volume, _auxprice);
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
            BuyList_InsertAfter(current.prev, _sender, _price, _volume, _auxprice );           
        }
        return true; 
       
    
    }    

//******************** BuyList_InsertAfter() function ********************//
    function BuyList_InsertAfter(uint256 _prevId, address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) internal returns (bool)
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
        return true;
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
    function BuyList_SetTail(uint256 _id) internal returns(bool)
    {
        BuyTail = _id;
        return true;
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
    function BuyList_SetHead(uint256 _id) internal returns(bool)
    {
        BuyHead = _id;
        return true;
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
        
        require (BuyHead != 0, 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[BuyHead].Price);
        
    }
//****************   BuyListMaxSender()  *********************//
    //BuyListMaxSender function returns the sender of the highest priority element (The highest bid)
    function BuyListMaxSender() public  returns (address){
        
        require (BuyHead != 0, 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[BuyHead].Sender);
        
    }
//******************** BuyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    function BuyListMaxDelete() public returns (uint256, address)
    {
        
        OrderStruct memory removeObject = BuyList[BuyHead];
        uint256 _price =  removeObject.Price;
        address _sender = removeObject.Sender;

        if (BuyTail == BuyHead)
        {
            BuyHead = 0;
            BuyTail = 0;
            
        }
        else
        {
            BuyHead = removeObject.next;
            BuyList[removeObject.next].prev = 0;
            
        }
        
        delete BuyList[removeObject.id];
        return (_price,_sender); 
        
        


        /* OrderStruct memory removeObject = BuyList[BuyHead];
        BuyList_SetHead(removeObject.next);
        BuyList[removeObject.next].prev = 0;
        
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
        return (_price,_sender); */
    
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
        OrderStruct memory current = SellList[SellHead];
        while (current.id !=0 && _auxprice >= current.AuxPrice) //The linkedlist is sorted in an ascending order (increasing)
        {
        current = SellList[current.next];
        // we only exit this loop if we find the position to insert our data;
        }  
        if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            SellList_AddHead(_sender, _price, _volume, _auxprice);
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
        SellList_InsertAfter(current.prev, _sender, _price, _volume, _auxprice);           
        }
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
//******************** SellList_InsertBefore() function ********************//
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
    function SellList_SetTail(uint256 _id) internal returns(bool)
    {
        SellTail = _id;
        return true;
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
    function SellList_SetHead(uint256 _id) internal returns (bool)
    {
        SellHead = _id;
        return true;
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
    function SellList_Link(uint256 _prevId, uint256 _nextId) internal returns (bool)
    {
        SellList[_prevId].next = _nextId;
        SellList[_nextId].prev = _prevId;
        return true;    
    }
//****************   SellListMaxPrice()  *********************//
    //SellListMaxPrice function returns the price of the highest priority element (The Lowest ask)
    function SellListMaxPrice() public  returns (uint256){

        require(SellHead != 0,'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellList[SellHead].Price);
    }
//****************   SellListMaxSender()  *********************//
    //SellListMaxSender function returns the sender of the highest priority element (The Lowest ask)
    function SellListMaxSender() public  returns (address){

        require(SellHead != 0,'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellList[SellHead].Sender);
    }
//*******************  SellListMaxDelete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    function SellListMaxDelete() public returns (uint256, address)
    {
        

        
        OrderStruct memory removeObject = SellList[SellHead];
        uint256 _price =  removeObject.Price;
        address _sender = removeObject.Sender;

        if (SellTail == SellHead)
        {
            SellHead = 0;
            SellTail = 0;
            
        }
        else
        {
            SellHead = removeObject.next;
            SellList[removeObject.next].prev = 0;
            
        }
        
        delete SellList[removeObject.id];
        return (_price,_sender); 
    

        /* OrderStruct memory removeObject = SellList[SellHead];
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
        return (_price,_sender); */
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

//****************   deletePQ()  *********************//
    function deletePQ (address payable _callmarket) public {
        selfdestruct(_callmarket);
    }


}