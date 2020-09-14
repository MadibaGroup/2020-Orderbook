//pragma solidity 0.5.12;
pragma solidity >=0.4.22;
//Heap with static array wrapped in a priority queue

contract HeapStaticArray{
    
    constructor (uint256 _MAXORDERS) public
    {
        maxOrders = _MAXORDERS;
    }

/**
*   @dev 
    Order structs with its element:
        Sender: The address of the trader submitting the order
        Price: The price of the order
        Volume: The volume of the order, it is considered 1 by now
        AuxPrice: The contcantenation of the order's price and the counter which helps to sort the heap when there are ties
    buyList: The array that contains bid OrderStructs, it is a maxheap (decrementally ordered)
    sellList: The array that contains ask OrderStructs, it is a minheap (incrementally ordered)
*/

//Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        uint256 Volume;     //The volume is 1 for now
        bool Exists;
        uint256 AuxPrice;   //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties

        
    }
    uint256 public maxOrders;
    OrderStruct[42] internal buyList;  //The array that contains Bid OrderStructs (descending (decremental)), we always want the highest bid (maxheap)
    OrderStruct[42] internal sellList; //The array that contains Ask OrderStructs (ascending (incremental)), we always want the lowest ask (minheap)
    uint256 public sellIndex;
    uint256 public buyIndex;

//*****************************************************************//
//*******************  maxheap Functions (buyList) ****************//
//*****************************************************************//

//*******************  insertBid() ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function insertBid (address sender, uint256 price, uint256 volume, uint256 auxprice) external 
    {
        OrderStruct memory neworder = OrderStruct(sender, price , volume, true, auxprice);

        if (!buyList[0].Exists)
        {
            buyList[0] = neworder; 
        }
       else{
            buyIndex ++;
            buyList[buyIndex] = neworder;
            maxheapHeapifyUp ();
        }  
        
    }    
