pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;


//Mapping and Heap with dynamic array wrapped in a priority queue
//The code stores orderstructs in the mapping and have keys for them. and stores the keys in the sorted heap that is implemented by dynamic array
//Maximum number of order the Match function can handle:

contract PQ3_Heap_Mapping{

    //Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;  
        uint256 Volume;     //The volume is 1 for now
        bool Exists;
        uint256 AuxPrice; //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
    }


    mapping(uint256 => OrderStruct) public BuyList;   //mapping that contains the buy orders and have keys for them. This mapping is not sorted, we store the keys into the heap and sort them there
    mapping(uint256 => OrderStruct) public SellList;  //same as above but for sell orders
    uint256 public BuyListKey;
    uint256 public SellListKey;

    uint256[] BuyListHeap;
    uint256[] SellListHeap;

//*****************************************************************//
//*******************  maxheap Functions (BuyList) ****************//
//*****************************************************************//    

//*******************  InsertBid() ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function InsertBid (address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public 
    //CheckAuctionStage ()
    returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(msg.sender, _price, _volume, true, _auxprice);
        BuyList[BuyListKey] = neworder;
        BuyListHeap.push(BuyListKey);
        BuyListKey++;
        maxheap_heapifyUp ();
        return true;
    }

//*******************  maxheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new Buy order is submitted) and
    //now the heap has to be sorted again
    function maxheap_heapifyUp () internal returns (bool) {
    
        uint256 k = BuyListHeap.length - 1;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (BuyList[BuyListHeap[k]].AuxPrice > BuyList[BuyListHeap[p]].AuxPrice) 
            {   
                uint256 temp = BuyListHeap[k];    //swap the element at index k with its parent
                BuyListHeap[k] = BuyListHeap[p];
                BuyListHeap[p] = temp;
                k = p;                                  //k moves up one level
            }
            else {break;}                               //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        return true;
    }
//******************** BuyListMaxDelete() function ********************//    
    //the highest priority item will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function BuyListMaxDelete() public returns (uint256, address)
    {
        require (BuyListHeap.length != 0, 'BuyList is empty!');                            //the delete function throws exception if the heap is empty
        uint256 _price =  BuyList[BuyListHeap[0]].Price;
        address _sender =  BuyList[BuyListHeap[0]].Sender;
        
        if (BuyListHeap.length == 1) {                                      //if the heap has only one items

            //delete BuyList[BuyListHeap[0]];
            BuyListHeap.pop();                                                 //the only element of the heap is removed and returned 
            BuyListKey--;
            return (_price, _sender);     
       
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        
        //delete BuyList[BuyListHeap[0]];
        BuyListHeap[0] = BuyListHeap[BuyListHeap.length -1]; //the last elementof the heap is removed and written into the first position
        BuyListHeap.pop();
        maxheap_heapifyDown(); //now the siftdown is called
        BuyListKey--;
        return (_price, _sender);  
    }
//*******************  maxheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function maxheap_heapifyDown () internal returns (bool)
    {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < BuyListHeap.length)
        {                                   //as long as the left child is within the array that heap is stored in
            uint256 max = leftchild;
            uint256 rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < BuyListHeap.length)                                       //if there is a rightchild
            {
                if (BuyList[BuyListHeap[rightchild]].AuxPrice > BuyList[BuyListHeap[leftchild]].AuxPrice)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (BuyList[BuyListHeap[k]].AuxPrice < BuyList[BuyListHeap[max]].AuxPrice)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            uint256 temp = BuyListHeap[k];    //swap the element at index k with its parent
            BuyListHeap[k] = BuyListHeap[max];
            BuyListHeap[max] = temp;
            k = max;                                                         //k is set to max
            leftchild =2*k + 1;                                              //l is recompuetd in preparation for the next iteration
        }
        else{                                                               //if the k item is not smaller than the max item, heapifyDown should stop
            break;
            }
        }
        return true;
    }
//****************   BuyListMaxPrice()  *********************//
    //BuyListpeak function returns the price of the highest priority element (The highest bid)
    function BuyListMaxPrice() public  returns (uint256){
        
        require (BuyListHeap.length != 0, 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[BuyListHeap[0]].Price);
        
    }
//****************   BuyListMaxSender()  *********************//
    //BuyListpeak function returns the sender of the highest priority element (The highest bid)
    function BuyListMaxSender() public  returns (address){
        
        require (BuyListHeap.length != 0, 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[BuyListHeap[0]].Sender);
        
    }
