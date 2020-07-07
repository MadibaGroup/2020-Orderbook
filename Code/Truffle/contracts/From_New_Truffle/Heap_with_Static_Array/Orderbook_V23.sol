pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


// The last vesrion of the call market implemented by Heap with static array
// define  a constant called MAXORDERS 
// Size the arrays to it and use it in the modifier to reject orders when you already have the max
//Call market with heap (static array is used to store the heap)
//Maximum number of order the Match function can handle : 18
contract Orderbook_V23{

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
  constructor (uint256 _MAXORDERS) public{
    state = States.Settled; 
    MAXORDERS = _MAXORDERS;
  }

//**************** OrderStruct ***************************//
//Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        uint256 AuxPrice;   //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
        uint256 Volume;     //The volume is 1 for now
        bool Exists;
    }

//****************************************************//
    uint256 public countervariable;
    uint256 public MAXORDERS;

    OrderStruct[35] BuyList;  //The array that contains Bid OrderStructs (descending (decremental)), we always want the highest bid (maxheap)
    OrderStruct[35] SellList; //The array that contains Ask OrderStructs (ascending (incremental)), we always want the lowest ask (minheap)
    
    
    enum States {Opened, Closed, Settled} 
    //Opened: biddingTime, Settlement has not yet started.
    //Closed: biddingTime’s over, Settlement’s satrted and not finished yet.
    //Settled: biddingTime and Settlement are both over , which means the auction is ended and everything is wiped and settled
    
    uint256 public CreationTime;
    uint256 public NumOrders;        //Number of all the orders within the auction
    uint256 public BuyListCounter;   //the counter for BuyList which sorts the order incrementally
    uint256 public SellIndex;
    uint256 public BuyIndex;
    uint256 public counter;
    uint256 public SellListCounter;  //the counter for SellList which sorts the order decrementally
    States state;
    address public Token;            //The token that is being traded in the auction



    uint256 public biddingTime = 5 minutes;

    event BidIsSubmitted (address indexed _sender, uint256 _price);
    event TokenDepositted (address indexed _sender, address indexed _token , uint256 _numofTokens);
    event LogBuyList (address _sender, uint256 _price, uint256 _volume);
    event TransferToken (address _from, address _to, uint256 _numofTokens);
    event TransferEther (address _from, address _to, uint256 _numofEther);
    event TradeHappens (uint256 _BuyPrice, uint256 _SellPrice);
    
    event EtherRefunded (address _owner, uint256 _amount);

   


