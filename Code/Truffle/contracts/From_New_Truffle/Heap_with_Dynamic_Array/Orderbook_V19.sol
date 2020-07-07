pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

//import "http://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

//call martket, collateralized
contract Orderbook_V19{


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

//**************** OrderStruct ***************************//
//Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        uint256 AuxPrice; //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
        uint256 Volume; //The volume is 1 for now
        
    }
//**************** AuctionStruct ***************************//
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
        address Token;          //The token that is being traded in the auction
    }    
    
 //**********************************************//   
    enum States {UnInitiallized, Opened, Closed} 
    //Opened: biddingTime, Settlement has not yet started.
    //Locked: biddingTime’s over, Settlement’s satrted and not finished yet.
    //Ended: biddingTime and Settlement are both over , which means the auction is ended. 
    uint256 public numAuctions;
    mapping (uint256 => AuctionStruct) public Auctions;
    uint public biddingTime = 5 minutes;

    event LogBuyList (address _sender, uint256 _price, uint256 _volume);
    event TransferToken (address _from, address _to, uint256 _numofTokens);
    event TransferEther (address _from, address _to, uint256 _numofEther);
    event TradeHappens (uint256 _BuyPrice, uint256 _SellPrice);

//**********************************************//
//***************Function Modifiers*************//
//**********************************************//
 
    //Checks if the auction should be closed or not.
    modifier CheckAuctionStage (uint256 _AuctionID) {
        if (Auctions[_AuctionID].isValue == false) {Auctions[_AuctionID].state = States.UnInitiallized;}
        if (now >= Auctions[_AuctionID].CreationTime + biddingTime || Auctions[_AuctionID].NumOrders == 1000) 
        {
            Auctions[_AuctionID].state = States.Closed;
            CloseMarket(_AuctionID);
            
        }
        _;
    }

//**********************************************// 
    //Checks wether the auction is at state_1 or not (Check this again! Seems to be the same thing with the one above)
    modifier AuctionAtStage (uint256 _AuctionID , States state_1 ) { 
        require (Auctions[_AuctionID].state == state_1); 
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
    //mapping(address => mapping(address => uint256)) public escrowExpiration;
    
    //User (Biders) => balance(Ether)
    mapping(address => uint256) public EtherBalance;

//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _numofTokens) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _numofTokens));
        TokenBalance[msg.sender][_token] += _numofTokens;
        return true;
    
    }
//**************DepositEther() Function*********************//    
    
    function DepositEther() public payable returns (bool) {
        EtherBalance[msg.sender] += msg.value;
        return true;
        
    }

//******************** OpenMarket function ********************//
    //To open a market(auction) on an specific token, user has to call OpenMarket() function and pass the address of ERC20 token to it
    function OpenMarket(address _token) public returns (uint256 _AuctionID){
    

        _AuctionID = numAuctions++;
        
        Auctions[_AuctionID].CreationTime = now; 
        Auctions[_AuctionID].NumOrders = 0;
        Auctions[_AuctionID].state = States.Opened;
        Auctions[_AuctionID].isValue = true;
        Auctions[_AuctionID].BuyListCounter = 999;
        Auctions[_AuctionID].SellListCounter = 0;
        Auctions[_AuctionID].Token = _token;
        
        return _AuctionID;

    }
//******************** CloseMarket() function ********************//
    
    function CloseMarket(uint256 _AuctionID) public returns (bool){
        //MatchOrders(_AuctionID);
        Auctions[_AuctionID].state = States.Closed;
        return true;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    }

