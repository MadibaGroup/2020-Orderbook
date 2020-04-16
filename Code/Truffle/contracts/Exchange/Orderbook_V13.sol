pragma solidity >=0.4.22 <0.6.0;
//pragma experimental ABIEncoderV2;

//call martket (first version)
contract Orderbook_V13{

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
        uint256 Volume; //The volume is 1 for now
        //uint8 Type;         //1=Ask, 2=Bid

    }
//Every Auction has some attributes:
    struct AuctionStruct
    {
        uint256 CreationTime;
        uint256 NumOrders;      //Number of all the orders within the auction
        States state;
        bool isValue;
        uint256 BuyListCounter;  //the counter for BuyList which sorts the order incrementally
        uint256 SellListCounter;  //the counter for SellList which sorts the order decrementally
        OrderStruct[] BuyList;  //The array that contains Bid OrderStructs (descending (decremental)), we always want the highest bid (maxheap)
        OrderStruct[] SellList; //The array that contains Ask OrderStructs (ascending (incremental)), we always want the lowest ask (minheap)
    }    
    
    
    enum States {UnInitiallized, Opened, Closed} 
    //Opened: biddingTime, Settlement has not yet started.
    //Locked: biddingTime’s over, Settlement’s satrted and not finished yet.
    //Ended: biddingTime and Settlement are both over , which means the auction is ended. 
    uint256 numAuctions;
    mapping (uint256 => AuctionStruct) public Auctions;
    uint public biddingTime = 5 minutes;

    event LogBuyList (address _sender, uint256 _price, uint256 _volume);


//**********************************************//

//**********************************************//
    //Checks auction’s state.
    modifier CheckAuctionStage (uint256 _AuctionID) {
        if (Auctions[_AuctionID].isValue == false) {Auctions[_AuctionID].state = States.UnInitiallized;}
        if (now >= Auctions[_AuctionID].CreationTime + biddingTime || Auctions[_AuctionID].NumOrders == 1000) 
        {
            Auctions[_AuctionID].state = States.Closed;
            CloseMarket(_AuctionID);
            
        }
        _;
    }
    
    modifier ToPlaceOrderAuctionAtStage (uint256 _AuctionID , States state_1) { 
        require (Auctions[_AuctionID].state == state_1);
        _;
    }
    
    modifier AuctionAtStage (uint256 _AuctionID , States state_1 ) { 
        require (Auctions[_AuctionID].state == state_1); 
        _;
    }
    
//******************** OpenMarket function ********************//
    
    function OpenMarket() public returns (uint256 _AuctionID){
    

        _AuctionID = numAuctions++;
        
        Auctions[_AuctionID].CreationTime = now; 
        Auctions[_AuctionID].NumOrders = 0;
        Auctions[_AuctionID].state = States.Opened;
        Auctions[_AuctionID].isValue = true;
        Auctions[_AuctionID].BuyListCounter = 999;
        Auctions[_AuctionID].SellListCounter = 0;
        

    }
//******************** CloseMarket function ********************//
    
    function CloseMarket(uint256 _AuctionID) public 
    CheckAuctionStage (_AuctionID)
    returns (bool){

        MatchOrders(_AuctionID);
        return true;

    }
//******************** MatchOrders function ********************//
    function MatchOrders(uint256 _AuctionID) public 
    AuctionAtStage (_AuctionID, States.Closed)
    returns (bool){
        
        
        
        
        
        
        
        
        
        
    }    
