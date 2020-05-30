pragma solidity >=0.4.22;
//pragma experimental ABIEncoderV2;


contract Orderbook_V12{




//************************String Converaion and Contcatenation************************//


function str2uint (string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint i;
        uint result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    
    return result;
    }

function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

// Contcatenation of strings
    /*function contcat(string memory a, string memory b, string memory c ) internal pure returns (string memory) {

        return string (abi.encodePacked( a , b, c));


    }*/
    function contcat(string memory a, string memory b) internal pure returns (string memory) {

        return string (abi.encodePacked( a , b));


    }

//*********************************************************************************//

//**********************************************//
//Every order has some attributes:
    struct OrderStruct
    {
        address Sender;
        uint256 Price;
        uint256 Volume;

    }

//**********************************************//
    OrderStruct[] public BuyList;  //The array that contains Bid OrderStructs (ascending (incremental))
    OrderStruct[] public SellList; //The array that contains Ask OrderStructs (descending (deccremental) = maxheap)
    
    //mapping (address => OrderStruct[]) BuyListMappig;
    
    
    uint256 BuyListCounter;  //the counter for BuyList which sorts the order incrementally
    uint256 SellListCounter = 999;  //the counter for SellList which sorts the order decrementally
    //enum States {Empty, NonEmpty} 
    //States public state;
    uint256 public CreationTime;

    

//**********************************************//

    
    
    
    
    
//**********************************************//

    //SellListpeak function returns the highest priority element
    function Flush () internal returns (bool success){
        
        delete BuyList;
        delete SellList;
        BuyListCounter = 1000;
        SellListCounter = 1999;
        return true;    
        
    }
    
    
    modifier isinitialized () {
        if ( BuyList.length == 0 && SellList.length == 0){ 
            CreationTime = now; 
            
        } 
        _;
    }
    modifier iftobeFlushed () {
        if (now >= CreationTime + 3 minutes || SellListCounter == 1000 || BuyListCounter == 1999  ) { 
            
            
            Flush();
            CreationTime = now;
        }
        
        _;
    }
    
    
    
//******************** submitBid function ********************//
    //submitBid function calls the minheap_insert function    
    function submitBid (uint256 _price, uint256 _volume ) public isinitialized() iftobeFlushed() returns (bool){
        
        /*uint256 _finalpriceUint;
        string memory _finalpriceString; 
        
        if ( BuyListCounter < 10){
            _finalpriceString = contcat ( uint2str(_price), "00", uint2str (BuyListCounter));
            _finalpriceUint = str2uint (_finalpriceString);
        }
        if ( 10 <= BuyListCounter && BuyListCounter < 100){
            _finalpriceString = contcat ( uint2str(_price), "0", uint2str (BuyListCounter));
            _finalpriceUint = str2uint (_finalpriceString);
        }
        if ( 100 <= BuyListCounter && BuyListCounter < 1000){
            _finalpriceString = contcat2 ( uint2str(_price), uint2str (BuyListCounter));
            _finalpriceUint = str2uint (_finalpriceString);
        }*/
        
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        if (minheap_insert( msg.sender, _finalpriceUint, _volume))
        {
                BuyListCounter ++;
        }
    
        return true;
    }
//******************** submitask function ********************//
    //submitAsk function calls the maxheap_insert function
    function submitAsk (uint _price, uint _volume ) public isinitialized() iftobeFlushed() returns (bool) {

        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        if(maxheap_insert( msg.sender, _finalpriceUint, _volume))
        {
                SellListCounter --;
        }
        
        return true;

    }
//**********************************************//


//************************************************************************//
//*********************     function modifiers    ************************//
//************************************************************************//



//************************************************************************//
//*********************     auxillary functions    ************************//
//************************************************************************//


//****************   ordertype function  *********************//
    //ordertype order checks if the incoming order is a bid or ask
    /*function ordertype ( bool _type ) private returns (bool success){

        OrderStruct memory temp = a[i];    //"!SYNTAX!"
        a[i] = a[j];
        a[p] = temp;
    }*/


//****************   swap function  *********************//
    //swap function swaps the elements i and j in the array list (i=k, j=p)
    /*function swap(OrderStruct[]  a, uint i, uint j ) internal returns (bool success){

        OrderStruct memory temp = a[i];    //"!SYNTAX!"
        a[i] = a[j];
        a[j] = temp;
    }*/


//****************   BuyListpeak function  *********************//
    //BuyListpeak function returns the highest priority element
    function BuyListpeak() public view returns (address, uint256 , uint256){
    //function BuyListpeak() public returns (uint256 _price){

        //require(BuyList.length != 0, “BuyList length is 0”) //Shayan
        if (BuyList.length == 0) { revert(); } //the delete function throws exception if the heap is empty
        //_sender =  BuyList[0].Sender;
        //_price = BuyList[0].Price;
        //_volume = BuyList[0].Volume;
        return (BuyList[0].Sender, BuyList[0].Price,BuyList[0].Volume );
    }



//****************   SellListpeak function  *********************//
    //SellListpeak function returns the highest priority element
    function SellListpeak() public view returns (address, uint256, uint256){

        if (SellList.length == 0) { revert(); } //the delete function throws exception if the heap is empty
        //_sender =  SellList[0].Sender;
        //_price = SellList[0].Price;
        //_volume = SellList[0].Volume;
        return (SellList[0].Sender, SellList[0].Price, SellList[0].Volume);
    }




//************************************************************************//
//*********************     Maxheap (SellList)    ************************//
//************************************************************************//


//*******************  maxheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new sell order is submitted) and
    //now the heap has to be sorted again
    function maxheap_heapifyUp () internal {
        uint256 k = SellList.length - 1;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (SellList[k].Price > SellList[p].Price) //if the element is greater than its parent
            {   //"!SYNTAX!"
                //Orderbook_V9.swap(SellList, k, p);              //swap the element at index k with its parent
                OrderStruct memory temp = SellList[k];    //"!SYNTAX!"//swap the element at index k with its parent
                SellList[k] = SellList[p];
                SellList[p] = temp;
                k = p;                                  //k moves up one level
            }
            else {break;}                               //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
    }
//*******************  maxheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function maxheap_heapifyDown () internal {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < SellList.length)
        {                                   //as long as the left child is within the array that heap is stored in
            uint max = leftchild;
            uint rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < SellList.length)                                       //if there is a rightchild
            {
                if (SellList[rightchild].Price > SellList[leftchild].Price)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (SellList[k].Price < SellList[max].Price)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            //swap k with its greatest children (max)
            //"!SYNTAX!"
            //Orderbook_V9.swap (SellList, k, max);
            OrderStruct memory temp = SellList[k];    //"!SYNTAX!"//swap the element at index k with its parent
            SellList[k] = SellList[max];
            SellList[max] = temp;
            k = max;                                                         //k is set to max
            leftchild =2*k + 1;                                              //l is recompuetd in preparation for the next iteration
        }
        else{                                                               //if the k item is not smaller than the max item, heapifyDown should stop
            break;
            }
        }
    }

