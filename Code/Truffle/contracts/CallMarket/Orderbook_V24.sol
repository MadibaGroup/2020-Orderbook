pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


//Call market that stores the order structs in the mapping and have keys for them. Stores the keys in the sorted heap that is implemented by dynamic array
contract Orderbook_V24{


function getState() public view returns (States)
  {
    return state;
  }


//****************************************************//
//********String Converaion and Contcatenation********//
//****************************************************//

//****************  str2uint() function ***************************//
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
//****************  uint2str() function ***************************//
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
//****************  contcat() function ***************************//    
    function contcat(string memory a, string memory b) internal pure returns (string memory) {

        return string (abi.encodePacked( a , b));
    }

//****************************************************//
//****************************************************//
//****************************************************//
//constructor: Set the state the auctions as Settled
  constructor () public{
    state = States.Settled;   
  }

//**************** OrderStruct ***************************//
//Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        uint256 AuxPrice;   //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
        uint256 Volume;     //The volume is 1 for now
        
    }

//****************************************************//

    //OrderStruct[] BuyList;  //The array that contains Bid OrderStructs (descending (decremental)), we always want the highest bid (maxheap)
    //OrderStruct[] SellList; //The array that contains Ask OrderStructs (ascending (incremental)), we always want the lowest ask (minheap)
    mapping(uint => OrderStruct) public BuyList;
    mapping(uint => OrderStruct) public SellList;
    uint[] BuyListHeap;
    uint[] SellListHeap;
    uint public BuyListKey;
    uint public SellListKey;


    
    enum States {Opened, Closed, Settled} 
    //Opened: biddingTime, Settlement has not yet started.
    //Closed: biddingTime’s over, Settlement’s satrted and not finished yet.
    //Settled: biddingTime and Settlement are both over , which means the auction is ended and everything is wiped and settled
    
    uint256 public CreationTime;
    uint256 public NumOrders;        //Number of all the orders within the auction
    uint256 public BuyListCounter;   //the counter for BuyList which sorts the order incrementally
    uint256 public SellListCounter;  //the counter for SellList which sorts the order decrementally
    States state;
    address public Token;            //The token that is being traded in the auction



    uint public biddingTime = 5 minutes;

    event LogBuyList (address _sender, uint256 _price, uint256 _volume);
    event TransferToken (address _from, address _to, uint256 _numofTokens);
    event TransferEther (address _from, address _to, uint256 _numofEther);
    event TradeHappens (uint256 _BuyPrice, uint256 _SellPrice);


//**********************************************//
//***************Function Modifiers*************//
//**********************************************//
 
    //Checks if the auction should be closed or not.
    modifier CheckAuctionStage () {
        //if (Auctions[_AuctionID].isValue == false) {Auctions[_AuctionID].state = States.UnInitiallized;}
        if (now >= CreationTime + biddingTime || NumOrders == 1000) 
        {
            state = States.Closed;
            CloseMarket();
            
        }
        _;
    }

//**********************************************// 
    //Checks wether the auction is at state_1 or not (Check this again! Seems to be the same thing with the one above)
    modifier AuctionAtStage (States state_1 ) { 
        require (state == state_1); 
        _;
    }
//**********************************************// 



//**********************************************//
//*********Escrow Variables and Functions*******//
//**********************************************//
    
    //To make the escrow fully general, the contract does not assume a specific ERC20 token, 
    //so a single account may escrow different tokens at the same time. 
    //For each (account, token) pair, the contract tracks its balance and the time when escrow expires:
    //User (Sellers) => Token => balanace
    mapping(address => mapping(address => uint256)) public TotalTokenBalance;
    mapping(address => mapping(address => uint256)) public AvailableTokenBalance;
    //mapping(address => mapping(address => uint256)) public escrowExpiration;
    
    //User (Biders) => balance(Ether)
    mapping(address => uint256) public TotalEtherBalance;
    mapping(address => uint256) public AvailableEtherBalance;

