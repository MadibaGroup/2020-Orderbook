pragma solidity >=0.4.22;

////Call market with linked list 
//This is just for the sake of testing:
//Here the “close market” just tells you how many orders matched and how many didn’t
//It doesn’t actually swap anything
//and then see how much gas that consumes
contract Orderbook_V26{
    uint public countervariable;
    SellList public SellFirst;
    BuyList public BuyFirst;
    uint public SellCounter;
    uint public BuyCounter;

    uint public test;

    function changetest() public {
        
        test = SellCounter;
        
    }
    constructor () public{
      SellFirst = SellList(0);
      BuyFirst = BuyList(0);
    }


//******************** submitask() function ********************/
    function submitAsk (uint256 _price ) public returns (bool)
    {
        if (SellListInsert( _price))
        {   
            SellCounter++;
        
        }
    
        return true;
    }
//******************** submitBid() function ********************//
    function submitBid (uint256 _price) public returns (bool)
    {
        if (BuyListInsert( _price))
        {
            BuyCounter++;
        }
        return true;
    }
//******************** MatchOrders() function ********************//
    function MatchOrders() public  returns (bool)
    {
  
        //uint256 counter;
        SellList currentask = SellFirst;
        BuyList currentbuy = BuyFirst;
        SellList selltemp;
        BuyList buytemp;

        if (BuyCounter >= SellCounter) 
        { 
            while (currentask != SellList(0)) //while the list is not empty
            {
                if (currentbuy.price() >= currentask.price())
                {
                    countervariable++;
                    selltemp = currentask;
                    buytemp = currentbuy;
                    BuyListtRemove(buytemp.price());
                    SellListRemove(selltemp.price());
                    currentask =  selltemp.next();
                    currentbuy = buytemp.next();

       
                }
                else {break;}
            
            }
        }
        else //Buylist is shorter than sellluiist
        {
            while (currentbuy != BuyList(0)) //while the list is not empty
            {
                if (currentbuy.price() >= currentask.price())
                {
                    countervariable++;
                    currentask = currentask.next();
                    currentbuy = currentbuy.next();
                }
                else {break;}
            
            }


        }
        
    

        
    }

//*****************************************************************//
//*******************  SellList Functions  ************************//
//*****************************************************************//


//******************** SellListRemove() function ********************//
    function SellListRemove(uint _price) public returns (SellList)  
    { 
        SellList current = SellFirst;
        SellList previous = SellList(0);
        while (current.price() != _price)
        {
            if (current.next() == SellList(0))
            {
                return SellList(0); //we have not found the element so we return null
            }
            
            else 
            {   previous = current;
                current = current.next();
            }
        }
        //we exit the while loop while we find the key
        //now if have to check if the node we want to delete is the first node
        if (current == SellFirst)
        {   
            SellFirst = SellFirst.next();
            
            
        }
        else
        {
            previous.addNew(current.next());
        }
        return current;
        
    }
//******************** SellListInsert() function ********************//
    function SellListInsert(uint _price) public returns (bool)
    {
        SellList newitem = new SellList (_price);
        SellList current = SellFirst; 
        SellList previous = SellList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != SellList(0) && _price > current.price()) //The linkedlist is sorted in an ascending order (increasing)
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

//******************** BuyListContains() function ********************//

    function BuyListContains(uint _price) public returns (bool success)  //returns true if the key is in the list
    { 
        BuyList current = BuyFirst;
        while (current.price() != _price)
        {
            if (current.next() == BuyList(0))
            {
                return  false; //we reach the end of the list and we dont find the _key, so we return false
                
            }
            else 
            {
                current = current.next();
            }
        }
        return true;
        
    }
//******************** BuyListtRemove() function ********************//
    function BuyListtRemove(uint _price) public returns (BuyList)  
    { 
        BuyList current = BuyFirst;
        BuyList previous = BuyList(0);
        while (current.price() != _price)
        {
            if (current.next() == BuyList(0))
            {
                return BuyList(0); //we have not found the element so we return null
            }
            
            else 
            {   previous = current;
                current = current.next();
            }
        }
        //we exit the while loop while we find the key
        //now if have to check if the node we want to delete is the first node
        if (current == BuyFirst)
        {   
            BuyFirst = BuyFirst.next();
            
        }
        else
        {
            previous.addNew(current.next());
        }
        return current;
        
    }
//******************** BuyListInsert() function ********************//
    function BuyListInsert(uint _price) public returns (bool)
    {
        BuyList newitem = new BuyList (_price);
        BuyList current = BuyFirst; 
        BuyList previous = BuyList(0);
        
        //we iterate through our list with 2 conditions:
        while (current != BuyList(0) && _price < current.price()) //The linkedlist is sorted in an descending order (descreasing)
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
    uint public price;
    
    constructor(uint _price) public {
        
        price = _price;
        next = SellList(0);
    }

    function addNew(SellList _askorder) public {
        
        next = _askorder;
       
    }
   
    
    function replacedata ( uint _price) public {
        price = _price;
        
    }
}   

//*****************************************************************//
//*******************  BuyList Contract  ************************//
//*****************************************************************//    
    
contract BuyList {
    BuyList public next;
    uint public price;
    
    constructor(uint _price) public {
        
        price = _price;
        next = BuyList(0);
    }

    function addNew(BuyList _bidorder) public {
        
        next = _bidorder;
       
    }
   
    
    function replacedata ( uint _price) public {
        price = _price;
        
    }
}      
    
    
    
    
    
    
    
    