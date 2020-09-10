
pragma solidity 0.5.12;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./PQ1_Heap_Dynamic_Array.sol";
import "./PQ2_Heap_Static_Array.sol";
import "./PQ3_Heap_Mapping.sol";
import "./PQ4_Linkedlist.sol";
import "./PQ5_Linkedlist_Mapping.sol";

contract Call_Market{


    PQ1_Heap_Dynamic_Array public PQ = new PQ1_Heap_Dynamic_Array();
    //PQ2_Heap_Static_Array public PQ = new PQ2_Heap_Static_Array(84);
    //PQ3_Heap_Mapping public PQ = new PQ3_Heap_Mapping();
    //we pass the address of the callmarket to the linkedlist so that the selfdestruct could send Ethers back to the callmarket
    //PQ4_Linkedlist public PQ = new PQ4_Linkedlist(address(this));
    //PQ5_Linkedlist_Mapping public PQ = new PQ5_Linkedlist_Mapping(); 
    //Mapping public MP = new Mapping(address(this));
    address payable public callmarket = address(uint160(address(this)));
    
//***********************************************************************//

    /**
    *   @dev Converts string to uint and returns the uint
    */

    function str2uint (string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint i;
        uint result = 0;
        uint j = b.length;
        for (i = 0; i < j; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }

        return result;
    }
//***********************************************************************//

    /**
    *   @dev Converts uint to string and returns the string
    */

    function uint2str (uint _i) internal pure returns (string memory _uintAsString) {
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
//***********************************************************************//
    
    /**
    *   @dev Contcatenates two string and returns the result
    */

    function contcat(string memory a, string memory b) internal pure returns (string memory) {

        return string (abi.encodePacked( a , b));
    }

//****************************************************//
//****************************************************//
//****************************************************//

    /**
    *   @dev
        States.Open: The market is open
        States.Closed: The market is closed but the orders have not yet been processed
        States.Settled: The market is closed and settled (orders have been processed)
        CreationTime: The openning time of the market
        biddingPeriod: The window of time during which the market is open
        NumOrders: Total orders in the market (both bids and asks)
        BuyListCounter: A bid orders counter that is decremented every time a bid is submitted (used for handling ties)
        SellListCounter: An ask orders counter that is incremented every time an ask is submitted (used for handling ties)
        refunds: Maintains the refund counters to be transferred to the block.coinbase (current block miner)

        TotalTokenBalance: Maintains the total token balance of each trader 
        UnavailableTokenBalance: Maintains the number of tokens a trader has depositted
        UnavailableTokenArray: Maintains a list of UnavailableTokenBalance addresses, this list will be used to delete the UnavailableTokenBalance mapping

        TotalEtherBalance: Maintains the total ETH balance of each trader 
        UnavailableEtherBalance: Maintains the number of ETH a trader has depositted
        UnavailableEtherArray: Maintains a list of UnavailableEtherBalance addresses, this list will be used to delete the UnavailableEtherBalance mapping
    */

    //uint256 public countervariable;
    enum States {Open, Closed, Settled} 
    States internal state;
    uint256 public CreationTime;
    uint256 public biddingPeriod;
    uint256 public NumOrders;        
    uint256 public BuyListCounter;   
    uint256 public SellListCounter;  
    mapping(address => uint256) internal refunds;

    mapping(address => uint256) public TotalTokenBalance;
    mapping(address => uint256) public UnavailableTokenBalance;
    address[] public UnavailableTokenArray;

    mapping(address => uint256) public TotalEtherBalance;
    mapping(address => uint256) public UnavailableEtherBalance;
    address[] public UnavailableEtherArray;

//**********************************************//
//***************Function Modifiers*************//
//**********************************************//

    /* modifier CheckAuctionStage () {
        if (now >= CreationTime + biddingPeriod || NumOrders == 1000) 
        {
            CloseMarket();
        }
        _;
    } */

    
//**********************************************// 
    /**
    *   @dev Checks whether the market is at state_1 or not 
    */

    modifier AuctionAtStage (States state_1 ) { 
        require (state == state_1); 
        _;
    }
//***********************************************************************//
    /**
    *   @dev Allows the traders to deposit ERC20 tokens
        Traders must firs call the approve() from the ERC20 token contract to allow the call market contract to spend those tokens
    */

    function DepositToken(address _token, uint256 _numofTokens) public returns (bool) {
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), _numofTokens));
        TotalTokenBalance[msg.sender] += _numofTokens;
        
        return true;
    
    }
//***********************************************************************//
    /**
    *   @dev Allows the traders to deposit ETH
    */ 

    function DepositEther(uint256 _numofEthers) public payable returns (bool) {
        TotalEtherBalance[msg.sender] += _numofEthers;
        
        return true;
    }
//***********************************************************************//
    /**
    *   @dev Opens the market
    */ 

    function OpenMarket() public returns (bool) {

        CreationTime = now; 
        biddingPeriod = 10 minutes;
        state = States.Open;
        NumOrders = 0;
        SellListCounter = 100;
        BuyListCounter = 999;
        return true;

    }
