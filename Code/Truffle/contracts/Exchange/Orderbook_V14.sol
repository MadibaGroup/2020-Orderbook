pragma solidity >=0.4.22 ^0.6.0;
pragma experimental ABIEncoderV2;

import "http://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


//call martket (2nd version), collateralized
contract Orderbook_V14{

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
    
    function contcat(string memory a, string memory b) internal pure returns (string memory) {

        return string (abi.encodePacked( a , b));


    }
    
    function bytes32ToString(bytes32 x) internal pure returns (string memory) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (uint j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
}

//*********************************************************************************//

//**********************************************//
//Every order has some attributes:
    struct OrderStruct 
    {
        address Sender;
        uint256 Price;
        uint256 AuxPrice; //This is not the real price of the order, it's the contcantenation of the real price and the counter which helps to sort the heap wehen there are ties
        uint256 Volume; //The volume is 1 for now
        
    }
//**********************************************//
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
    uint256 numAuctions;
    mapping (uint256 => AuctionStruct) public Auctions;
    uint public biddingTime = 5 minutes;

    event LogBuyList (address _sender, uint256 _price, uint256 _volume);
    
    

//**********************************************//
//***************Modifiers*******************//
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
    //Allows a function (submitbid() or submitask()) to get executed if the auction is in a desired state.
    modifier ToPlaceOrderAuctionAtStage (uint256 _AuctionID , States state_1) { 
        require (Auctions[_AuctionID].state == state_1);
        _;
    }
//**********************************************// 
    //Checks wether the auction is at state_1 or not
    modifier AuctionAtStage (uint256 _AuctionID , States state_1 ) { 
        require (Auctions[_AuctionID].state == state_1); 
        _;
    }
//**********************************************// 
    //Checks wether the auction is at state_1 or not
    modifier CheckEscrow (uint256 _AuctionID , States state_1 ) { 
        require (Auctions[_AuctionID].state == state_1); 
        _;
    }


    
//***************Escrow Variables and Functions******************//    
    
    //To make the escrow fully general, the contract does not assume a specific ERC20 token, 
    //so a single account may escrow different tokens at the same time. 
    //For each (account, token) pair, the contract tracks its balance and the time when escrow expires:
    //User (Sellers) => Token => balanace
    mapping(address => mapping(address => uint256)) public TokenBalance;
    //mapping(address => mapping(address => uint256)) public escrowExpiration;
    
    
    //User (Biders) => balance(Ether)
    mapping(address => uint256) EtherBalance;

//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _amount) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount));
        TokenBalance[msg.sender][_token] += _amount;
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
        
        

    }
//******************** CloseMarket function ********************//
    
    function CloseMarket(uint256 _AuctionID) public 
    CheckAuctionStage (_AuctionID)
    returns (bool){

        //MatchOrders(_AuctionID);
        return true;

    }
//******************** MatchOrders function ********************//
    function MatchOrders(uint256 _AuctionID) public 
    AuctionAtStage (_AuctionID, States.Closed)
    returns (bool){
        
        uint256 BestBid;
        uint256 BestAsk;
        uint256 refund;
      
        
        
        
        if (BuyListpeak(_AuctionID).Price >= SellListpeak(_AuctionID).Price)
        {
            BestBid = BuyListpeak(_AuctionID).Price;
            BestAsk = SellListpeak(_AuctionID).Price;
    
            transferToken (SellListpeak(_AuctionID).Sender, BuyListpeak(_AuctionID).Sender, Auctions[_AuctionID].Token, BuyListpeak(_AuctionID).Volume);
            transferEther (BuyListpeak(_AuctionID).Sender,SellListpeak(_AuctionID).Sender, Auctions[_AuctionID].Token, SellListpeak(_AuctionID).Price );

            //Pays the difference to the miner
            require (BestBid - BestAsk != 0);
            EtherBalance[block.coinbase] += BestBid - BestAsk;
            refund = EtherBalance[block.coinbase]; 
            EtherBalance[block.coinbase] = 0; 
            block.coinbase.transfer(refund);
        
            
        }
        
       
        
    }
    
