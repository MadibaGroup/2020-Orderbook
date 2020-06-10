pragma solidity >=0.4.22;


contract Sorted_linkedlist_V3{
    Item public first;
    event LogItems(address item, uint data);
    
    constructor() public {
        first = Item(0);
        
 
    }

    function isEmpty() public returns (bool){ //returns true if the list is empty
        
        return (first == Item(0));
    }

    bool public value;
    function contains(uint _key) public returns (bool success)  //returns true if the key is in the list
    { 
        Item current = first;
        while (current.data() != _key)
        {
            if (current.next() == Item(0))
            {
                return value = false; //we reach the end of the list and we dont find the _key, so we return false
                
            }
            else 
            {
                current = current.next();
            }
        }
        return value = true;
        
    }
    
    
    function remove(uint _key) public returns (Item)  
    { 
        Item current = first;
        Item previous = Item(0);
        while (current.data() != _key)
        {
            if (current.next() == Item(0))
            {
                return Item(0); //we have not found the element so we return null
            }
            
            else 
            {   previous = current;
                current = current.next();
            }
        }
        //we exit the while loop while we find the key
        //now if have to check if the node we want to delete is the first node
        if (current == first)
        {   
            first = first.next();
            
        }
        else
        {
            previous.addNew(current.next());
        }
        return current;
        
    }

    function insert(uint _key) public 
    {
        Item newitem = new Item (_key);
        Item current = first; 
        Item previous = Item(0);
        
        //we iterate through our list with 2 conditions:
        while (current != Item(0) && _key > current.data()) //The linkedlist is sorted in an ascending order (increasing)
        {
            previous = current;
            current = current.next();
            // we only exit this loop if we find the position to insert our data;
        } 
        //now if we have to check if we have to insert the node to the begining of the list:
        if (previous == Item(0)) //it means the current is equal to first and in that case we have to insert the node as a new head
        {
            first = newitem; 
        }
        else //the node next to the privious is no longer the current but it's our new node
        {
            previous.addNew(newitem);
        }
        
        //and in all cases regardless of if it's a first node or not, we must say we have to say the node next to our new node is current
        
        newitem.addNew(current);
    }            
    
    address[]  public itemlist;
    uint[] public itemdata;
    function displaylist() public 
    {  
            
        

        Item current = first;
        while (current != Item(0)) //while the list is not empty
        {
            
            itemlist.push(address(current));
            itemdata.push(current.data());
            current = current.next();
            
            
        }
        for (uint i=0; i < itemlist.length; i++) 
        {
            emit LogItems(itemlist[i], itemdata[i]);
        }
        //itemlist.length=0;
        //itemdata.length=0;
        delete itemlist;
        delete itemdata;

    }          
        


}        
                
    contract Item {
    Item public next;
    uint public data;
    

    constructor(uint _data) public {
        
        data = _data;
        next = Item(0);
    }

    function addNew(Item item) public {
        
        next = item;
       
    }
   
    
    function replacedata ( uint _data) public {
        data = _data;
        
    }
    

    
    function print () public returns (uint){
        return data;
        
    }
    
    
    
    
    
    
    
    
    
    
}
        
            
        
        
        
    


            
        

        
    
    




