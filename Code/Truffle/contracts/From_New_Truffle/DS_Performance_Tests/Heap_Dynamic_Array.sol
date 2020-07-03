pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;




//This file is only used for storing N order struct, sorting, and removing them
//Order structs are stored in a heap with dynamic array
contract Heap_Dynamic_Array{ //previously: Orderbook_V22.sol

//**************** OrderStruct ***************************//
//Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        uint256 Volume;     //The volume is 1 for now
        
    }
//****************************************************//

    OrderStruct[] MaxHeap;  //The array that contains Bid OrderStructs (descending (decremental)), we always want the highest bid (maxheap)
    
//****************************************************//
    function submitorder (uint256 _price, uint256 _volume) public returns (bool)
    {
        maxheap_insert(msg.sender, _price, _volume); 
        return true;
    }
//****************************************************//

//*****************************************************************//
//*******************  maxheap Functions (BuyList) ****************//
//*****************************************************************//


//*******************  maxheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function maxheap_insert (address _sender, uint256 _price, uint256 _volume) internal returns (bool)
    {
        
        OrderStruct memory neworder = OrderStruct(_sender, _price , _volume);
        MaxHeap.push(neworder);
        maxheap_heapifyUp ();
        return true;
    }    
//*******************  maxheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new Buy order is submitted) and
    //now the heap has to be sorted again
    function maxheap_heapifyUp () internal returns (bool) {
    
        uint256 k = MaxHeap.length - 1;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (MaxHeap[k].Price > MaxHeap[p].Price) //if the element is greater than its parent
            {   //"!SYNTAX!"
                //Orderbook_V9.swap(SellList, k, p);              //swap the element at index k with its parent
                OrderStruct memory temp = MaxHeap[k];    //"!SYNTAX!"//swap the element at index k with its parent
                MaxHeap[k] = MaxHeap[p];
                MaxHeap[p] = temp;
                k = p;                                  //k moves up one level
            }
            else {break;}                               //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        return true;
    }
//*******************  maxheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function maxheap_heapifyDown () internal returns (bool)
    {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < MaxHeap.length)
        {                                   //as long as the left child is within the array that heap is stored in
            uint max = leftchild;
            uint rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < MaxHeap.length)                                       //if there is a rightchild
            {
                if (MaxHeap[rightchild].Price > MaxHeap[leftchild].Price)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (MaxHeap[k].Price < MaxHeap[max].Price)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            //swap k with its greatest children (max)
            //"!SYNTAX!"
            //Orderbook_V9.swap (SellList, k, max);
            OrderStruct memory temp = MaxHeap[k];    //"!SYNTAX!"//swap the element at index k with its parent
            MaxHeap[k] = MaxHeap[max];
            MaxHeap[max] = temp;
            k = max;                                                         //k is set to max
            leftchild =2*k + 1;                                              //l is recompuetd in preparation for the next iteration
        }
        else{                                                               //if the k item is not smaller than the max item, heapifyDown should stop
            break;
            }
        }
        return true;
    }
    
//****************   MaxHeaptPeak()  *********************//
    //MaxHeappeak function returns the highest priority element (The highest bid)
    function MaxHeapPeak() public  returns (OrderStruct memory){
        //require (BuyList.length != 0); //throws exception if the maxheap (BuyList) is empty
        return (MaxHeap[0]);
        //return (BuyList[0].Sender, BuyList[0].Price, BuyList[0].AuxPrice, BuyList[0].Volume );
    }
    
//*******************  maxheap_delete () ***************************//
    //the highest priority item will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function MaxHeapDelete () public returns (OrderStruct memory) 
    {
        if (MaxHeap.length == 0) { revert(); }                             //the delete function throws exception if the heap is empty
        if (MaxHeap.length == 1) {                                      //if the heap has only one items
                     
            OrderStruct memory result =  MaxHeap[0];
            
            MaxHeap.pop();                                                 //the only element of the heap is removed and returned 
            return result;     
       
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        OrderStruct memory result =  MaxHeap[0];
        MaxHeap[0] = MaxHeap[MaxHeap.length -1]; //the last elementof the heap is removed and written into the first position
        MaxHeap.pop();
        maxheap_heapifyDown(); //now the siftdown is called
        return result;
    }
    
   
    
}   
    
    
    
    
    
    
    
    
    
    
    
    
    