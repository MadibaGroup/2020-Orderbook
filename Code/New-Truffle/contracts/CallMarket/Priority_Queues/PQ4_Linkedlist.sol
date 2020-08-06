pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

//Linkedlist wrapped in a priority queue

contract PQ4_Linkedlist{
    
    SellList public SellFirst;
    BuyList public BuyFirst;
    SellList selltemp;
    BuyList buytemp;
    address payable callmarket;


    constructor (address _callmarket) public {
        callmarket = address(uint160(_callmarket));
        SellFirst = SellList(0);
        BuyFirst = BuyList(0);
    }
//******************** InsertBid() function ********************//
    //A new buy order will be added in its right position in the list
    function InsertBid(address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public returns (bool)
    {
        BuyList newitem = new BuyList (_sender, _price , _volume, true, _auxprice);
        BuyList current = BuyFirst; 
        BuyList previous = BuyList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != BuyList(0) && _auxprice <= current.AuxPrice()) //The linkedlist is sorted in an descending order (descreasing)
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
//******************** BuyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    function BuyListMaxDelete() public returns(uint256, address) 
    {
        require (BuyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        buytemp = BuyFirst;
        BuyFirst.deletenode(callmarket);
        BuyFirst = buytemp.next();
        return (buytemp.Price(), buytemp.Sender());
    }
//****************   BuyListMaxPrice()  *********************//
    //BuyListMaxPrice function returns the price of the highest priority element (The highest bid)
    function BuyListMaxPrice() public  returns (uint256){
        
        require (BuyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyFirst.Price());
        
    }
//****************   BuyListMaxSender()  *********************//
    //BuyListMaxSender function returns the sender of the highest priority element (The highest bid)
    function BuyListMaxSender() public  returns (address){
        
        require (BuyFirst != BuyList(0), 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyFirst.Sender());
        
    }
//****************   BuyListisEmpty()  *********************//
    //checks if the BuyList is empty 
    function BuyListisEmpty() public returns (bool){
        
        if (BuyFirst == BuyList(0))
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }

//*******************  InsertAsk() ***************************//
    //A new sell order will be added in its right position in the list
    function InsertAsk (address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public returns (bool)
    {
        SellList newitem = new SellList (_sender, _price , _volume, true, _auxprice);
        SellList current = SellFirst; 
        SellList previous = SellList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != SellList(0) && _auxprice >= current.AuxPrice()) //The linkedlist is sorted in an ascending order (increasing)
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
//*******************  SellListMaxDelete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    function SellListMaxDelete() public returns (uint256, address)
    {
        require(SellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        selltemp = SellFirst;
        SellFirst.deletenode(callmarket);
        SellFirst = selltemp.next();
        return (selltemp.Price(), selltemp.Sender());
    }  
//****************   SellListMaxPrice()  *********************//
    //SellListMaxPrice function returns the price of the highest priority element (The Lowest ask)
    function SellListMaxPrice() public  returns (uint256){

        require(SellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellFirst.Price());
    }
//****************   SellListMaxSender()  *********************//
    //SellListMaxSender function returns the sender of the highest priority element (The Lowest ask)
    function SellListMaxSender() public  returns (address){

        require(SellFirst != SellList(0),'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellFirst.Sender());
    }
//****************   SellListisEmpty()  *********************//
    //checks if the SellList is empty
    function SellListisEmpty() public returns (bool){
        
        if (SellFirst == SellList(0))
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
    address public Sender;
    uint256 public Price;
    uint256 public Volume;
    bool public Exists;
    uint256 public AuxPrice;
    
    constructor(address _sender, uint256 _price, uint256 _volume, bool _exists, uint256 _auxprice) public {
        
        Sender = _sender;
        Price = _price;
        Volume = _volume;
        Exists = _exists;
        AuxPrice = _auxprice;
        next = SellList(0);
    }

    function addNew(SellList _askorder) public {
        
        next = _askorder;
       
    }
   
    function deletenode (address payable _callmarket) public {

        selfdestruct(_callmarket);
        
    }
}   

//*****************************************************************//
//*******************  BuyList Contract  ************************//
//*****************************************************************//    
    
contract BuyList {
    BuyList public next;
    address public Sender;
    uint256 public Price;
    uint256 public Volume;
    bool public Exists;
    uint256 public AuxPrice;
    constructor(address _sender, uint256 _price, uint256 _volume, bool _exists, uint256 _auxprice) public {
        
        Sender = _sender;
        Price = _price;
        Volume = _volume;
        Exists = _exists;
        AuxPrice = _auxprice;
        next = BuyList(0);
    }

    function addNew(BuyList _bidorder) public {
        
        next = _bidorder;
       
    }
   

    function deletenode (address payable _callmarket) public {
        selfdestruct(_callmarket);
    }
} 