//******************** MatchOrders() function ********************//
    function MatchOrders(uint256 _AuctionID) public AuctionAtStage (_AuctionID, States.Closed) returns (bool){
  
        uint256 refund;
        
           
        while ( Auctions[_AuctionID].BuyList.length != 0 && Auctions[_AuctionID].SellList.length != 0 && BuyListPeak(_AuctionID).Price >= SellListPeak(_AuctionID).Price)
        {
            
            
            
            emit TradeHappens (BuyListPeak(_AuctionID).Price, SellListPeak(_AuctionID).Price);
            OrderStruct memory temp_BestBid = BuyListPeak(_AuctionID);
            OrderStruct memory temp_BestAsk = SellListPeak(_AuctionID);
            transferToken (temp_BestAsk.Sender, temp_BestBid.Sender, Auctions[_AuctionID].Token, temp_BestBid.Volume);
            transferEther (temp_BestBid.Sender,temp_BestAsk.Sender, Auctions[_AuctionID].Token, temp_BestAsk.Price );
            
            
            
            //Pays the difference to the miner
            /*if (temp_BestBid.Price - temp_BestAsk.Price != 0) 
            {
                EtherBalance[block.coinbase] += temp_BestBid.Price - temp_BestAsk.Price;
                refund = EtherBalance[block.coinbase]; 
                EtherBalance[block.coinbase] = 0; 
                block.coinbase.transfer(refund);
            }*/
             
        
            BuyListDelete(_AuctionID);
            SellListDelete(_AuctionID);
            
        }
        
        if (Auctions[_AuctionID].BuyList.length != 0)
        {
            Rrefund_unexecuted_Buy_orders(_AuctionID);
        }
        
        if (Auctions[_AuctionID].SellList.length != 0)
        {
           Rrefund_unexecuted_Sell_orders(_AuctionID); 
        }
        
        return true;

        
    }
    
    //******************** Rrefund_unexecuted_Buy_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "Ethers" for those trades that did not happen
    function Rrefund_unexecuted_Buy_orders (uint256 _AuctionID) internal returns (bool) {

        
        uint i;
        while (Auctions[_AuctionID].BuyList.length != 0)
        {
            i = Auctions[_AuctionID].BuyList.length - 1;
            EtherBalance[Auctions[_AuctionID].BuyList[i].Sender] += Auctions[_AuctionID].BuyList[i].Volume * Auctions[_AuctionID].BuyList[i].Price;
            Auctions[_AuctionID].BuyList.pop();
            
            
        }
        
        return true;
    }
    
    //******************** Rrefund_unexecuted_Sell_orders function ********************//
    //After trades happened in the MatchOrders() function, following function will be called to refund the deposited "tokens" for those trades that did not happen
    function Rrefund_unexecuted_Sell_orders (uint256 _AuctionID) internal returns (bool) {
        
        
        
        uint i;
        while (Auctions[_AuctionID].SellList.length != 0)
        {
            i = Auctions[_AuctionID].SellList.length - 1;
            TokenBalance[Auctions[_AuctionID].SellList[i].Sender][Auctions[_AuctionID].Token] += Auctions[_AuctionID].SellList[i].Volume;
            Auctions[_AuctionID].SellList.pop();
           
            
        }
        
        return true;
    }
  
//******************** transferToken() & transferEther() internal ********************//    
    //These two functions are fired During the order matching 
    function transferToken( address _fromSeller, address _toBuyer, address _token, uint256 _numofTokens) internal
    {
        require(TokenBalance[_fromSeller][_token] >= _numofTokens,  "Insufficient Token balance.");

        //TokenBalance[_fromSeller][_token] -= _numofTokens;
        TokenBalance[_toBuyer][_token] += _numofTokens;
        emit TransferToken (_fromSeller, _toBuyer, _numofTokens);
    }
//******************************************************//    
    function transferEther( address _fromBuyer, address _toSeller, address _token, uint256 _numofEthers) internal
    {
        require(EtherBalance[_fromBuyer] >= _numofEthers,  "Insufficient Ether balance.");

        //EtherBalance[_fromBuyer] -= _numofEthers;
        EtherBalance[_toSeller] += _numofEthers;
        emit TransferEther (_fromBuyer, _toSeller, _numofEthers);
    } 
//******************************************************// 


//******************** claimTokens() & claimEther() ********************//
    //traders can claim their tokens or ethers uisng the following two functions

    function claimTokens (address _token) public returns (bool)
    {
        require (TokenBalance[msg.sender][_token] > 0);
        uint tokensToBeClaimed = TokenBalance[msg.sender][_token] ;
        TokenBalance[msg.sender][_token] = 0;
        IERC20(_token).transfer(msg.sender, tokensToBeClaimed);
        return true;
    }
//******************************************************//      
    function claimEther () public returns (bool)
    {
        require (EtherBalance[msg.sender] > 0);
        uint EthersToBeClaimed = EtherBalance[msg.sender] ;
        EtherBalance[msg.sender]  = 0;
        msg.sender.transfer(EthersToBeClaimed);
        return true;
    }    

    