//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _numofTokens) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _numofTokens));
        TotalTokenBalance[msg.sender][_token] += _numofTokens;
        AvailableTokenBalance[msg.sender][_token] += _numofTokens;
        return true;
    
    }
//**************DepositEther() Function*********************//    
    
    function DepositEther(uint256 _numofEthers) public payable returns (bool) {
        TotalEtherBalance[msg.sender] += _numofEthers;
        AvailableEtherBalance[msg.sender] += _numofEthers;
        return true;
        
    }


//******************** OpenMarket function ********************//
    //To open a market(auction) on an specific token, user has to call OpenMarket() function and pass the address of ERC20 token to it
    function OpenMarket(address _token) public 
    AuctionAtStage(States.Settled)
    returns (bool) {
    
        
        CreationTime = now; 
        state = States.Opened;
        NumOrders = 0;
        SellListCounter = 0;
        BuyListCounter = 999;
        SellListKey = 0;
        BuyListKey = 0;
        Token = _token;
        
        return true;

    }

//******************** CloseMarket() function ********************//
    
    function CloseMarket() public returns (bool){
        //MatchOrders(_AuctionID);
        state = States.Closed;
        return true;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    }
//******************** MatchOrders() function ********************//
    function MatchOrders() public AuctionAtStage (States.Closed) returns (bool){
  
        uint256 refund;
        uint256 counter;

        if (BuyListHeap.length >= SellListHeap.length) {counter = SellListHeap.length;}
        else {counter = BuyListHeap.length;} 
        
        //while (BuyList.length != 0 &&SellList.length != 0 && BuyListPeak().Price >= SellListPeak().Price)
        for (uint i =1 ; i <= counter; i++)
        //uint i =1;
        //while (i <= counter)
        {   
            if (BuyListPeak().Price >= SellListPeak().Price)
            {

                emit TradeHappens (BuyListPeak().Price, SellListPeak().Price);
                OrderStruct memory temp_BestBid = BuyListPeak();
                OrderStruct memory temp_BestAsk = SellListPeak();
                transferToken (temp_BestAsk.Sender, temp_BestBid.Sender, Token, temp_BestBid.Volume);
                transferEther (temp_BestBid.Sender,temp_BestAsk.Sender, Token, temp_BestAsk.Price);
                
                
                BuyListDelete();
                SellListDelete();



            }
            else{break;}
            //i++;    
        }
            
            //Pays the difference to the miner
            /*if (temp_BestBid.Price - temp_BestAsk.Price != 0) 
            {
                EtherBalance[block.coinbase] += temp_BestBid.Price - temp_BestAsk.Price;
                refund = EtherBalance[block.coinbase]; 
                EtherBalance[block.coinbase] = 0; 
                block.coinbase.transfer(refund);
            }*/
             
            
        
        
        if (BuyListHeap.length != 0)
        {
            Rrefund_unexecuted_Buy_orders();
        }
        
        if (SellListHeap.length != 0)
        {
            Rrefund_unexecuted_Sell_orders(); 
        }
        
        state = States.Settled;
        return true;

        
    }
    //******************** Rrefund_unexecuted_Buy_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "Ethers" for those trades that did not happen
    function Rrefund_unexecuted_Buy_orders () internal returns (bool) {

        


        uint i;
        while (BuyListHeap.length != 0)
        {
            i = BuyListHeap.length - 1;
            AvailableEtherBalance[BuyList[i].Sender] += BuyList[BuyListHeap[i]].Volume * BuyList[BuyListHeap[i]].Price;
            BuyListHeap.pop();
            
            
        }
        
        return true;
    }
    
    //******************** Rrefund_unexecuted_Sell_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "tokens" for those trades that did not happen
    function Rrefund_unexecuted_Sell_orders () internal returns (bool) {
        
        
        
        uint i;
        while (SellListHeap.length != 0)
        {
            i = SellListHeap.length - 1;
            AvailableTokenBalance[SellList[SellListHeap[i]].Sender][Token] += SellList[SellListHeap[i]].Volume;
            SellListHeap.pop();
           
            
        }
        
        return true;
    }
  
