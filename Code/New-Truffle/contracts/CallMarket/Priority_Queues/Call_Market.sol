pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./PQ1_Heap_Dynamic_Array.sol";
import "./PQ2_Heap_Static_Array.sol";
import "./PQ3_Heap_Mapping.sol";
import "./PQ4_Linkedlist.sol";
import "./PQ5_Linkedlist_Mapping.sol";
//import "./Mapping.sol";
contract Call_Market{

    //PQ1_Heap_Dynamic_Array public PQ = new PQ1_Heap_Dynamic_Array();
    //PQ2_Heap_Static_Array public PQ = new PQ2_Heap_Static_Array(100);
    //PQ3_Heap_Mapping public PQ = new PQ3_Heap_Mapping();
    //PQ4_Linkedlist public PQ = new PQ4_Linkedlist();
    PQ5_Linkedlist_Mapping public PQ = new PQ5_Linkedlist_Mapping();
    //Mapping public MP = new Mapping(address(this));

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
    uint256 public countervariable;
    enum States {Opened, Closed, Settled} 
    States state;
    uint256 public CreationTime;
    uint256 public biddingPeriod;
    uint256 public NumOrders;        //Number of all the orders within the auction
    uint256 public BuyListCounter;   //the counter for BuyList which sorts the orders decrementallyincrementally
    uint256 public SellListCounter;  //the counter for SellList which sorts the orders incrementally
    uint public ethbalancecounter;
    uint public tokenbalancecounter;
    mapping(address => uint256) internal refunds;

//**********************************************//
//*********Escrow Variables and Functions*******//
//**********************************************//
    mapping(address => uint256) public TotalTokenBalance;
    mapping(address => uint256) public UnavailableTokenBalance;
    address[] public UnavailableTokenArray;
    mapping(address => uint256) public TotalEtherBalance;
    mapping(address => uint256) public UnavailableEtherBalance;
    address[] public UnavailableEtherArray;

//**********************************************//
//***************Function Modifiers*************//
//**********************************************//
    //Checks if the auction should be closed or not.
    modifier CheckAuctionStage () {
        if (now >= CreationTime + biddingPeriod || NumOrders == 1000) 
        {
            CloseMarket();
        }
        _;
    }
//**********************************************// 
    //Checks wether the auction is at state_1 or not 
    modifier AuctionAtStage (States state_1 ) { 
        require (state == state_1); 
        _;
    }
//**************DepositToken() Function*********************//   
    //The token holder must first approve the amount to the exchange contract by calling the approve() from the ERC20 token contract
    function DepositToken(address _token, uint256 _numofTokens) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _numofTokens));
        TotalTokenBalance[msg.sender] += _numofTokens;
        
        return true;
    
    }
//**************DepositEther() Function*********************//    
    function DepositEther(uint256 _numofEthers) public payable returns (bool) {
        TotalEtherBalance[msg.sender] += _numofEthers;
        
        return true;
    }
//******************** OpenMarket function ********************//
    //To open a market(auction) on an specific token, user has to call OpenMarket() function and pass the address of ERC20 token to it
    function OpenMarket() public  returns (bool) {

        CreationTime = now; 
        biddingPeriod = 10 minutes;
        state = States.Opened;
        NumOrders = 0;
        SellListCounter = 100;
        BuyListCounter = 999;
        return true;

    }
//******************** submitBid() function ********************//
    //submitBid function calls the maxheap_insert function    
    //The Bidder must first deposit enough Ether in the exachange (DepositEther())
    function submitBid (uint256 _price, uint256 _volume) public AuctionAtStage (States.Opened) returns (bool)
    {
        require ((TotalEtherBalance[msg.sender] - UnavailableEtherBalance[msg.sender]) >= _volume * _price );
        //require ((TotalEtherBalance[msg.sender] - MP.readEther(msg.sender)) >= _volume * _price );
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        
        if (PQ.InsertBid(msg.sender, _price, _volume, _finalpriceUint))
        {
            NumOrders++;
            BuyListCounter--;
            UnavailableEtherBalance[msg.sender] += _volume * _price;
            //MP.addEther(msg.sender, _price, _volume);
            //UnavailableEtherArray.push(msg.sender);
        }
        return true;
    }