//******************** submitBid function ********************//
    //submitBid function calls the maxheap_insert function    
    
    function submitBid (uint256 _AuctionID, uint256 _price, uint256 _volume ) public 
    CheckAuctionStage (_AuctionID) 
    ToPlaceOrderAuctionAtStage (_AuctionID, States.Opened)
    returns (bool)
    {
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (Auctions[_AuctionID].BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        
        if(maxheap_insert( _AuctionID , msg.sender, _finalpriceUint, _volume)){
            Auctions[_AuctionID].BuyListCounter--;
            Auctions[_AuctionID].NumOrders++;
            
        }
        
    
        return true;
    }

//******************** submitask function ********************//
    //submitAsk function calls the minheap_insert function
    function submitAsk (uint256 _AuctionID, uint256 _price, uint256 _volume ) public 
    CheckAuctionStage (_AuctionID) 
    ToPlaceOrderAuctionAtStage (_AuctionID, States.Opened)
    returns (bool)
    {

        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (Auctions[_AuctionID].SellListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        if (minheap_insert( _AuctionID, msg.sender, _finalpriceUint, _volume))
        {
                Auctions[_AuctionID].SellListCounter++;
                Auctions[_AuctionID].NumOrders++;
        }
        
        return true;

    }

//*******************  maxheap Functions (BuyList) ****************//
//*****************************************************************//
//*****************************************************************//
//*****************************************************************//


//*******************  maxheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function maxheap_insert (uint256 _AuctionID, address _sender, uint256 _price, uint256 _volume) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool)
    {
        
        OrderStruct memory neworder = OrderStruct(_sender, _price ,_volume);
        Auctions[_AuctionID].BuyList.push(neworder);
        maxheap_heapifyUp (_AuctionID);
        return true;
    }    
//*******************  maxheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new Buy order is submitted) and
    //now the heap has to be sorted again
    function maxheap_heapifyUp (uint256 _AuctionID) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool) {
    
        uint256 k = Auctions[_AuctionID].BuyList.length - 1;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (Auctions[_AuctionID].BuyList[k].Price > Auctions[_AuctionID].BuyList[p].Price) //if the element is greater than its parent
            {   //"!SYNTAX!"
                //Orderbook_V9.swap(SellList, k, p);              //swap the element at index k with its parent
                OrderStruct memory temp = Auctions[_AuctionID].BuyList[k];    //"!SYNTAX!"//swap the element at index k with its parent
                Auctions[_AuctionID].BuyList[k] = Auctions[_AuctionID].BuyList[p];
                Auctions[_AuctionID].BuyList[p] = temp;
                k = p;                                  //k moves up one level
            }
            else {break;}                               //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        return true;
    }
//*******************  minheap Functions (SellList) ****************//
//*****************************************************************//
//*****************************************************************//
//*****************************************************************//

//*******************  minheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function minheap_insert (uint256 _AuctionID, address _sender, uint256 _price, uint256 _volume) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _price ,_volume); 
        Auctions[_AuctionID].SellList.push(neworder);
        minheap_heapifyUp(_AuctionID);
        return true;
    }

//*******************  minheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new sell order is submitted) and
    //now the heap has to be sorted again
    function minheap_heapifyUp (uint256 _AuctionID) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool) {

        uint256 k = Auctions[_AuctionID].SellList.length - 1; //k is set to be the last entry of the array(also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                      //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                            //we need to compute the parent of this last element which is p = (k-1)/2
            if (Auctions[_AuctionID].SellList[k].Price < Auctions[_AuctionID].SellList[p].Price) //if the element is greater than its parent
            { 
            
                OrderStruct memory temp = Auctions[_AuctionID].SellList[k];    //swap the element at index k with its parent
                Auctions[_AuctionID].SellList[k] = Auctions[_AuctionID].SellList[p];
                Auctions[_AuctionID].SellList[p] = temp;
                
                k = p; //k moves up one level
            }
            else {break;} //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        
        return true;
    }








//************************************************************************//
    
    function ReadBuyList(uint256 _AuctionID) public {
        for (uint i = 0; i< Auctions[_AuctionID].BuyList.length ; i++) {
            emit LogBuyList(Auctions[_AuctionID].BuyList[i].Sender, Auctions[_AuctionID].BuyList[i].Price, Auctions[_AuctionID].BuyList[i].Volume);
            
        }
        
    }


//************************************************************************//
//************************************************************************//
//************************************************************************//

}
