pragma solidity >=0.4.22;
//pragma solidity 0.5.12;


//Mapping and Heap with dynamic array wrapped in a priority queue
//The code stores orderstructs in the mapping and have keys for them. and stores the keys in the sorted heap that is implemented by dynamic array


contract HeapMapping{

    //Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;  
        uint256 Volume;     //The volume is 1 for now
        bool Exists;
        uint256 AuxPrice; //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
    }


    mapping(uint256 => OrderStruct) public buyList;   //mapping that contains the buy orders and have keys for them. This mapping is not sorted, we store the keys into the heap and sort them there
    mapping(uint256 => OrderStruct) public sellList;  //same as above but for sell orders
    uint256 public buyListKey;
    uint256 public sellListKey;

    uint256[] internal buyListHeap;
    uint256[] internal sellListHeap;

//*****************************************************************//
//*******************  maxheap Functions (buyList) ****************//
//*****************************************************************//    

//*******************  insertBid() ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function insertBid (address sender, uint256 price, uint256 volume, uint256 auxprice) external 
    {
        OrderStruct memory neworder = OrderStruct(msg.sender, price, volume, true, auxprice);
        buyList[buyListKey] = neworder;
        buyListHeap.push(buyListKey);
        buyListKey++;
        maxheapHeapifyUp ();
        
    }

//*******************  maxheapHeapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new Buy order is submitted) and
    //now the heap has to be sorted again
    function maxheapHeapifyUp () internal returns (bool) {
    
        uint256 k = buyListHeap.length - 1;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (buyList[buyListHeap[k]].AuxPrice > buyList[buyListHeap[p]].AuxPrice) 
            {   
                uint256 temp = buyListHeap[k];    //swap the element at index k with its parent
                buyListHeap[k] = buyListHeap[p];
                buyListHeap[p] = temp;
                k = p;                                  //k moves up one level
            }
            else {break;}                               //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        return true;
    }
//******************** buyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function buyListMaxDelete() external returns (uint256, address)
    {
        require (buyListHeap.length != 0, 'buyList is empty!');                            //the delete function throws exception if the heap is empty
        
        
        if (buyListHeap.length == 1) {                                      //if the heap has only one items

            uint256 _price =  buyList[buyListHeap[0]].Price;
            address _sender =  buyList[buyListHeap[0]].Sender;
            delete buyList[buyListHeap[0]];
            buyListHeap.pop();                                                 //the only element of the heap is removed and returned 
            buyListKey--;
            return (_price, _sender);     
       
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        
        uint256 _price =  buyList[buyListHeap[0]].Price;
        address _sender =  buyList[buyListHeap[0]].Sender;
        delete buyList[buyListHeap[0]];
        buyListHeap[0] = buyListHeap[buyListHeap.length -1]; //the last elementof the heap is removed and written into the first position
        buyListHeap.pop();
        maxheapHeapifyDown(); //now the siftdown is called
        buyListKey--;
        return (_price, _sender);  
    }
//*******************  maxheapHeapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function maxheapHeapifyDown () internal returns (bool)
    {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < buyListHeap.length)
        {                                   //as long as the left child is within the array that heap is stored in
            uint256 max = leftchild;
            uint256 rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < buyListHeap.length)                                       //if there is a rightchild
            {
                if (buyList[buyListHeap[rightchild]].AuxPrice > buyList[buyListHeap[leftchild]].AuxPrice)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (buyList[buyListHeap[k]].AuxPrice < buyList[buyListHeap[max]].AuxPrice)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            uint256 temp = buyListHeap[k];    //swap the element at index k with its parent
            buyListHeap[k] = buyListHeap[max];
            buyListHeap[max] = temp;
            k = max;                                                         //k is set to max
            leftchild =2*k + 1;                                              //l is recompuetd in preparation for the next iteration
        }
        else{                                                               //if the k item is not smaller than the max item, heapifyDown should stop
            break;
            }
        }
        return true;
    }
//****************   buyListMaxPrice()  *********************//
    //BuyListpeak function returns the price of the highest priority element (The highest bid)
    function buyListMaxPrice() external  returns (uint256){
        
        require (buyListHeap.length != 0, 'buyList is empty!'); //throws exception if the maxheap (buyList) is empty
        return (buyList[buyListHeap[0]].Price);
        
    }
//****************   buyListMaxSender()  *********************//
    //BuyListpeak function returns the sender of the highest priority element (The highest bid)
    function buyListMaxSender() external  returns (address){
        
        require (buyListHeap.length != 0, 'buyList is empty!'); //throws exception if the maxheap (buyList) is empty
        return (buyList[buyListHeap[0]].Sender);
        
    }
