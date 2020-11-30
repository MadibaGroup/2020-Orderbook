pragma solidity >=0.4.22;
//pragma solidity 0.5.12;

//Linkedlist implemented with mapping wrapped in a priority queue

contract LinkedListMapping{
    

    constructor() public 
    {
        sellHead = 0;
        sellTail = 0;
        sellistCounter = 1;
        buyHead = 0;
        buyTail = 0;
        buyListCounter = 1;
        

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

    uint256 public sellHead;
    uint256 public sellTail;
    uint256 public sellistCounter;

    uint256 public buyHead;
    uint256 public buyTail;
    uint256 public buyListCounter;
  
    mapping (uint256 => OrderStruct) public sellList;
    mapping (uint256 => OrderStruct) public buyList;
    
    

//******************** insertBid() function ********************//
    //A new buy order will be added in its right position in the list
    function insertBid(address sender, uint256 price, uint256 volume, uint256 auxprice) external 
    {
       OrderStruct memory current = buyList[buyHead];
        while (current.id !=0 && auxprice <= current.AuxPrice) //The linkedlist is sorted in an desceding order (decreasing)
        {
            current = buyList[current.next];
            // we only exit this loop if we find the position to insert our data;
        }  
        if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            buyListAddHead(sender, price, volume, auxprice);
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
            buyListInsertAfter(current.prev, sender, price, volume, auxprice );           
        }
        
       
    
    }    

//******************** buyListInsertAfter() function ********************//
    function buyListInsertAfter(uint256 prevId, address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (bool)
    {
        
        if (prevId == buyTail) {
            buyListAddTail(sender,price, volume, auxprice);
        }
        else{
            OrderStruct memory prevOrder = buyList[prevId];
            OrderStruct memory nextOrder = buyList[prevOrder.next];
            uint256 newOrderId = buyListCreateObject(sender,price, volume, auxprice);
            buyListLink(newOrderId, nextOrder.id);
            buyListLink(prevOrder.id, newOrderId);  
        }
        return true;
    }
//******************** buyListInsertBefore() function ********************//
    function buyListInsertBefore(uint256 nextId, address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (bool)
    {
        if (nextId == buyHead) {
            buyListAddHead(sender,price, volume, auxprice);
        }
        else {
            buyListInsertAfter(buyList[nextId].prev, sender, price, volume, auxprice);
        }
        return true;
    }
    
//******************** buyListAddTail() function ********************//
    function buyListAddTail(address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (bool)
    {
        
        if (buyHead == 0) {
            buyListAddHead(sender, price, volume, auxprice);
        }
        else {
            uint256 ordertId = buyListCreateObject(sender, price, volume, auxprice);
            buyListLink(buyTail, ordertId);
            buyListSetTail(ordertId);
        }
        
        return true;
    }
//******************** buyListSetTail() function ********************//
    function buyListSetTail(uint256 id) internal returns(bool)
    {
        buyTail = id;
        return true;
    }
//******************** buyListAddHead() function ********************//
    function buyListAddHead(address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (uint256)
    {
        uint256 ordertId = buyListCreateObject(sender, price, volume, auxprice);
        buyListLink(ordertId, buyHead);
        buyListSetHead(ordertId);
        if (buyTail == 0) buyListSetTail(ordertId);
        return ordertId;
    }
//******************** buyListSetHead() function ********************//
    function buyListSetHead(uint256 id) internal returns(bool)
    {
        buyHead = id;
        return true;
    }      
    
//******************** buyListCreateObject() function ********************//
    function buyListCreateObject(address sender,uint256 price, uint256 volume, uint256 auxprice) internal returns (uint256)
    {
        uint256 newId = buyListCounter;
        buyListCounter ++;
        OrderStruct memory order = OrderStruct(sender, price, volume, true, auxprice, newId, 0, 0);
        buyList[order.id] = order;
        return order.id;
    }
//******************** buyListCreateObject() function ********************//
    function buyListLink(uint256 prevId, uint256 nextId) internal
    {
        buyList[prevId].next = nextId;
        buyList[nextId].prev = prevId;   
    }
//****************   buyListMaxPrice()  *********************//
    //buyListMaxPrice function returns the price of the highest priority element (The highest bid)
    function buyListMaxPrice() external  returns (uint256){
        
        require (buyHead != 0, 'buyList is empty!'); //throws exception if the maxheap (buyList) is empty
        return (buyList[buyHead].Price);
        
    }
//****************   buyListMaxSender()  *********************//
    //buyListMaxSender function returns the sender of the highest priority element (The highest bid)
    function buyListMaxSender() external  returns (address){
        
        require (buyHead != 0, 'buyList is empty!'); //throws exception if the maxheap (buyList) is empty
        return (buyList[buyHead].Sender);
        
    }
//****************   buyListMax()  *********************//
    //buyListMax function returns the sender of the highest priority element (The highest bid)
    function buyListMax() external  returns (uint256, address, uint256){
        
        require (buyHead != 0, 'buyList is empty!'); //throws exception if the maxheap (buyList) is empty
        return (buyList[buyHead].Price, buyList[buyHead].Sender, buyList[buyHead].Volume);
        
    }

//******************** buyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    function buyListMaxDelete() external returns (uint256, address, uint256)
    {
        
        OrderStruct memory removeObject = buyList[buyHead];
        uint256 _price =  removeObject.Price;
        address _sender = removeObject.Sender;
        uint256 _volume = removeObject.Volume;

        if (buyTail == buyHead)
        {
            buyHead = 0;
            buyTail = 0;
            
        }
        else
        {
            buyHead = removeObject.next;
            buyList[removeObject.next].prev = 0;
            
        }
        
        delete buyList[removeObject.id];
        return (_price,_sender,_volume); 
        
        


        /* OrderStruct memory removeObject = buyList[buyHead];
        buyListSetHead(removeObject.next);
        buyList[removeObject.next].prev = 0;
        
        if (buyTail == buyHead)
        {
            buyListSetHead(0);
            buyListSetTail(0);
        }
        else
        {
            buyListSetHead(removeObject.next);
            buyList[removeObject.next].prev = 0;
            buyListLink(removeObject.prev, removeObject.next);
        }
        uint256 _price =  removeObject.Price;
        address _sender = removeObject.Sender;
        delete buyList[removeObject.id];
        return (_price,_sender); */
    
    }

//****************   buyListisEmpty()  *********************//
    //checks if the buyList is empty
    function buyListisEmpty() external returns (bool){
        
        if (buyHead == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }

//*******************  insertAsk () ***************************//
    //A new buy order will be added in its right position in the list
    function insertAsk (address sender, uint256 price, uint256 volume, uint256 auxprice) external 
    {
        OrderStruct memory current = sellList[sellHead];
        while (current.id !=0 && auxprice >= current.AuxPrice) //The linkedlist is sorted in an ascending order (increasing)
        {
        current = sellList[current.next];
        // we only exit this loop if we find the position to insert our data;
        }  
        if (current.prev == 0) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            sellListAddHead(sender, price, volume, auxprice);
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
        sellListInsertAfter(current.prev, sender, price, volume, auxprice);           
        }    
         
    }
//******************** sellListInsertAfter() function ********************//
    function sellListInsertAfter(uint256 prevId, address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (bool)
    {
        if (prevId == sellTail) 
        {
            sellListAddTail(sender, price, volume, auxprice);
        }
        else 
        {
            OrderStruct memory prevOrder = sellList[prevId];
            OrderStruct memory nextOrder = sellList[prevOrder.next];
            uint256 newOrderId = sellListCreateObject(sender, price, volume, auxprice);
            sellListLink(newOrderId, nextOrder.id);
            sellListLink(prevOrder.id, newOrderId);  
        }
        return true;
    }
//******************** sellListInsertBefore() function ********************//
    function sellListInsertBefore(uint256 nextId, address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (bool)
    {
        if (nextId == sellHead) {
            sellListAddHead(sender, price, volume, auxprice);
        }
        else {
            sellListInsertAfter(sellList[nextId].prev, sender, price, volume, auxprice);
        }
        return true;
    }
//******************** sellListAddTail() function ********************//
    function sellListAddTail(address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (bool)
    {
        if (sellHead == 0) {
            sellListAddHead(sender, price, volume, auxprice);
        }
        else {
            uint256 ordertId = sellListCreateObject(sender, price, volume, auxprice);
            sellListLink(sellTail, ordertId);
            sellListSetTail(ordertId);
        }
        
        return true;
    }
//******************** sellListSetTail() function ********************//
    function sellListSetTail(uint256 id) internal returns(bool)
    {
        sellTail = id;
        return true;
    }
//******************** sellListAddHead() function ********************//
    function sellListAddHead(address sender,uint256 price, uint256 volume, uint256 auxprice) internal returns (uint256)
    {
        uint256 ordertId = sellListCreateObject(sender, price, volume, auxprice);
        sellListLink(ordertId, sellHead);
        sellListSetHead(ordertId);
        if (sellTail == 0) sellListSetTail(ordertId);
        return ordertId;
    }
//******************** sellListSetHead() function ********************//
    function sellListSetHead(uint256 id) internal returns (bool)
    {
        sellHead = id;
        return true;
    }      
//******************** sellListCreateObject() function ********************//
    function sellListCreateObject(address sender, uint256 price, uint256 volume, uint256 auxprice) internal returns (uint256)
    {
        uint256 newId = sellistCounter;
        sellistCounter ++;
        OrderStruct memory order =  OrderStruct( sender , price, volume, true, auxprice, newId, 0, 0);
        sellList[order.id] = order;
        return order.id;
    }
//******************** sellListCreateObject() function ********************//
    function sellListLink(uint256 prevId, uint256 nextId) internal returns (bool)
    {
        sellList[prevId].next = nextId;
        sellList[nextId].prev = prevId;
        return true;    
    }
//****************   sellListMaxPrice()  *********************//
    //sellListMaxPrice function returns the price of the highest priority element (The Lowest ask)
    function sellListMaxPrice() external  returns (uint256){

        require(sellHead != 0,'sellList is empty!'); //throws exception if the minheap (sellList) is empty
        return (sellList[sellHead].Price);
    }
//****************   sellListMaxSender()  *********************//
    //sellListMaxSender function returns the sender of the highest priority element (The Lowest ask)
    function sellListMaxSender() external  returns (address){

        require(sellHead != 0,'sellList is empty!'); //throws exception if the minheap (sellList) is empty
        return (sellList[sellHead].Sender);
    }
//****************   sellListMax()  *********************//
    //sellListMax function returns the sender of the highest priority element (The Lowest ask)
    function sellListMax() external  returns (uint256, address, uint256){

        require(sellHead != 0,'sellList is empty!'); //throws exception if the minheap (sellList) is empty
        return (sellList[sellHead].Price,sellList[sellHead].Sender, sellList[sellHead].Volume);
    }
//*******************  sellListMaxDelete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    function sellListMaxDelete() external returns (uint256, address, uint256)
    {
        

        
        OrderStruct memory removeObject = sellList[sellHead];
        uint256 _price =  removeObject.Price;
        address _sender = removeObject.Sender;
        uint256 _volume = removeObject.Volume;

        if (sellTail == sellHead)
        {
            sellHead = 0;
            sellTail = 0;
            
        }
        else
        {
            sellHead = removeObject.next;
            sellList[removeObject.next].prev = 0;
            
        }
        
        delete sellList[removeObject.id];
        return (_price,_sender, _volume); 
    

        /* OrderStruct memory removeObject = sellList[sellHead];
        if (sellTail == sellHead)
        {
            sellListSetHead(0);
            sellListSetTail(0);
        }
        else
        {
            sellListSetHead(removeObject.next);
            sellList[removeObject.next].prev = 0;
        }
        uint256 _price =  removeObject.Price;
        address _sender =  removeObject.Sender;
        delete sellList[removeObject.id];
        return (_price,_sender); */
    }

        
    
//****************   sellListisEmpty()  *********************//
    //checks if the sellList is empty
    function sellListisEmpty() external returns (bool){
        
        if (sellHead == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }

//****************   deletePQ()  *********************//
    /* function deletePQ (address payable callmarket) external {
        selfdestruct(callmarket);
    } */


}