//*******************  maxheap_insert () ***************************//
    //the new item will be added to the end of the array list (a sell order is submitted)
    //then heapified up with a call to heapifyUp method
    function maxheap_insert (address _sender, uint256 _price, uint256 _volume) internal returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _price ,_volume);
        SellList.push(neworder);
        maxheap_heapifyUp ();
        return(true);
    }

//*******************  maxheap_delete () ***************************//
    //the highest priority item will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function maxheap_delete () public returns (address, uint256, uint256) 
    {
        if (SellList.length == 0) { revert(); }                             //the delete function throws exception if the heap is empty
        if (SellList.length == 1) {                                      // if the heap has only one items
            OrderStruct memory result =  SellList[0];         //"!SYNTAX!"
            //delete SellList[0];  
            SellList.length--;                                        //the only element of the heap is removed and returned "!SYNTAX!"
            //_sender = result.Sender;
            //_price = result.Price;
            //_volume = result.Volume;
            return(result.Sender,result.Price,result.Volume);
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        OrderStruct memory result = SellList[0]; //the element on the of the heap is placed in the variable called hold
        SellList[0] = SellList[SellList.length -1]; //the last elementof the heap is removed and written into the first position
        //delete SellList [SellList.length -1];
        SellList.length--;
        maxheap_heapifyDown(); //now the siftdown is called
        return (result.Sender,result.Price,result.Volume);
    }

//************************************************************************//
//*********************     Minheap (BuyList)    ************************//
//************************************************************************//


//*******************  minheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new buy order is submitted) and
    //now the heap has to be sorted again
    function minheap_heapifyUp () internal {

        uint256 k = BuyList.length - 1;                   //k is set to be the last entry of the array(also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                 //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                          //we need to compute the parent of this last element which is p = (k-1)/2
            if (BuyList[k].Price < BuyList[p].Price) //if the element is greater than its parent
            { 
                //swap (BuyList, k, p); //swap k with its parent "!SYNTAX!"
            
                OrderStruct memory temp = BuyList[k];    //"!SYNTAX!"//swap the element at index k with its parent
                BuyList[k] = BuyList[p];
                BuyList[p] = temp;
                
                k = p; //k moves up one level
            }
            else {break;} //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
    }
//*******************  minheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function minheap_heapifyDown () internal returns (bool) {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < BuyList.length){               //as long as the left child is within the array that heap is stored in
            uint256 min = leftchild;
            uint256 rightchild = leftchild + 1;              //rightchild = 2k+2

            if (rightchild < BuyList.length)                //if there is a rightchild, then the right child and left child are compared
            {
                if (BuyList[rightchild].Price < BuyList[leftchild].Price)
                {    min++;   }                               //now min is set to rightchild, otherwise min remains to be the leftchild
            }

            if (BuyList[min].Price < BuyList[k].Price) //compares the k item with the max item and if its less they are swapped
            {
                //swap (BuyList, k, min); //swap k with its smaller children
                
                OrderStruct memory temp = BuyList[k];    //"!SYNTAX!"//swap the element at index k with its parent
                BuyList[k] = BuyList[min];
                BuyList[min] = temp;

                k = min; //k is set to min
                leftchild = 2*k + 1; //l is recompuetd in preparation for the next iteration
            }
            else{ //if k item's smaller childer is not smaller than k item itself, heapifyDown should stop
                break;
            }

        }
        return true;
    }
