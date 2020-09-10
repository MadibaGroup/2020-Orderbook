pragma solidity 0.5.12;

//Heap with dynamic array wrapped in a priority queue

contract PQ1_Heap_Dynamic_Array{


/**
*   @dev 
    Order structs with its element:
        Sender: The address of the trader submitting the order
        Price: The price of the order
        Volume: The volume of the order, it is considered 1 by now
        AuxPrice: The contcantenation of the order's price and the counter which helps to sort the heap when there are ties
    BuyList: The array that contains bid OrderStructs, it is a maxheap (decrementally ordered)
    SellList: The array that contains ask OrderStructs, it is a minheap (incrementally ordered)
*/
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        uint256 Volume;     
        uint256 AuxPrice;   

    }

    OrderStruct[] internal BuyList;  
    OrderStruct[] internal SellList; 

//*****************************************************************//
//*******************  maxheap Functions (BuyList) ****************//
//*****************************************************************//

//***********************************************************************//

    /**
    *   @dev Adds the incoming bid orders to the end of the BuyList array which will be then heapified
    */
  
    function InsertBid (address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _price , _volume, _auxprice);
        BuyList.push(neworder);
        maxheap_heapifyUp();
        return true;
    }    
//***********************************************************************//

    /**
    *   @dev Sorts the heap
    */
    
    function maxheap_heapifyUp () internal returns (bool) {
        
        //k is set to be the index of the last entry of the BuyList array which is the oredr that has been added and needs to be moved up
        uint256 k = BuyList.length - 1;                   

        //while we havent reached to the top of the heap
        while (k > 0){       
            //compute the parent of this last element which is p = (k-1)/2                           
            uint256 p = (k-1)/2;  
            //if the element's price is greater than its parent's price                         
            if (BuyList[k].AuxPrice > BuyList[p].AuxPrice) 
            {   
                //swap the element at index k with its parent
                OrderStruct memory temp = BuyList[k];    
                BuyList[k] = BuyList[p];
                BuyList[p] = temp;
                //k moves up one level
                k = p;                                  
            }
            //if not, break statement exits the loop (it continues until no element index k is greater than its parent)
            else {break;}                               
        }
        return true;
    }

//***********************************************************************//

    /**
    *   @dev Removes and returns the highest priority element of the BuyList
        Only if the BuyList is not empty
        then the heap is reordered using the heapifyDown method
    */

    function BuyListMaxDelete() public returns (uint256, address) 
    {
        require (BuyList.length != 0,'BuyList is empty!');
        
        //If the BuyList has only one order
        if (BuyList.length == 1) {                                                          
            uint256 _price =  BuyList[0].Price;
            address _sender =  BuyList[0].Sender;
            BuyList.pop();                                                  
            return (_price ,_sender);     
       
        }

        uint256 _price =  BuyList[0].Price;
        address _sender =  BuyList[0].Sender;
        //The last elementof the BuyList is removed and written into the first position
        BuyList[0] = BuyList[BuyList.length -1]; 
        BuyList.pop();
        maxheap_heapifyDown();
        return (_price, _sender);  
    }


//***********************************************************************//

    /**
    *   @dev Heapifydown the BuyList when an order is removed 
    */ 

    function maxheap_heapifyDown () internal returns (bool)
    {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        
        //As long as the left child is within the array that heap is stored in
        while (leftchild < BuyList.length)
        {                                   
            uint256 max = leftchild;
            //rightchild = 2k+2
            uint256 rightchild = leftchild + 1;                                     
            //if there is a rightchild
            if (rightchild < BuyList.length)                                       
            {   
                //then the right child and left child are compared
                if (BuyList[rightchild].AuxPrice > BuyList[leftchild].AuxPrice)    
                {
                    //now max is set to rightchild, otherwise max remains to be the leftchild
                    max++;                                                       
                }
            }
            //compares the k item with the max item and if k is smaller than its greatest children they are swapped
            if (BuyList[k].AuxPrice < BuyList[max].AuxPrice)                        
            {
            
                OrderStruct memory temp = BuyList[k];
                BuyList[k] = BuyList[max];    
                BuyList[max] = temp;
                //k is set to max
                k = max;    
                //leftchild is recompuetd in preparation for the next iteration                                                     
                leftchild =2*k + 1;                                              
            }
            else
            { 
                //if the k item is not smaller than the max item, heapifyDown should stop                                                              
                break;
            }
        }
        return true;
    }
    