//****************   buyListisEmpty()  *********************//
    //checks if the buyList is empty
    function buyListisEmpty() external returns (bool){
        
        if (buyListHeap.length == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }
//*****************************************************************//
//*******************  minheap Functions (sellList) ****************//
//*****************************************************************//

//*******************  insertAsk() ***************************//
    //the new item will be added to the end of the array list (a sell order is submitted)
    //then heapified up with a call to heapifyUp method
    function insertAsk (address sender, uint256 price, uint256 volume, uint256 auxprice) external  
    {
        OrderStruct memory neworder = OrderStruct(msg.sender, price, volume, true, auxprice);
        sellList[sellListKey] = neworder;
        sellListHeap.push(sellListKey);
        sellListKey++;
        minheapHeapifyUp();
       
    }    
//*******************  minheapHeapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new sell order is submitted) and
    //now the heap has to be sorted again
    function minheapHeapifyUp () internal returns (bool) {

        uint256 k = sellListHeap.length - 1; //k is set to be the last entry of the array(also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                      //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                            //we need to compute the parent of this last element which is p = (k-1)/2
            if (sellList[sellListHeap[k]].AuxPrice < sellList[sellListHeap[p]].AuxPrice) //if the element is greater than its parent
            { 
            
                uint256 temp = sellListHeap[k];    //swap the element at index k with its parent
                sellListHeap[k] = sellListHeap[p];
                sellListHeap[p] = temp;
                
                k = p; //k moves up one level
            }
            else {break;} //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        
        return true;
    }
//*******************  sellListMaxDelete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function sellListMaxDelete() external returns (uint256, address)
    {
        require (sellListHeap.length != 0, 'buyList is empty!');                      //the delete function throws exception if the heap is empty
        
        
        if (sellListHeap.length == 1) {                               // if the heap has only one item
            
            uint256 _price =  sellList[sellListHeap[0]].Price;
            address _sender =  sellList[sellListHeap[0]].Sender;
            delete sellList[sellListHeap[0]];
            sellListHeap.pop();                                   //the only element of the heap is removed and returned  
            sellListKey --;
            return (_price, _sender);
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
      
        uint256 _price =  sellList[sellListHeap[0]].Price;
        address _sender =  sellList[sellListHeap[0]].Sender;
        delete sellList[sellListHeap[0]];
        sellListHeap[0] = sellListHeap[sellListHeap.length -1];                      //the last elementof the heap is removed and written into the first position
        sellListHeap.pop(); 
        minheapHeapifyDown();                           //now the heapifyDown is called to restore the ordering of the heap 
        sellListKey --;
        return (_price, _sender);    
    }
//*******************  minheapHeapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function minheapHeapifyDown () internal  returns (bool) {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < sellListHeap.length){               //as long as the left child is within the array that heap is stored in
            uint256 min = leftchild;
            uint256 rightchild = leftchild + 1;              //rightchild = 2k+2

            if (rightchild < sellListHeap.length)                //if there is a rightchild, then the right child and left child are compared
            {
                if (sellList[sellListHeap[rightchild]].AuxPrice < sellList[sellListHeap[leftchild]].AuxPrice)
                {    min++;   }                               //now min is set to rightchild, otherwise min remains to be the leftchild
            }

            if (sellList[sellListHeap[min]].AuxPrice < sellList[sellListHeap[k]].AuxPrice) //compares the k item with the max item and if its less they are swapped
            {
                
                uint256 temp = sellListHeap[k];    //swap the element at index k with its parent
                sellListHeap[k] = sellListHeap[min];
                sellListHeap[min] = temp;

                k = min; //k is set to min
                leftchild = 2*k + 1; //l is recompuetd in preparation for the next iteration
            }
            else{ //if k item's smaller childer is not smaller than k item itself, heapifyDown should stop
                break;
            }

        }
        return true;
    }
//****************   sellListMaxPrice()  *********************//
    //SellListpeak function returns the price of the highest priority element (The Lowest ask)
    function sellListMaxPrice() external  returns (uint256){
        
        require (sellListHeap.length != 0, 'sellList is empty!'); //throws exception if the minheap (sellList) is empty
        return (sellList[sellListHeap[0]].Price);
    }
//****************   sellListMaxSender()  *********************//
    //SellListpeak function returns the sender of the highest priority element (The Lowest ask)
    function sellListMaxSender() external  returns (address){
        
        require (sellListHeap.length != 0, 'sellList is empty!'); //throws exception if the minheap (sellList) is empty
        return (sellList[sellListHeap[0]].Sender);
    }
//****************   sellListisEmpty()  *********************//
    //checks if the sellList is empty
    function sellListisEmpty() external returns (bool){
        
        if (sellListHeap.length == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }




}