//******************** transferToken() & transferEther() internal ********************//    
    //These two functions are fired During the order matching 
    function transferToken( address _fromSeller, address _toBuyer, address _token, uint256 _numofTokens) internal
    {

        TotalTokenBalance[_fromSeller][_token] -= _numofTokens;
               
        TotalTokenBalance[_toBuyer][_token] += _numofTokens;
        AvailableTokenBalance[_toBuyer][_token] += _numofTokens;
        
        emit TransferToken (_fromSeller, _toBuyer, _numofTokens);
    }
//******************************************************//    
    function transferEther( address _fromBuyer, address _toSeller, address _token, uint256 _numofEthers) internal
    {
        TotalEtherBalance[_fromBuyer] -= _numofEthers;
        
        TotalEtherBalance[_toSeller] += _numofEthers;
        AvailableEtherBalance[_toSeller] += _numofEthers;
        
        emit TransferEther (_fromBuyer, _toSeller, _numofEthers);
    } 
//******************************************************// 


//******************** claimTokens() & claimEther() ********************//
    //traders can claim their tokens or ethers uisng the following two functions

    function claimTokens (address _token, uint256 _numofTokens ) public returns (bool)
    {
        require (AvailableTokenBalance[msg.sender][_token] > _numofTokens);
        uint tokensToBeClaimed = _numofTokens ;
        AvailableTokenBalance[msg.sender][_token] -= tokensToBeClaimed;
        TotalTokenBalance[msg.sender][_token] -= tokensToBeClaimed;
        IERC20(_token).transfer(msg.sender, tokensToBeClaimed);
        return true;
    }
//******************************************************//      
    function claimEther (uint256 _numofEthers) public returns (bool)
    {
        require (AvailableEtherBalance[msg.sender] > _numofEthers);
        uint EthersToBeClaimed = _numofEthers ;
        AvailableEtherBalance[msg.sender] -= EthersToBeClaimed;
        AvailableEtherBalance[msg.sender] -= EthersToBeClaimed;
        msg.sender.transfer(EthersToBeClaimed);
        return true;
    }    

 

//******************** submitBid() function ********************//
    //submitBid function calls the maxheap_insert function    
    //The Bidder must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint256 _price, uint256 _volume) public
    CheckAuctionStage ()
    AuctionAtStage (States.Opened)
    returns (bool)
    {
        require (AvailableEtherBalance[msg.sender] >= _volume * _price );
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        
        OrderStruct memory neworder = OrderStruct(msg.sender, _price, _finalpriceUint, _volume);
        BuyList[BuyListKey] = neworder;


        if (maxheap_insert(BuyListKey)){
            BuyListCounter--;
            NumOrders++;
            BuyListKey++;
            AvailableEtherBalance[msg.sender] -= _volume * _price;
            
        }
    
        return true;
    }

//******************** submitask() function ********************//
    //submitAsk function calls the minheap_insert function
    //The Bidder must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint256 _price, uint256 _volume ) public 
    CheckAuctionStage () 
    AuctionAtStage (States.Opened)
    returns (bool)
    {
        require( AvailableTokenBalance[msg.sender][Token] >= _volume);
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (SellListCounter));
        _finalpriceUint = str2uint (_finalpriceString);

        OrderStruct memory neworder = OrderStruct(msg.sender, _price, _finalpriceUint, _volume);
        SellList[SellListKey] = neworder;
        
        if (minheap_insert(SellListKey))
        {
                SellListCounter++;
                NumOrders++;
                SellListKey++;
                AvailableTokenBalance[msg.sender][Token] -= _volume;
        }
        
        return true;

    }
//*****************************************************************//
//*******************  maxheap Functions (BuyList) ****************//
//*****************************************************************//