//***********************************************************************//

    /**
    *   @dev Checks if the BuyList is empty or not
    */ 
    function BuyListisEmpty() public returns (bool){
        
        if (BuyList.length == 0) 
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }
//*****************************************************************//
//*******************  minheap Functions (SellList) ****************//
//*****************************************************************//

//***********************************************************************//

    /**
    *   @dev Adds the incoming ask orders to the end of the SellList array which will be then heapified
    */

    function InsertAsk (address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public  returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _price , _volume, _auxprice); 
        SellList.push(neworder);
        minheap_heapifyUp();
        return true;
    }    
//***********************************************************************//

    /**
    *   @dev Sorts the heap
    */
    function minheap_heapifyUp () internal returns (bool) {

        //k is set to be the index of the last entry of the SellList array which is the oredr that has been added and needs to be moved up
        uint256 k = SellList.length - 1; 
        //while we havent reached to the top of the heap
        while (k > 0){                                      
            //we need to compute the parent of this last element which is p = (k-1)/2
            uint256 p = (k-1)/2;                            
            //if the element is smaller than its parent
            if (SellList[k].AuxPrice < SellList[p].AuxPrice) 
            { 
                //swap the element at index k with its parent
                OrderStruct memory temp = SellList[k];    
                SellList[k] = SellList[p];
                SellList[p] = temp;
                //k moves up one level
                k = p; 
            }
            //if not, the break statement exits the loop (it continues until no element index k is smaller than its parent)
            else {break;} 
        }
        
        return true;
    }    
//***********************************************************************//

    /**
    *   @dev Removes and returns the highest priority element of the SellList (the lowest ask order)
        Only if the SellList is not empty
        then the heap is reordered using the heapifyDown method
    */
    function SellListMaxDelete() public returns (uint256, address)
    
    {
        require(SellList.length != 0, 'SellList is empty!');             
        //if the heap has only one order
        if (SellList.length == 1) {                               
            uint256 _price =  SellList[0].Price;
            address _sender =  SellList[0].Sender;
            SellList.pop();                                    
            return (_price, _sender);
        }

        uint256 _price =  SellList[0].Price;
        address _sender =  SellList[0].Sender;
        //the last elementof the heap is removed and written into the first position
        SellList[0] = SellList[SellList.length -1];                      
        SellList.pop(); 
        minheap_heapifyDown();                           
        return (_price, _sender);       
    }

//***********************************************************************//

    /**
    *   @dev Heapifydown the SellList when an order is removed 
    */ 

    function minheap_heapifyDown () internal returns (bool) 
    {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        //as long as the left child is within the array that heap is stored in
        while (leftchild < SellList.length){               
            uint256 min = leftchild;
            //rightchild = 2k+2
            uint256 rightchild = leftchild + 1;              
            
            //if there is a rightchild, then the right child and left child are compared
            if (rightchild < SellList.length)               
            {
                if (SellList[rightchild].AuxPrice < SellList[leftchild].AuxPrice)
                {   //now min is set to rightchild, otherwise min remains to be the leftchild
                    min++;   
                }                               
            }
            //compares the k item with the max item and if its less they are swapped
            if (SellList[min].AuxPrice < SellList[k].AuxPrice) 
            {                   
                //swap the element at index k with its parent 
                OrderStruct memory temp = SellList[k];    
                SellList[k] = SellList[min];
                SellList[min] = temp;
                
                //k is set to min
                k = min; 
                //leftchild is recompuetd in preparation for the next iteration
                leftchild = 2*k + 1; 
            }
            //if k item's smaller childer is not smaller than k item itself, heapifyDown should stop
            else
            { 
                break;
            }

        }
        return true;
    }

//***********************************************************************//
    /**
    *   @dev Checks if the SellList is empty or not
    */

    function SellListisEmpty() public returns (bool){
        
        if (SellList.length == 0) 
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }
        










}