//******************** submitask() function ********************//
    //submitAsk function calls the minheap_insert function
    //The Bidder must first deposit enough Token in the exachange (DepositToken())
    function submitAsk (uint256 _price, uint256 _volume ) public AuctionAtStage (States.Opened) returns (bool)
    {
        require((TotalTokenBalance[msg.sender] - UnavailableTokenBalance[msg.sender]) >= _volume);
        //require((TotalTokenBalance[msg.sender] - MP.readToken(msg.sender)) >= _volume);
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (SellListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
    
        if (PQ.InsertAsk(msg.sender, _price, _volume,_finalpriceUint))
        {   
            NumOrders++;
            SellListCounter++;
            UnavailableTokenBalance[msg.sender] += _volume;
            //MP.addToken(msg.sender, _volume);
            //UnavailableTokenArray.push(msg.sender);
        }
    return true;

    }
//******************** CloseMarket() function ********************//
    function CloseMarket() public returns (bool)
    {
        state = States.Closed;
        return true;
    }

//******************** MatchOrders() function ********************//
    function MatchOrders() public AuctionAtStage(States.Closed) returns (bool){
       
        (uint256 BBPrice, address BBSender) = PQ.BuyListMaxDelete();
        (uint256 BAPrice, address BASender) = PQ.SellListMaxDelete();
        while (BBPrice >= BAPrice)
        
        {  
            countervariable++;
            TotalTokenBalance[BBSender] += 1;
            TotalEtherBalance[BASender] += BAPrice;
         
            if (PQ.BuyListisEmpty() || PQ.SellListisEmpty()) {break;}

            (BBPrice,BBSender) = PQ.BuyListMaxDelete();
            (BAPrice,BASender) = PQ.SellListMaxDelete();
        }
        
        //uint refund = refunds[block.coinbase]; 
        //refunds[block.coinbase] = 0; 
        //block.coinbase.transfer(refund);
        //refunds[block.coinbase] += PQ.BuyListMaxPrice() - PQ.SellListMaxPrice();
        // for (uint i =0 ; i< UnavailableTokenArray.length; i++) 
        // {   
        //     delete UnavailableTokenBalance[UnavailableTokenArray[i]];
        // }
        
        // for (uint j=0 ; j< UnavailableEtherArray.length; j++) 
        // {   
        //     delete UnavailableEtherBalance[UnavailableEtherArray[j]];
        // }
             
        //  while (PQ.BuyListMaxPrice() >= PQ.SellListMaxPrice())
        // {   
        //     countervariable++;
            
        //     TotalTokenBalance[PQ.BuyListMaxSender()] += 1;
        //     TotalEtherBalance[PQ.SellListMaxSender()] += PQ.SellListMaxPrice();
        //     //refunds[block.coinbase] += PQ.BuyListMaxPrice() - PQ.SellListMaxPrice();
    
        //     PQ.SellListMaxDelete();
        //     PQ.BuyListMaxDelete();
            
        //     if (PQ.BuyListisEmpty() == true || PQ.SellListisEmpty() == true) {break;}
            

        // }    
        
        state = States.Settled;
        return true;

        
    }    
//******************** claimTokens() & claimEther() ********************//
    //traders can claim their tokens or ethers uisng the following two functions
    function claimTokens (address _token, uint256 _numofTokens ) public returns (bool)
    {
        require ((TotalTokenBalance[msg.sender] - UnavailableTokenBalance[msg.sender]) > _numofTokens);
        uint256 tokensToBeClaimed = _numofTokens ;
        TotalTokenBalance[msg.sender] -= tokensToBeClaimed;
        IERC20(_token).transfer(msg.sender, tokensToBeClaimed);
        return true;
    }
//******************************************************//      
    function claimEther (uint256 _numofEthers) public returns (bool)
    {
        require ((TotalEtherBalance[msg.sender] - UnavailableEtherBalance[msg.sender]) > _numofEthers);
        uint256 EthersToBeClaimed = _numofEthers ;
        TotalEtherBalance[msg.sender] -= EthersToBeClaimed;
        msg.sender.transfer(EthersToBeClaimed);
        return true;
    }    
    
                                                                                                                                                                                   
}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