//******************** transferToken() & transferEther() internal ********************//    
    //These two functions are fired During the order matching 
    function transferToken( address _fromSeller, address _toBuyer, address _token, uint256 _numofTokens) internal
    {
        require(TokenBalance[_fromSeller][_token] >= _numofTokens,  "Insufficient balance.");

        TokenBalance[_fromSeller][_token] -= _numofTokens;
        TokenBalance[_toBuyer][_token] += _numofTokens;
    }
//******************************************************//    
    function transferEther( address _fromBuyer, address _toSeller, address _token, uint256 _numofEthers) internal
    {
        require(EtherBalance[_fromBuyer] >= _numofEthers,  "Insufficient balance.");

        EtherBalance[_fromBuyer] -= _numofEthers;
        EtherBalance[_toSeller] += _numofEthers;
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


    
    
    
    
    
    
//******************** submitBid function ********************//
    //submitBid function calls the maxheap_insert function    
    //The Bidder must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint256 _AuctionID, uint256 _numofEthers, uint256 _volume) public 
    CheckAuctionStage (_AuctionID) 
    ToPlaceOrderAuctionAtStage (_AuctionID, States.Opened)
    returns (bool)
    {
        
        
        require (EtherBalance[msg.sender] >= _volume * _numofEthers );
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_numofEthers), uint2str (Auctions[_AuctionID].BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        
        if(maxheap_insert(_AuctionID , msg.sender, _numofEthers, _finalpriceUint, _volume)){
            Auctions[_AuctionID].BuyListCounter--;
            Auctions[_AuctionID].NumOrders++;
            EtherBalance[msg.sender] -= _volume * _numofEthers;
            
        }
        
    
        return true;
    }

//******************** submitask function ********************//
    //submitAsk function calls the minheap_insert function
    //The Bidder must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint256 _AuctionID, uint256 _numofTokens, uint256 _volume ) public 
    CheckAuctionStage (_AuctionID) 
    ToPlaceOrderAuctionAtStage (_AuctionID, States.Opened)
    returns (bool)
    {
        require( TokenBalance[msg.sender][Auctions[_AuctionID].Token] >= _volume);
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_numofTokens), uint2str (Auctions[_AuctionID].SellListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        if (minheap_insert( _AuctionID, msg.sender, _numofTokens, _finalpriceUint, _volume))
        {
                Auctions[_AuctionID].SellListCounter++;
                Auctions[_AuctionID].NumOrders++;
                TokenBalance[msg.sender][Auctions[_AuctionID].Token] -= _volume;
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
    function maxheap_insert (uint256 _AuctionID, address _sender, uint256 _numofEthers, uint256 _auxPrice, uint256 _volume) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool)
    {
        
        OrderStruct memory neworder = OrderStruct(_sender, _numofEthers , _auxPrice, _volume);
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
    
//****************   BuyListpeak()  *********************//
    //BuyListpeak function returns the highest priority element (The highest bid)
    function BuyListpeak(uint256 _AuctionID) public view returns (OrderStruct memory){

        require(Auctions[_AuctionID].BuyList.length != 0); //throws exception if the maxheap (BuyList) is empty
        return (Auctions[_AuctionID].BuyList[0]);
    }

    
    
//*******************  minheap Functions (SellList) ****************//
//*****************************************************************//
//*****************************************************************//
//*****************************************************************//

//*******************  minheap_insert () ***************************//
    //the new item will be added to the end of the array list (a buy order is submitted)
    //then heapified up with a call to heapifyUp method
    function minheap_insert (uint256 _AuctionID, address _sender, uint256 _numofTokens, uint256 _auxPrice, uint256 _volume) internal 
    CheckAuctionStage (_AuctionID)
    returns (bool)
    {
        OrderStruct memory neworder = OrderStruct(_sender, _numofTokens , _auxPrice, _volume); 
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

//****************   SellListpeak()  *********************//
    //SellListpeak function returns the highest priority element (The Lowest ask)
    function SellListpeak(uint256 _AuctionID) public view returns (OrderStruct memory){

        require(Auctions[_AuctionID].SellList.length != 0); //throws exception if the minheap (SellList) is empty
        return (Auctions[_AuctionID].SellList[0]);
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