//**********************************************//
//***************Function Modifiers*************//
//**********************************************//
 
    //Checks if the auction should be closed or not.
    modifier CheckAuctionStage () {
        //if (Auctions[_AuctionID].isValue == false) {Auctions[_AuctionID].state = States.UnInitiallized;}
        if (now >= CreationTime + biddingTime || NumOrders == MAXORDERS ) 
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
    //Checks whether we have reached to the total number of orders in the auction  
    modifier CheckMaxOrders () { 
        require (NumOrders <= MAXORDERS); 
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
    mapping(address => mapping(address => uint256)) public TokenBalance;
    
    //User (Biders) => balance(Ether)
    mapping(address => uint256) public EtherBalance;

//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _numofTokens) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _numofTokens));
        TokenBalance[msg.sender][_token] += _numofTokens;
        emit TokenDepositted (msg.sender,  _token , _numofTokens);
        return true;
    
    }
//**************DepositEther() Function*********************//    
    function DepositEther(uint256 _numofEthers) public payable returns (bool) {
        EtherBalance[msg.sender] += _numofEthers;
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
        BuyListCounter = MAXORDERS - 1;
        SellIndex = 0;
        BuyIndex = 0;
        Token = _token;
        
        return true;

    }

//******************** CloseMarket() function ********************//
    function CloseMarket() public returns (bool){
        state = States.Closed;
        return true;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    }
//******************** MatchOrders() function ********************//
    uint public test;
    function MatchOrders(address _token) public AuctionAtStage (States.Closed) returns (bool){
  
        while (BuyList[0].Price >= SellList[0].Price)
        {   
            countervariable++;
            
            TokenBalance[BuyList[0].Sender][_token] += BuyList[0].Volume;
            EtherBalance[SellList[0].Sender] += SellList[0].Price;
                
            BuyListDelete();
            SellListDelete();
            
            if (BuyList[BuyIndex].Exists == false || SellList[SellIndex].Exists == false) {break;}


        }
        

        // if (BuyIndex >= SellIndex) {counter = SellIndex;}
        // else {counter = BuyIndex;} 
        
        // //while (BuyList.length != 0 &&SellList.length != 0 && BuyListPeak().Price >= SellListPeak().Price)
        // for (uint256 i =1 ; i <= counter; i++)
        // //uint256 i =1;
        // //while (i <= counter)
        // {   
        //     if (BuyListPeak().Price >= SellListPeak().Price)
        //     {

        //         emit TradeHappens (BuyListPeak().Price, SellListPeak().Price);
        //         OrderStruct memory temp_BestBid = BuyListPeak();
        //         OrderStruct memory temp_BestAsk = SellListPeak();
        //         transferToken (temp_BestAsk.Sender, temp_BestBid.Sender, Token, temp_BestBid.Volume);
        //         transferEther (temp_BestBid.Sender,temp_BestAsk.Sender, Token, temp_BestAsk.Price);
                
                
        //         BuyListDelete();
        //         SellListDelete();



        //     }
        //     else{break;}
        //     //i++;    
        // }
            
        //Pays the difference to the miner
            /*if (temp_BestBid.Price - temp_BestAsk.Price != 0) 
            {
                EtherBalance[block.coinbase] += temp_BestBid.Price - temp_BestAsk.Price;
                refund = EtherBalance[block.coinbase]; 
                EtherBalance[block.coinbase] = 0; 
                block.coinbase.transfer(refund);
            }*/
             
            
        if (BuyList[BuyIndex].Exists != false)
        {
            Rrefund_unexecuted_Buy_orders();
        }  
        
        
        
        if (SellList[SellIndex].Exists != false)
        {
            Rrefund_unexecuted_Sell_orders(); 
        }
        
        state = States.Settled;
        return true;

        
    }
    //******************** Rrefund_unexecuted_Buy_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "Ethers" for those trades that did not happen
    function Rrefund_unexecuted_Buy_orders () internal returns (bool) {

        


        uint256 i;
        while (BuyIndex >= 0)
        {
            i = BuyIndex;
            EtherBalance[BuyList[i].Sender] += BuyList[i].Volume * BuyList[i].Price;
            delete BuyList[i];
            if (BuyIndex == 0){ break;}
            BuyIndex --;
            
            
        }
        
        return true;
    }
    
     //******************** Rrefund_unexecuted_Sell_orders function ********************//
     //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "tokens" for those trades that did not happen
    function Rrefund_unexecuted_Sell_orders () internal returns (bool) {
        
        
        
        uint256 i;
        while (SellIndex >= 0)
        {
            i = SellIndex ;
            TokenBalance[SellList[i].Sender][Token] += SellList[i].Volume;
            delete SellList[i];
            if (SellIndex == 0){ break;}
            SellIndex --;
           
            
        }
        
        return true;
    }
  
 //******************** transferToken() & transferEther() internal ********************//    
    //These two functions are fired During the order matching 
//     function transferToken( address _fromSeller, address _toBuyer, address _token, uint256 _numofTokens) internal
//     {

//         TotalTokenBalance[_fromSeller][_token] -= _numofTokens;
               
//         TotalTokenBalance[_toBuyer][_token] += _numofTokens;
//         AvailableTokenBalance[_toBuyer][_token] += _numofTokens;
        
//         emit TransferToken (_fromSeller, _toBuyer, _numofTokens);
//     }
// //******************************************************//    
//     function transferEther( address _fromBuyer, address _toSeller, address _token, uint256 _numofEthers) internal
//     {
//         TotalEtherBalance[_fromBuyer] -= _numofEthers;
        
//         TotalEtherBalance[_toSeller] += _numofEthers;
//         AvailableEtherBalance[_toSeller] += _numofEthers;
        
//         emit TransferEther (_fromBuyer, _toSeller, _numofEthers);
//     } 
 //******************************************************// 


//******************** claimTokens() & claimEther() ********************//
    //traders can claim their tokens or ethers uisng the following two functions

    function claimTokens (address _token, uint256 _numofTokens ) public returns (bool)
    {
        require (TokenBalance[msg.sender][_token] > _numofTokens);
        uint256 tokensToBeClaimed = _numofTokens ;
        TokenBalance[msg.sender][_token] -= tokensToBeClaimed;
        IERC20(_token).transfer(msg.sender, tokensToBeClaimed);
        return true;
    }
//******************************************************//      
    function claimEther (uint256 _numofEthers) public returns (bool)
    {
        require (EtherBalance[msg.sender] > _numofEthers);
        uint256 EthersToBeClaimed = _numofEthers ;
        EtherBalance[msg.sender] -= EthersToBeClaimed;
        msg.sender.transfer(EthersToBeClaimed);
        return true;
    }    

 

//******************** submitBid() function ********************//
    //submitBid function calls the maxheap_insert function    
    //The Bidder must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint256 _price, uint256 _volume) public CheckAuctionStage () AuctionAtStage (States.Opened) CheckMaxOrders()
    returns (bool)
    {
        require (EtherBalance[msg.sender] >= _volume * _price );
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        
        if (maxheap_insert(msg.sender, _price, _finalpriceUint, _volume)){
            BuyListCounter--;
            NumOrders++;
            EtherBalance[msg.sender] -= _volume * _price;
            emit BidIsSubmitted (msg.sender, _price);
            
        }
        
    
        return true;
    }

//******************** submitask() function ********************//
    //submitAsk function calls the minheap_insert function
    //The Bidder must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint256 _price, uint256 _volume ) public CheckAuctionStage() AuctionAtStage (States.Opened) CheckMaxOrders()
    returns (bool)
    {
        require(TokenBalance[msg.sender][Token] >= _volume);
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (SellListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        if (minheap_insert(msg.sender, _price, _finalpriceUint, _volume))
        {
            SellListCounter++;
            NumOrders++;
            TokenBalance[msg.sender][Token] -= _volume;
        }
        
        return true;

    }
//*****************************************************************//
//*******************  maxheap Functions (BuyList) ****************//
//*****************************************************************//


//*******************  maxheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function maxheap_insert (address _sender, uint256 _price, uint256 _auxPrice, uint256 _volume) internal 
    CheckAuctionStage ()
    returns (bool)
    {
        
        OrderStruct memory neworder = OrderStruct(_sender, _price , _auxPrice, _volume, true);

        if (BuyList[0].Exists == false)
        {
            BuyList[0] = neworder; 
        }
       else{
            BuyIndex ++;
            BuyList[BuyIndex] = neworder;
            maxheap_heapifyUp ();
       }    

        return true;
    }    
//*******************  maxheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new Buy order is submitted) and
    //now the heap has to be sorted again
    function maxheap_heapifyUp () internal 
    CheckAuctionStage ()
    returns (bool) {

        uint256 k = BuyIndex;                   //k is set to be the last entry of the array (also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                  //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                           //we need to compute the parent of this last element which is p = (k-1)/2
            if (BuyList[k].Price > BuyList[p].Price) //if the element is greater than its parent
            {   //"!SYNTAX!"
                //Orderbook_V9.swap(SellList, k, p);              //swap the element at index k with its parent
                OrderStruct memory temp = BuyList[k];    //"!SYNTAX!"//swap the element at index k with its parent
                BuyList[k] = BuyList[p];
                BuyList[p] = temp;
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
        while (leftchild < BuyIndex )
        {                                   //as long as the left child is within the array that heap is stored in
            uint256 max = leftchild;
            uint256 rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < BuyIndex )                                       //if there is a rightchild
            {
                if (BuyList[rightchild].Price > BuyList[leftchild].Price)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (BuyList[k].Price < BuyList[max].Price)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            //swap k with its greatest children (max)
            //"!SYNTAX!"
            //Orderbook_V9.swap (SellList, k, max);
            OrderStruct memory temp = BuyList[k];    //"!SYNTAX!"//swap the element at index k with its parent
            BuyList[k] = BuyList[max];
            BuyList[max] = temp;
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
    function BuyListPeak() public  CheckAuctionStage () returns (OrderStruct memory){

        require (BuyList[0].Exists == true, 'BuyList is empty!'); //throws exception if the maxheap (BuyList) is empty
        return (BuyList[0]);
    }
    
    
    
//*******************  maxheap_delete () ***************************//
    //the highest priority item will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function BuyListDelete () public CheckAuctionStage() returns (OrderStruct memory) 
    {
        if (BuyIndex == 0) {
              OrderStruct memory result =  BuyList[0];
              delete BuyList[0];
              NumOrders --;
              //emit BuyIndexChanged(BuyIndex);
              return result;
              
        }                           
        if (BuyIndex == 1){                                      //if the heap has two items
                     
            OrderStruct memory result =  BuyList[0];
            //delete BuyList[0];                                                 //the first element of the heap is removed 
            BuyList[0] = BuyList[1];
            delete BuyList[1];
            NumOrders --;
            BuyIndex --;
            //emit BuyIndexChanged(BuyIndex);
            return result;     
            
       
        }
        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        OrderStruct memory result =  BuyList[0];
        BuyList[0] = BuyList[BuyIndex]; //the last elementof the heap is removed and written into the first position
        delete BuyList[BuyIndex];
        maxheap_heapifyDown(); //now the siftdown is called
        NumOrders --;
        BuyIndex--;
        //emit BuyIndexChanged(BuyIndex);
        return result;
    }
    




//*****************************************************************//
//*******************  minheap Functions (SellList) ****************//
//*****************************************************************//

//*******************  minheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function minheap_insert (address _sender, uint256 _price, uint256 _auxPrice, uint256 _volume) internal 
    CheckAuctionStage ()
    returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _price , _auxPrice, _volume, true); 
        
        if (SellList[0].Exists == false)
        {
           SellList[0] = neworder;
           
        }
        else
        {
            SellIndex ++;
            SellList[SellIndex] = neworder;
            minheap_heapifyUp();
        }
    
        return true;
    }

//*******************  minheap_heapifyUp () ***************************//
    //this function is called everytime we insert a new element to the end of the array (aka a new sell order is submitted) and
    //now the heap has to be sorted again
    function minheap_heapifyUp () internal 
    CheckAuctionStage ()
    returns (bool) {

        uint256 k = SellIndex ; //k is set to be the last entry of the array(also heap) which is the element that's just added and has to be moved up
        while (k > 0){                                      //while we havent reached to the top of the heap
            uint256 p = (k-1)/2;                            //we need to compute the parent of this last element which is p = (k-1)/2
            if (SellList[k].Price < SellList[p].Price) //if the element is greater than its parent
            { 
            
                OrderStruct memory temp = SellList[k];    //swap the element at index k with its parent
                SellList[k] = SellList[p];
                SellList[p] = temp;
                
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
        while (leftchild < SellIndex ){               //as long as the left child is within the array that heap is stored in
            uint256 min = leftchild;
            uint256 rightchild = leftchild + 1;              //rightchild = 2k+2

            if (rightchild < SellIndex )                //if there is a rightchild, then the right child and left child are compared
            {
                if (SellList[rightchild].Price < SellList[leftchild].Price)
                {    min++;   }                               //now min is set to rightchild, otherwise min remains to be the leftchild
            }

            if (SellList[min].Price < SellList[k].Price) //compares the k item with the max item and if its less they are swapped
            {
                //swap (BuyList, k, min); //swap k with its smaller children
                
                OrderStruct memory temp = SellList[k];    //"!SYNTAX!"//swap the element at index k with its parent
                SellList[k] = SellList[min];
                SellList[min] = temp;

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

        require(SellList[0].Exists == true,'SellList is empty!'); //throws exception if the minheap (SellList) is empty
        
        return (SellList[0]);
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
        //if (SellList[SellIndex].Price == 0) {SellIndex--;}
        if (SellIndex == 0) {
            
            OrderStruct memory result = SellList[0];
            delete SellList[0]; 
            NumOrders --;
            return result;
        }
            
        
        if (SellIndex == 1) {                               // if the heap has only one item
            OrderStruct memory result = SellList[0];
            BuyList[0] = BuyList[1];
            delete SellList[1];                                   //the only element of the heap is removed and returned  
            NumOrders --;
            SellIndex --;
            return result;
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
      
        OrderStruct memory result = SellList[0];
        //delete SellList[0];
        SellList[0] = SellList[SellIndex];                      //the last elementof the heap is removed and written into the first position
        delete SellList[SellIndex]; 
        minheap_heapifyDown();                           //now the heapifyDown is called to restore the ordering of the heap 
        NumOrders --;
        SellIndex--;
        return result;        
    }

    




//************************************************************************//
//************************************************************************//
//************************************************************************//

    function returnSellListlength () public returns (uint256 _result){
        _result = SellList[0].Price;
        return _result;
    }    
    function returnBuyListlength () public returns (uint256 _result){
        _result = BuyList[0].Price;
        return _result;
    }  

//************************************************************************//
//************************************************************************//
//************************************************************************//

    
}   
    
    
    
    
    
    
    
    
    
    
    
    
    