//***********************************************************************//
    /**
    *   @dev 
        Allows traders to submit bid orders if the market is at the open state
        Traders must have enough ETH already depositted
        To handle ties: Converts the bid price to string, contactenate it with the BuyListCounter and converts the constactenated string to uint
        Calls the PQ InsertBid function
        Increment the market's total number of orders 
        Decrements the BuyListCounter
        Increase the UnavailableEtherBalance of the trader by _volume * _price;
    */ 
  
    function submitBid (uint256 _price, uint256 _volume) public AuctionAtStage (States.Open) returns (bool)
    {
        require ((TotalEtherBalance[msg.sender] - UnavailableEtherBalance[msg.sender]) >= _volume * _price );
        
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (BuyListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
        if (PQ.InsertBid(msg.sender, _price, _volume, _finalpriceUint))
        {
            NumOrders++;
            BuyListCounter--;
            UnavailableEtherBalance[msg.sender] += _volume * _price;
            //UnavailableEtherArray.push(msg.sender);
        }
        return true;
    }

//***********************************************************************//
    /**
    *   @dev 
        Allows traders to submit ask orders if the market is at the open state
        Traders must have enough tokens already depositted
        To handle ties: Converts the ask price to string, contactenate it with the SellListCounter and converts the constactenated string to uint
        Calls the PQ InsertAsk function
        Increments the market's total number of orders 
        Increments the SellListCounter
        Increase the UnavailableTokenBalance of the trader by _volume
    */ 

    function submitAsk (uint256 _price, uint256 _volume) public AuctionAtStage (States.Open) returns (bool)
    {
        require((TotalTokenBalance[msg.sender] - UnavailableTokenBalance[msg.sender]) >= _volume);
        uint256 _finalpriceUint;
        string memory _finalpriceString;
        _finalpriceString = contcat ( uint2str(_price), uint2str (SellListCounter));
        _finalpriceUint = str2uint (_finalpriceString);
        
    
        if (PQ.InsertAsk(msg.sender, _price, _volume,_finalpriceUint))
        {   
            NumOrders++;
            SellListCounter++;
            UnavailableTokenBalance[msg.sender] += _volume;
            //UnavailableTokenArray.push(msg.sender);
        }
    return true;

    }
//***********************************************************************//
    /**
    *   @dev Closes the market
    */ 

    function CloseMarket() public returns (bool)
    {
        state = States.Closed;
        return true;
    }

//***********************************************************************//
    /**
    *   @dev 
        Processes the orders only if the market is at the closed state

    */

    function MatchOrders() public AuctionAtStage(States.Closed) returns (bool){
       
        (uint256 BBPrice, address BBSender) = PQ.BuyListMaxDelete();
        (uint256 BAPrice, address BASender) = PQ.SellListMaxDelete();
        
        while (BBPrice >= BAPrice)
        
        {  
            TotalTokenBalance[BBSender] += 1;
            TotalEtherBalance[BASender] += BAPrice;

            //refunds[block.coinbase] += BBPrice - BAPrice;
         
            if (PQ.BuyListisEmpty() || PQ.SellListisEmpty()) 
            {
                break;
            }

            (BBPrice,BBSender) = PQ.BuyListMaxDelete();
            (BAPrice,BASender) = PQ.SellListMaxDelete();
        }
        
        //uint refund = refunds[block.coinbase]; 
        //refunds[block.coinbase] = 0; 
        //block.coinbase.transfer(refund);
        
        // for (uint i =0 ; i< UnavailableTokenArray.length; i++) 
        // {   
        //     delete UnavailableTokenBalance[UnavailableTokenArray[i]];
        // }
        
        // for (uint j=0 ; j< UnavailableEtherArray.length; j++) 
        // {   
        //     delete UnavailableEtherBalance[UnavailableEtherArray[j]];
        // }
             
        
        state = States.Settled;
        return true;

        
    }    
//***********************************************************************//
    /**
    *   @dev Allows the tarders to claim their available tokens back
    */    
    function claimTokens (address _token, uint256 _numofTokens ) public returns (bool)
    {
        require ((TotalTokenBalance[msg.sender] - UnavailableTokenBalance[msg.sender]) > _numofTokens);
        uint256 tokensToBeClaimed = _numofTokens ;
        TotalTokenBalance[msg.sender] -= tokensToBeClaimed;
        IERC20(_token).transfer(msg.sender, tokensToBeClaimed);
        return true;
    }
//***********************************************************************//
    /**
    *   @dev Allows the tarders to claim their available ETH back
    */     
    function claimEther (uint256 _numofEthers) public returns (bool)
    {
        require ((TotalEtherBalance[msg.sender] - UnavailableEtherBalance[msg.sender]) > _numofEthers);
        uint256 EthersToBeClaimed = _numofEthers ;
        TotalEtherBalance[msg.sender] -= EthersToBeClaimed;
        msg.sender.transfer(EthersToBeClaimed);
        return true;
    }    
    
                                                                                                                                                                                   
}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