//******************** submitBid() function ********************//
    //submitBid function calls the maxheap_insert function    
    //The Bidder must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint256 _AuctionID, uint256 _price, uint256 _volume) public 
    CheckAuctionStage (_AuctionID) 
    AuctionAtStage (_AuctionID, States.Opened)
    returns (bool)
    {
        
        
        require (EtherBalance[msg.sender] >= _volume * _price );
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (Auctions[_AuctionID].BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        
        if(maxheap_insert(_AuctionID , msg.sender, _price, _finalpriceUint, _volume)){
            Auctions[_AuctionID].BuyListCounter--;
            Auctions[_AuctionID].NumOrders++;
            EtherBalance[msg.sender] -= _volume * _price;
            
        }
        
    
        return true;
    }

//******************** submitask() function ********************//
    //submitAsk function calls the minheap_insert function
    //The Bidder must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint256 _AuctionID, uint256 _price, uint256 _volume ) public 
    CheckAuctionStage (_AuctionID) 
    AuctionAtStage (_AuctionID, States.Opened)
    returns (bool)
    {
        require( TokenBalance[msg.sender][Auctions[_AuctionID].Token] >= _volume);
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (Auctions[_AuctionID].SellListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        if (minheap_insert( _AuctionID, msg.sender, _price, _finalpriceUint, _volume))
        {
                Auctions[_AuctionID].SellListCounter++;
                Auctions[_AuctionID].NumOrders++;
                TokenBalance[msg.sender][Auctions[_AuctionID].Token] -= _volume;
        }
        
        return true;

    }


//*****************************************************************//
//*******************  maxheap Functions (BuyList) ****************//
//*****************************************************************//


//*******************  maxheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function maxheap_insert (uint256 _AuctionID, address _sender, uint256 _price, uint256 _auxPrice, uint256 _volume) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool)
    {
        
        OrderStruct memory neworder = OrderStruct(_sender, _price , _auxPrice, _volume);
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
//*******************  maxheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function maxheap_heapifyDown (uint256 _AuctionID) internal {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < Auctions[_AuctionID].BuyList.length)
        {                                   //as long as the left child is within the array that heap is stored in
            uint max = leftchild;
            uint rightchild = leftchild + 1;                                     //rightchild = 2k+2

            if (rightchild < Auctions[_AuctionID].BuyList.length)                                       //if there is a rightchild
            {
                if (Auctions[_AuctionID].BuyList[rightchild].Price > Auctions[_AuctionID].BuyList[leftchild].Price)    //then the right child and left child are compared
                {
                    max++;                                                       //now max is set to rightchild, otherwise max remains to be the leftchild
                }
            }

        if (Auctions[_AuctionID].BuyList[k].Price < Auctions[_AuctionID].BuyList[max].Price)                        //compares the k item with the max item and if k is smaller than its greatest children they are swapped
        {
            //swap k with its greatest children (max)
            //"!SYNTAX!"
            //Orderbook_V9.swap (SellList, k, max);
            OrderStruct memory temp = Auctions[_AuctionID].BuyList[k];    //"!SYNTAX!"//swap the element at index k with its parent
            Auctions[_AuctionID].BuyList[k] = Auctions[_AuctionID].BuyList[max];
            Auctions[_AuctionID].BuyList[max] = temp;
            k = max;                                                         //k is set to max
            leftchild =2*k + 1;                                              //l is recompuetd in preparation for the next iteration
        }
        else{                                                               //if the k item is not smaller than the max item, heapifyDown should stop
            break;
            }
        }
    }
    
//****************   BuyListpeak()  *********************//
    //BuyListpeak function returns the highest priority element (The highest bid)
    function BuyListPeak(uint256 _AuctionID) public view returns (OrderStruct memory){

        require(Auctions[_AuctionID].BuyList.length != 0); //throws exception if the maxheap (BuyList) is empty
        return (Auctions[_AuctionID].BuyList[0]);
    }
    
    //Function Overloading: When BuyListpeak() is called from inside of the MatchingOrder(), it recieves just an array (and not an AuctionID) as paramater  
    function BuyListPeak(OrderStruct[] memory _array) internal view returns (OrderStruct memory){

        require(_array.length != 0); //throws exception if the list is empty
        return (_array[0]);
    }
    
//*******************  maxheap_delete () ***************************//
    //the highest priority item will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function BuyListDelete (uint256 _AuctionID) public returns (OrderStruct memory) 
    {
        if (Auctions[_AuctionID].BuyList.length == 0) { revert(); }                             //the delete function throws exception if the heap is empty
        if (Auctions[_AuctionID].BuyList.length == 1) {                                      //if the heap has only one items
                     
            OrderStruct memory result =  Auctions[_AuctionID].BuyList[0];
            
            Auctions[_AuctionID].BuyList.pop();                                                 //the only element of the heap is removed and returned 
            Auctions[_AuctionID].NumOrders --;
            return result;     
       
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
        OrderStruct memory result =  Auctions[_AuctionID].BuyList[0];
        Auctions[_AuctionID].BuyList[0] = Auctions[_AuctionID].BuyList[Auctions[_AuctionID].BuyList.length -1]; //the last elementof the heap is removed and written into the first position
        Auctions[_AuctionID].BuyList.pop();
        //Auctions[_AuctionID].BuyList.length--;
        maxheap_heapifyDown(_AuctionID); //now the siftdown is called
        Auctions[_AuctionID].NumOrders --;
        return result;
    }
    

//*****************************************************************//
//*******************  minheap Functions (SellList) ****************//
//*****************************************************************//

//*******************  minheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function minheap_insert (uint256 _AuctionID, address _sender, uint256 _price, uint256 _auxPrice, uint256 _volume) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _price , _auxPrice, _volume); 
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
//*******************  minheap_heapifyDown () ***************************//
    //when we want to remove an element from the heap we remove the root of the heap and add the last item
    //to the root and reorder the heap again
    function minheap_heapifyDown (uint256 _AuctionID) internal returns (bool) {
        uint256 k =0;
        uint256 leftchild = 2*k + 1;
        while (leftchild < Auctions[_AuctionID].SellList.length){               //as long as the left child is within the array that heap is stored in
            uint256 min = leftchild;
            uint256 rightchild = leftchild + 1;              //rightchild = 2k+2

            if (rightchild < Auctions[_AuctionID].SellList.length)                //if there is a rightchild, then the right child and left child are compared
            {
                if (Auctions[_AuctionID].SellList[rightchild].Price < Auctions[_AuctionID].SellList[leftchild].Price)
                {    min++;   }                               //now min is set to rightchild, otherwise min remains to be the leftchild
            }

            if (Auctions[_AuctionID].SellList[min].Price < Auctions[_AuctionID].SellList[k].Price) //compares the k item with the max item and if its less they are swapped
            {
                //swap (BuyList, k, min); //swap k with its smaller children
                
                OrderStruct memory temp = Auctions[_AuctionID].SellList[k];    //"!SYNTAX!"//swap the element at index k with its parent
                Auctions[_AuctionID].SellList[k] = Auctions[_AuctionID].SellList[min];
                Auctions[_AuctionID].SellList[min] = temp;

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
    function SellListPeak(uint256 _AuctionID) public view returns (OrderStruct memory){

        require(Auctions[_AuctionID].SellList.length != 0); //throws exception if the minheap (SellList) is empty
        return (Auctions[_AuctionID].SellList[0]);
    }
    //Function Overloading: When SellListpeak() is called from inside of the MatchingOrder(), it recieves just an array (and not an AuctionID) as paramater  
    function SellListPeak(OrderStruct[] memory _array) internal view returns (OrderStruct memory){

        require(_array.length != 0); //throws exception if the list is empty
        return (_array[0]);
    }


//*******************  minheap_delete () ***************************//
    //the highest priority item (the smallest bid) will be removed from the list and is returned by the function
    //then the heap is reordered uising the heapifyDown method
    function SellListDelete (uint256 _AuctionID) public returns (OrderStruct memory)
    //function minheap_delete () public view returns (uint256 _price)
    {
        if (Auctions[_AuctionID].SellList.length == 0) { revert(); }                      //the delete function throws exception if the heap is empty
        if (Auctions[_AuctionID].SellList.length == 1) {                               // if the heap has only one item
            OrderStruct memory result = Auctions[_AuctionID].SellList[0];
            Auctions[_AuctionID].SellList.pop();                                   //the only element of the heap is removed and returned  
            Auctions[_AuctionID].NumOrders --;
            return result;
        }

        //if neither of these conditions are true, then there are at least 2 items in the heap and deletion proceeds
      
        OrderStruct memory result = Auctions[_AuctionID].SellList[0];
        Auctions[_AuctionID].SellList[0] = Auctions[_AuctionID].SellList[Auctions[_AuctionID].SellList.length -1];                      //the last elementof the heap is removed and written into the first position
        Auctions[_AuctionID].SellList.pop(); 
        minheap_heapifyDown(_AuctionID);                           //now the heapifyDown is called to restore the ordering of the heap 
        Auctions[_AuctionID].NumOrders --;
        return result;        
    }

//************************************************************************//
//************************************************************************//
//************************************************************************//



//************************************************************************//
//************************************************************************//
//************************************************************************//

}