//*******************  minheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function minheap_insert (address _sender, uint256 _price, uint256 _volume) internal returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _price ,_volume); //"!SYNTAX!"
        BuyList.push(neworder);
        minheap_heapifyUp(); //"!SYNTAX!"
        return true;
        //uint256 x = 3;
        //return x;
    }

//*******************  minheap_delete () ***************************//
    //the highest priority item (the smallest bid) will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function minheap_delete () public returns (address, uint256, uint256)
    //function minheap_delete () public view returns (uint256 _price)
    {
        if (BuyList.length == 0) { revert(); }                      //the delete function throws exception if the heap is empty
        if (BuyList.length == 1) {                               // if the heap has only one item
            OrderStruct memory result = BuyList[0];  //"!SYNTAX!"
            //delete BuyList[0];                                   //the only element of the heap is removed and returned  "!SYNTAX!"
            BuyList.length--;   
            return (result.Sender, result.Price, result.Volume);                                       // "!SYNTAX!"
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        //_sender = BuyList[0].Sender;
        //_price = BuyList[0].Price;
       // _volume = BuyList[0].Volume;
        OrderStruct memory result = BuyList[0];
        //OrderStruct memory hold = BuyList[0];                        //the element on the of the heap is placed in the variable called hold "!SYNTAX!"
        BuyList[0] = BuyList[BuyList.length -1];                      //the last elementof the heap is removed and written into the first position
        //delete BuyList[BuyList.length -1]; 
        BuyList.length--;                  //"!SYNTAX!"
        minheap_heapifyDown();                           //now the heapifyDown is called to restore the ordering of the heap "!SYNTAX!"
        return(result.Sender, result.Price, result.Volume);        //"!SYNTAX!"
    }

//************************************************************************//
//************************************************************************//
//************************************************************************//

}
