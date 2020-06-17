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
    address payable callmarket = address(uint160(address(this)));

    function changetest() public {
        
        test = BuyFirst.next().price();
        
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
        //SellList currentask = SellFirst;
        //BuyList currentbuy = BuyFirst;
        SellList selltemp;
        BuyList buytemp;

        if (BuyCounter >= SellCounter) 
        { 
            while (SellFirst != SellList(0)) //while the list is not empty
            {
                if (BuyFirst.price() >= SellFirst.price())
                {
                    countervariable++;
                    selltemp = SellFirst;
                    buytemp = BuyFirst;
                    //BuyListtRemove(BuyFirst.price());
                    //SellListRemove(SellFirst.price());
                    SellFirst.deletenode(callmarket);
                    BuyFirst.deletenode(callmarket);
                    SellFirst =  selltemp.next();
                    BuyFirst = buytemp.next();
                    
                    //BuyListtRemove(buytemp.price());
                    //SellListRemove(selltemp.price());
       
                }
                else 
                {   
                    //SellFirst = currentask;
                    //BuyFirst = currentbuy;
                    break;
                }
            
            }
        }
        else //Buylist is shorter than sellluiist
        {
            while (BuyFirst != BuyList(0)) //while the list is not empty
            {
                if (BuyFirst.price() >= SellFirst.price())
                {
                    countervariable++;
                    selltemp = SellFirst;
                    buytemp = BuyFirst;
                    //BuyListtRemove(buytemp.price());
                    //SellListRemove(selltemp.price());
                    SellFirst.deletenode(callmarket);
                    BuyFirst.deletenode(callmarket);
                    SellFirst =  selltemp.next();
                    BuyFirst = buytemp.next();
                }
                else 
                {   //SellFirst = currentask;
                    //BuyFirst = currentbuy;
                    break;
                    
                }
            
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
        SellList temp;
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
            temp = SellFirst;
            SellFirst.deletenode(callmarket);
            SellFirst = temp.next();
            //SellFirst = SellFirst.next();
            
            
        }
        else
        {
            
            temp = current;
            current.deletenode(callmarket);
            previous.addNew(temp.next());
            //previous.addNew(current.next());
            
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
        BuyList temp;
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
            temp = BuyFirst;
            BuyFirst.deletenode(callmarket);
            BuyFirst = temp.next();
            //BuyFirst = BuyFirst.next();
            
        }
        else
        {
            temp = current;
            current.deletenode(callmarket);
            previous.addNew(temp.next());
            //previous.addNew(current.next());
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
    function deletenode (address payable _callmarket) public {

        selfdestruct(_callmarket);
        
    
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

    function deletenode (address payable _callmarket) public {
        selfdestruct(_callmarket);
    }
}      
    
    
    
    
    
    
    
    