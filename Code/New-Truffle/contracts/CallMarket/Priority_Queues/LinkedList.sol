pragma solidity >=0.4.22;
//pragma solidity 0.5.12;

//Linkedlist wrapped in a priority queue

contract LinkedList{
    
    SellList public sellFirst;
    BuyList public buyFirst;
    SellList internal selltemp;
    BuyList internal buytemp;
    address payable callmarket;
    address internal owner;
    

    constructor (address _callmarket) public {
        callmarket = address(uint160(_callmarket));
        sellFirst = SellList(0);
        buyFirst = BuyList(0);
        owner = address(this);
    }
//******************** insertBid() function ********************//
    //A new buy order will be added in its right position in the list
    function insertBid(address sender, uint256 price, uint256 volume, uint256 auxprice) external 
    {
        BuyList newitem = new BuyList (sender, price , volume, true, auxprice);
        BuyList current = buyFirst; 
        BuyList previous = BuyList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != BuyList(0) && auxprice <= current.auxPrice()) //The linkedlist is sorted in an descending order (descreasing)
        {
            previous = current;
            current = current.next();
            // we only exit this loop if we find the position to insert our data;
        } 
        //now if we have to check if we have to insert the node to the begining of the list:
        if (previous == BuyList(0)) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            buyFirst = newitem; 
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
            previous.addNew(newitem);
        }
        
        //and in all cases regardless of if it's a first node or not, we must say we have to say the node next to our new node is current
        
        newitem.addNew(current);
        
    }
//******************** buyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    function buyListMaxDelete() external returns(uint256, address) 
    {
        require (buyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        buytemp = buyFirst;
        buyFirst = buytemp.next();
        buytemp.deletenode(callmarket, owner);
        //buyFirst.deletenode(callmarket);
        //buyFirst = buytemp.next();
        return (buytemp.price(), buytemp.sender());
    }
//****************   buyListMaxPrice()  *********************//
    //buyListMaxPrice function returns the price of the highest priority element (The highest bid)
    function buyListMaxPrice() external  returns (uint256){
        
        require (buyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (buyFirst.price());
        
    }
//****************   buyListMaxSender()  *********************//
    //buyListMaxSender function returns the sender of the highest priority element (The highest bid)
    function buyListMaxSender() external  returns (address){
        
        require (buyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (buyFirst.sender());
        
    }
//****************   buyListisEmpty()  *********************//
    //checks if the BuyList is empty 
    function buyListisEmpty() external returns (bool){
        
        if (buyFirst == BuyList(0))
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }

//*******************  insertAsk() ***************************//
    //A new sell order will be added in its right position in the list
    function insertAsk (address sender, uint256 price, uint256 volume, uint256 auxprice) external 
    {
        SellList newitem = new SellList (sender, price , volume, true, auxprice);
        SellList current = sellFirst; 
        SellList previous = SellList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != SellList(0) && auxprice >= current.auxPrice()) //The linkedlist is sorted in an ascending order (increasing)
        {
            previous = current;
            current = current.next();
            // we only exit this loop if we find the position to insert our data;
        } 
        //now if we have to check if we have to insert the node to the begining of the list:
        if (previous == SellList(0)) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            sellFirst = newitem; 
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
            previous.addNew(newitem);
        }
        
        //and in all cases regardless of if it's a first node or not, we must say we have to say the node next to our new node is current
        
        newitem.addNew(current);
    }  
//*******************  sellListMaxDelete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    function sellListMaxDelete() external returns (uint256, address)
    {
        require(sellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        selltemp = sellFirst;
        sellFirst = selltemp.next();
        selltemp.deletenode(callmarket, owner);
        //sellFirst.deletenode(callmarket);
        //sellFirst = selltemp.next();
        return (selltemp.price(), selltemp.sender());
    }  
//****************   sellListMaxPrice()  *********************//
    //sellListMaxPrice function returns the price of the highest priority element (The Lowest ask)
    function sellListMaxPrice() external  returns (uint256){

        require(sellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (sellFirst.price());
    }
//****************   sellListMaxSender()  *********************//
    //sellListMaxSender function returns the sender of the highest priority element (The Lowest ask)
    function sellListMaxSender() external  returns (address){

        require(sellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (sellFirst.sender());
    }
//****************   sellListisEmpty()  *********************//
    //checks if the SellList is empty
    function sellListisEmpty() external returns (bool){
        
        if (sellFirst == SellList(0))
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }

}
//*****************************************************************//
//*******************  SellList Contract  ************************//
//*****************************************************************//
contract SellList {
    SellList public next;
    address public sender;
    uint256 public price;
    uint256 public volume;
    bool public exists;
    uint256 public auxPrice;
    
    constructor(address orderSender, uint256 orderPrice, uint256 orderVolume, bool ifExists, uint256 auxprice)  public {
        
        sender = sender;
        price = price;
        volume = volume;
        exists = exists;
        auxPrice = auxprice;
        next = SellList(0);
    }

    function addNew(SellList askorder) external {
        
        next = askorder;
       
    }
   
    function deletenode (address payable callmarket,address ownerContract) external {
        require (msg.sender == ownerContract,"Should be the Owner"  );
        selfdestruct(callmarket);
        
    }
    
    
}   

//*****************************************************************//
//*******************  BuyList Contract  ************************//
//*****************************************************************//    
    
contract BuyList {
    BuyList public next;
    address public sender;
    uint256 public price;
    uint256 public volume;
    bool public exists;
    uint256 public auxPrice;
    
    constructor(address orderSender, uint256 orderPrice, uint256 orderVolume, bool ifExists, uint256 auxprice) public {
        
        sender = orderSender;
        price = orderPrice;
        volume = orderVolume;
        exists = ifExists;
        auxPrice = auxprice;
        next = BuyList(0);
    }

    function addNew(BuyList bidorder) external {
        
        next = bidorder;
       
    }

    function deletenode (address payable callmarket, address ownerContract) external {
        require (msg.sender == ownerContract,"Should be the Owner" );
        selfdestruct(callmarket);
    }
} 