//*******************  maxheapHeapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new Buy order is submitted) and
    //now the heap has to be sorted again
    function maxheapHeapifyUp () internal returns (bool) {

        uint256 k = buyIndex;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (buyList[k].AuxPrice > buyList[p].AuxPrice) //if the element is greater than its parent
            {   
                OrderStruct memory temp = buyList[k];    //swap the element at index k with its parent
                buyList[k] = buyList[p];
                buyList[p] = temp;
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
        require (!buyList[0].Exists, 'buyList is empty!');   //the delete function throws exception if the list is empty
        
        
        if (buyIndex == 0) 
        {   
            uint256 _price =  buyList[0].Price;
            address _sender =  buyList[0].Sender;
            delete buyList[0];
            return(_price,_sender);

        }                           
        if (buyIndex == 1)  //if the heap has two items
        {                                     
            uint256 _price =  buyList[0].Price;
            address _sender =  buyList[0].Sender;                  
            buyList[0] = buyList[1]; //the first element of the heap is removed 
            delete buyList[1];
            buyIndex --;
            return(_price,_sender);
            
       
        }
        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        uint256 _price =  buyList[0].Price;
        address _sender =  buyList[0].Sender;
        buyList[0] = buyList[buyIndex]; //the last elementof the heap is removed and written into the first position
        delete buyList[buyIndex];
        buyIndex--;
        maxheapHeapifyDown(); //now the siftdown is called
        return(_price,_sender);
    }

//*******************  maxheapHeapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function maxheapHeapifyDown () internal 
 
    returns (bool)
    {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild <= buyIndex )
        {                                   //as long as the left child is within the array that heap is stored in
            uint256 max = leftchild;
            uint256 rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < buyIndex )                                       //if there is a rightchild
            {
                if (buyList[rightchild].AuxPrice > buyList[leftchild].AuxPrice)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (buyList[k].AuxPrice < buyList[max].AuxPrice)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            
            OrderStruct memory temp = buyList[k];    //swap the element at index k with its parent
            buyList[k] = buyList[max];
            buyList[max] = temp;
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
    //BuyListMaxPrice function returns the price of the highest priority element (The highest bid)
    function buyListMaxPrice() external  returns (uint256){
        
        require (buyList[0].Exists, 'buyList is empty!'); //throws exception if the maxheap (buyList) is empty
        return (buyList[0].Price);
        
    }
//****************   buyListMaxSender()  *********************//
    //BuyListMaxSender function returns the sender of the highest priority element (The highest bid)
    function buyListMaxSender() external  returns (address){
        
        require (buyList[0].Exists, 'buyList is empty!'); //throws exception if the maxheap (buyList) is empty
        return (buyList[0].Sender);
        
    }
//****************   buyListisEmpty()  *********************//
    //checks if the buyList is empty or not 
    function buyListisEmpty() external returns (bool){
        
        if (!buyList[0].Exists)
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

//*******************  insertAsk () ***************************//
    //the new item will be added to the end of the array list (a sell order is submitted)
    //then heapified up with a call to heapifyUp method
    function insertAsk (address sender, uint256 price, uint256 volume, uint256 auxprice) external  
    {
        OrderStruct memory neworder = OrderStruct(sender, price , volume, true, auxprice); 
        
        if (!sellList[0].Exists)
        {
           sellList[0] = neworder;
           
        }
        else
        {
            sellIndex ++;
            sellList[sellIndex] = neworder;
            minheapHeapifyUp();
        }
    
       
    }    
//*******************  minheapHeapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new sell order is submitted) and
    //now the heap has to be sorted again
    function minheapHeapifyUp () internal returns (bool) {

        uint256 k = sellIndex ; //k is set to be the last entry of the array(also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                      //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                            //we need to compute the parent of this last element which is p = (k-1)/2
            if (sellList[k].AuxPrice < sellList[p].AuxPrice) //if the element is greater than its parent
            { 
            
                OrderStruct memory temp = sellList[k];    //swap the element at index k with its parent
                sellList[k] = sellList[p];
                sellList[p] = temp;
                
                k = p; //k moves up one level
            }
            else {break;} //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        
        return true;
    }    
//****************   sellListMaxPrice()  *********************//
    //SellListMaxPrice function returns the price of the highest priority element (The Lowest ask)
    function sellListMaxPrice() external  returns (uint256){

        require(sellList[0].Exists,'sellList is empty!'); //throws exception if the minheap (sellList) is empty
        return (sellList[0].Price);
    }
//****************   sellListMaxSender()  *********************//
    //sellListMaxSender function returns the address of the highest priority element (The Lowest ask)
    function sellListMaxSender() external  returns (address){

        require(sellList[0].Exists,'sellList is empty!'); //throws exception if the minheap (sellList) is empty
        return (sellList[0].Sender);
    }
//****************   sellListisEmpty()  *********************//
    //checks if the sellList is empty or not 
    function sellListisEmpty() external returns (bool){
        
        if (!sellList[0].Exists)
        {
            return true;

        }
        else
        {
            return false;
        }
        
    }
//*******************  sellListMaxDelete () ***************************//
    //the highest priority item (the lowest ask) will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function sellListMaxDelete() external returns (uint256, address)
    {
        require(sellList[0].Exists,'sellList is empty!');            //the delete function throws exception if the list is empty
        
        
        if (sellIndex == 0) 
        {
            uint256 _price =  sellList[0].Price;
            address _sender =  sellList[0].Sender;
            delete sellList[0]; 
            return (_price,_sender);
        }
            
        
        if (sellIndex == 1) {                               // if the heap has only one item
   
            uint256 _price =  sellList[0].Price;
            address _sender =  sellList[0].Sender;
            sellList[0] = sellList[1];
            delete sellList[1];                                   //the only element of the heap is removed and returned  
            sellIndex --;
            return (_price,_sender);
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
      
        uint256 _price =  sellList[0].Price;
        address _sender =  sellList[0].Sender;
        sellList[0] = sellList[sellIndex];                      //the last elementof the heap is removed and written into the first position
        delete sellList[sellIndex]; 
        sellIndex--;
        minheapHeapifyDown();                           //now the heapifyDown is called to restore the ordering of the heap 
        return (_price,_sender);
    }
//*******************  minheapHeapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function minheapHeapifyDown () internal returns (bool) {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild <= sellIndex ){               //as long as the left child is within the array that heap is stored in
            uint256 min = leftchild;
            uint256 rightchild = leftchild + 1;              //rightchild = 2k+2

            if (rightchild < sellIndex )                //if there is a rightchild, then the right child and left child are compared
            {
                if (sellList[rightchild].AuxPrice < sellList[leftchild].AuxPrice)
                {    min++;   }                               //now min is set to rightchild, otherwise min remains to be the leftchild
            }

            if (sellList[min].AuxPrice < sellList[k].AuxPrice) //compares the k item with the max item and if its less they are swapped
            {
                
                OrderStruct memory temp = sellList[k];    //swap the element at index k with its parent
                sellList[k] = sellList[min];
                sellList[min] = temp;

                k = min; //k is set to min
                leftchild = 2*k + 1; //l is recompuetd in preparation for the next iteration
            }
            else{ //if k item's smaller childer is not smaller than k item itself, heapifyDown should stop
                break;
            }

        }
        return true;
    }



}