//*******************  maxheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function maxheap_insert (uint _BuyListKey) internal 
    CheckAuctionStage ()
    returns (bool)
    {
        
        //OrderStruct memory neworder = OrderStruct(_sender, _price , _auxPrice, _volume);
        //BuyList[_BuyListKey] = neworder;
        BuyListHeap.push(_BuyListKey);
        maxheap_heapifyUp ();
        return true;
    }    
//*******************  maxheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new Buy order is submitted) and
    //now the heap has to be sorted again
    function maxheap_heapifyUp () internal 
    CheckAuctionStage ()
    returns (bool) {
    
        uint256 k = BuyListHeap.length - 1;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (BuyList[BuyListHeap[k]].Price > BuyList[BuyListHeap[p]].Price) 
            {   
                uint temp = BuyListHeap[k];    //swap the element at index k with its parent
                BuyListHeap[k] = BuyListHeap[p];
                BuyListHeap[p] = temp;
                k = p;                                  //k moves up one level
            }
            else {break;}                               //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        return true;
    }
//*******************  maxheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function maxheap_heapifyDown () internal 
    CheckAuctionStage ()
    returns (bool)
    {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < BuyListHeap.length)
        {                                   //as long as the left child is within the array that heap is stored in
            uint max = leftchild;
            uint rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < BuyListHeap.length)                                       //if there is a rightchild
            {
                if (BuyList[BuyListHeap[rightchild]].Price > BuyList[BuyListHeap[leftchild]].Price)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (BuyList[BuyListHeap[k]].Price < BuyList[BuyListHeap[max]].Price)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            //swap k with its greatest children (max)
            //"!SYNTAX!"
            //Orderbook_V9.swap (SellList, k, max);
            uint temp = BuyListHeap[k];    //"!SYNTAX!"//swap the element at index k with its parent
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
    
//****************   BuyListpeak()  *********************//
    //BuyListpeak function returns the highest priority element (The highest bid)
    function BuyListPeak() public  
    CheckAuctionStage ()
    //returns (address, uint256, uint256, uint256){
    returns (OrderStruct memory){

        
        //require (BuyList.length != 0); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[BuyListHeap[0]]);
        //return (BuyList[0].Sender, BuyList[0].Price, BuyList[0].AuxPrice, BuyList[0].Volume );
    }
    
    //Function Overloading: When BuyListpeak() is called from inside of the MatchingOrder(), it recieves an array as paramater  
    /*function BuyListPeak(OrderStruct[] memory _array) internal view returns (OrderStruct memory){

        require(_array.length != 0); //throws exception if the list is empty
        return (_array[0]);
    }*/
    
//*******************  maxheap_delete () ***************************//
    //the highest priority item will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function BuyListDelete () public 
    CheckAuctionStage ()
    returns (OrderStruct memory) 
    {
        if (BuyListHeap.length == 0) { revert(); }                             //the delete function throws exception if the heap is empty
        if (BuyListHeap.length == 1) {                                      //if the heap has only one items
                     
            OrderStruct memory result =  BuyList[BuyListHeap[0]];
            
            BuyListHeap.pop();                                                 //the only element of the heap is removed and returned 
            //delete BuyList[[BuyListHeap[0]]];
            NumOrders --;
            return result;     
       
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        OrderStruct memory result =  BuyList[BuyListHeap[0]];
        BuyListHeap[0] = BuyListHeap[BuyListHeap.length -1]; //the last elementof the heap is removed and written into the first position
        //delete BuyList[[BuyListHeap[0]]];
        BuyListHeap.pop();
        maxheap_heapifyDown(); //now the siftdown is called
        NumOrders --;
        return result;
    }
    
//*****************************************************************//
//*******************  minheap Functions (SellList) ****************//
//*****************************************************************//

//*******************  minheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function minheap_insert (uint _SellListKey) internal 
    CheckAuctionStage ()
    returns (bool)
    {
        //OrderStruct memory neworder = OrderStruct(_sender, _price , _auxPrice, _volume); 
        //SellList.push(neworder);
        SellListHeap.push(_SellListKey);
        minheap_heapifyUp();
        return true;
    }

//*******************  minheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new sell order is submitted) and
    //now the heap has to be sorted again
    function minheap_heapifyUp () internal 
    CheckAuctionStage ()
    returns (bool) {

        uint256 k = SellListHeap.length - 1; //k is set to be the last entry of the array(also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                      //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                            //we need to compute the parent of this last element which is p = (k-1)/2
            if (SellList[SellListHeap[k]].Price < SellList[SellListHeap[p]].Price) //if the element is greater than its parent
            { 
            
                uint temp = SellListHeap[k];    //swap the element at index k with its parent
                SellListHeap[k] = SellListHeap[p];
                SellListHeap[p] = temp;
                
                k = p; //k moves up one level
            }
            else {break;} //if not the break statement exits the loop (it continues until no element index k is not greater than its parent)
        }
        
        return true;
    }
//*******************  minheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function minheap_heapifyDown () internal 
    CheckAuctionStage ()
    returns (bool) {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < SellListHeap.length){               //as long as the left child is within the array that heap is stored in
            uint256 min = leftchild;
            uint256 rightchild = leftchild + 1;              //rightchild = 2k+2

            if (rightchild < SellListHeap.length)                //if there is a rightchild, then the right child and left child are compared
            {
                if (SellList[SellListHeap[rightchild]].Price < SellList[SellListHeap[leftchild]].Price)
                {    min++;   }                               //now min is set to rightchild, otherwise min remains to be the leftchild
            }

            if (SellList[SellListHeap[min]].Price < SellList[SellListHeap[k]].Price) //compares the k item with the max item and if its less they are swapped
            {
                //swap (BuyList, k, min); //swap k with its smaller children
                
                uint temp = SellListHeap[k];    //"!SYNTAX!"//swap the element at index k with its parent
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

//****************   SellListpeak()  *********************//
    //SellListpeak function returns the highest priority element (The Lowest ask)
    function SellListPeak() public 
    CheckAuctionStage ()
    //returns (address, uint256, uint256, uint256){
    returns (OrderStruct memory){

        //require(SellList.length != 0); //throws exception if the minheap (SellList) is empty
        
        return (SellList[SellListHeap[0]]);
        //return (SellList[0].Sender, SellList[0].Price, SellList[0].AuxPrice, SellList[0].Volume );
    }
    //Function Overloading: When SellListpeak() is called from inside of the MatchingOrder(), it recieves just an array (and not an AuctionID) as paramater  
    /*function SellListPeak(OrderStruct[] memory _array) internal view returns (OrderStruct memory){

        require(_array.length != 0); //throws exception if the list is empty
        return (_array[0]);
    }*/


//*******************  minheap_delete () ***************************//
    //the highest priority item (the smallest ask) will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function SellListDelete () public 
    CheckAuctionStage ()
    returns (OrderStruct memory)
    {
        if (SellListHeap.length == 0) { revert(); }                      //the delete function throws exception if the heap is empty
        if (SellListHeap.length == 1) {                               // if the heap has only one item
            OrderStruct memory result = SellList[SellListHeap[0]];
            //delete SellList[[SellListHeap[0]]];
            SellListHeap.pop();                                   //the only element of the heap is removed and returned  
            NumOrders --;
            return result;
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
      
        OrderStruct memory result = SellList[SellListHeap[0]];
        SellListHeap[0] = SellListHeap[SellListHeap.length -1];                      //the last elementof the heap is removed and written into the first position
        //delete SellList[[SellListHeap[0]]];
        SellListHeap.pop(); 
        minheap_heapifyDown();                           //now the heapifyDown is called to restore the ordering of the heap 
        NumOrders --;
        return result;        
    }

//************************************************************************//
//************************************************************************//
//************************************************************************//



//************************************************************************//
//************************************************************************//
//************************************************************************//

    //function returnSelllistlength () public returns (uint256 _result){
        //_result = SellList.length;
        //return _result;
    //}    
    
    
}   
    
    
    
    
    
    
    
    
    
    
    
    
    