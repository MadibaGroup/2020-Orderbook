pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

//Linkedlist implemented with mapping wrapped in a priority queue
//Maximum number of order the Match function can handle : 18

contract PQ5_Linkedlist_Mapping{
    
    constructor() public 
    {
        
        BuyHead = 0;
        BuyTail = 0;
        BuyListCounter = 1;

    }
    

    struct OrderStruct
    {
        uint256 Price;
        bool Exists;
        uint256 id;
        uint256 next;
        uint256 prev;
    }

    

    uint256 public BuyHead;
    uint256 public BuyTail;
    uint256 public BuyListCounter;
  
    
    mapping (uint256 => OrderStruct) public BuyList;
    
   
    uint256 public test;
//******************** InsertBid() function ********************//
    //A new buy order will be added in its right position in the list
    function InsertBid(uint256 _price) public returns (bool)
    {
     
        if (BuyList[BuyHead].Exists == false)
        {
            BuyList_AddHead(_price);
            return true;
        }
        
        OrderStruct memory current = BuyList[BuyHead];
        while (current.id != BuyTail &&  _price < current.Price)
        {
            
                current = BuyList[current.next];

            
        
            // we only exit this loop if we find the position to insert our data;
        }  
        
        if (current.id == BuyHead && _price < current.Price)
        {
            BuyList_InsertAfter(current.id, _price );
            return true;
        }
        
        if (current.id == BuyHead && _price > current.Price)
        {
            BuyList_InsertBefore(current.id, _price );
            return true;
        }
        
        if (current.id == BuyTail && _price < current.Price)
        {
            BuyList_InsertAfter(current.id, _price );
            return true;
        }
        
        if (current.id == BuyTail && _price > current.Price)
        {
            BuyList_InsertBefore(current.id, _price );
            return true;
        }
        
      
        
        BuyList_InsertBefore(current.id, _price );
        return true;   
         

        //if (current.id == 1) //it means the current is equal to first and in that case we have to insert the node as a new head
        //{
            //BuyList_AddHead(_price);
        //}
        //else //the node next to the privious is no longer the current but it's our new node
        //{
            //uint id = BuyList_InsertAfter(current.prev, _price );    
            //BuyList_SetHead(id);       
        //}
         
    }    

//******************** BuyList_InsertAfter() function ********************//
    function BuyList_InsertAfter(uint256 _prevId, uint256 _price) internal 
    {
        
        if (_prevId == BuyTail) {
            BuyList_AddTail(_price);
        }
        else{
            
        
            OrderStruct memory prevOrder = BuyList[_prevId];
            OrderStruct memory nextOrder = BuyList[prevOrder.next];
            uint256 newOrderId = BuyList_CreateObject(_price);
            BuyList_Link(newOrderId, nextOrder.id);
            BuyList_Link(prevOrder.id, newOrderId);  
        }
        
        
    }

    function BuyList_InsertBefore(uint256 _nextId, uint256 _price) internal returns (bool)
    {
        if (_nextId == BuyHead) {
            BuyList_AddHead(_price);
        }
        else {
            BuyList_InsertAfter(BuyList[_nextId].prev, _price);
        }
        return true;
    }
    
//******************** BuyList_AddTail() function ********************//
    function BuyList_AddTail(uint256 _price) internal returns (bool)
    {
        
        if (BuyHead == 0) {
            BuyList_AddHead(_price);
        }
        else {
            uint256 ordertId = BuyList_CreateObject(_price);
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
    function BuyList_AddHead(uint256 _price) internal returns (uint256)
    {
        uint256 ordertId = BuyList_CreateObject(_price);
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
    function BuyList_CreateObject(uint256 _price) internal returns (uint256)
    {
        uint256 newId = BuyListCounter;
        BuyListCounter ++;
        OrderStruct memory order = OrderStruct(  _price, true, newId, 0, 0);
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

//******************** BuyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    function BuyListMaxDelete() public returns (uint256)
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
        
        delete BuyList[removeObject.id];
        return (_price);
    
    }

        
    






//****************   BuyListisEmpty()  *********************//
    //checks if the BUyList is empty
    function BuyListisEmpty() public returns (bool){
        
        if (BuyList[BuyHead].next == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }













}