//****************   BuyListisEmpty()  *********************//
    //checks if the BuyList is empty
    function BuyListisEmpty() public returns (bool){
        
        if (BuyListHeap.length == 0)
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

//*******************  InsertAsk() ***************************//
    //the new item will be added to the end of the array list (a sell order is submitted)
    //then heapified up with a call to heapifyUp method
    function InsertAsk (address _sender, uint256 _price, uint256 _volume, uint256 _auxprice) public  returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(msg.sender, _price, _volume, true, _auxprice);
        SellList[SellListKey] = neworder;
        SellListHeap.push(SellListKey);
        SellListKey++;
        minheap_heapifyUp();
        return true;
    }    
//*******************  minheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new sell order is submitted) and
    //now the heap has to be sorted again
    function minheap_heapifyUp () internal returns (bool) {

        uint256 k = SellListHeap.length - 1; //k is set to be the last entry of the array(also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                      //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                            //we need to compute the parent of this last element which is p = (k-1)/2
            if (SellList[SellListHeap[k]].AuxPrice < SellList[SellListHeap[p]].AuxPrice) //if the element is greater than its parent
            { 
            
                uint256 temp = SellListHeap[k];    //swap the element at index k with its parent
                SellListHeap[k] = SellListHeap[p];
                SellListHeap[p] = temp;
                
                k = p; //k moves up one level
            }
            else {break;} //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        
        return true;
    }
//*******************  SellListMaxDelete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function SellListMaxDelete() public returns (uint256, address)
    {
        require (SellListHeap.length != 0, 'BuyList is empty!');                      //the delete function throws exception if the heap is empty
        uint256 _price =  SellList[SellListHeap[0]].Price;
        address _sender =  SellList[SellListHeap[0]].Sender;
        
        if (SellListHeap.length == 1) {                               // if the heap has only one item
            
            //delete SellList[SellListHeap[0]];
            SellListHeap.pop();                                   //the only element of the heap is removed and returned  
            SellListKey --;
            return (_price, _sender);
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
      
        //delete SellList[SellListHeap[0]];
        SellListHeap[0] = SellListHeap[SellListHeap.length -1];                      //the last elementof the heap is removed and written into the first position
        SellListHeap.pop(); 
        minheap_heapifyDown();                           //now the heapifyDown is called to restore the ordering of the heap 
        SellListKey --;
        return (_price, _sender);    
    }
//*******************  minheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function minheap_heapifyDown () internal  returns (bool) {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < SellListHeap.length){               //as long as the left child is within the array that heap is stored in
            uint256 min = leftchild;
            uint256 rightchild = leftchild + 1;              //rightchild = 2k+2

            if (rightchild < SellListHeap.length)                //if there is a rightchild, then the right child and left child are compared
            {
                if (SellList[SellListHeap[rightchild]].AuxPrice < SellList[SellListHeap[leftchild]].AuxPrice)
                {    min++;   }                               //now min is set to rightchild, otherwise min remains to be the leftchild
            }

            if (SellList[SellListHeap[min]].AuxPrice < SellList[SellListHeap[k]].AuxPrice) //compares the k item with the max item and if its less they are swapped
            {
                
                uint256 temp = SellListHeap[k];    //swap the element at index k with its parent
                SellListHeap[k] = SellListHeap[min];
                SellListHeap[min] = temp;

                k = min; //k is set to min
                leftchild = 2*k + 1; //l is recompuetd in preparation for the next iteration
            }
            else{ //if k item's smaller childer is not smaller than k item itself, heapifyDown should stop
                break;
            }

        }
        return true;
    }
//****************   SellListMaxPrice()  *********************//
    //SellListpeak function returns the price of the highest priority element (The Lowest ask)
    function SellListMaxPrice() public  returns (uint256){
        
        require (SellListHeap.length != 0, 'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellList[SellListHeap[0]].Price);
    }
//****************   SellListMaxSender()  *********************//
    //SellListpeak function returns the sender of the highest priority element (The Lowest ask)
    function SellListMaxSender() public  returns (address){
        
        require (SellListHeap.length != 0, 'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        return (SellList[SellListHeap[0]].Sender);
    }
//****************   SellListisEmpty()  *********************//
    //checks if the SellList is empty
    function SellListisEmpty() public returns (bool){
        
        if (SellListHeap.length == 0)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }




}