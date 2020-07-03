const CallMarket = artifacts.require('Call_Market.sol');
const DappToken = artifacts.require('DappToken');
var CallMarketaddress;
var tokenaddress;
var accounts;
var maximum = 100;
var minimum = 1;



//Test 2:
//This truffle code tests 5 priority queues in terms of the number of matches the match function can handle.
//Note: this is a "normal/average case" matching where we use random prices for Bids and Asks and obviously not all of them will be executed against each other.
//The deliverables of this code are: (1) The maximum number of orders the match function can match (2) How much gas it uses (which should be close to the limit)

//******************* Deploys the CallMaket and stores its address *************************
contract('CallMarket', function(accounts) {
    it('should store the address of the CallMarket into the var CallMarketaddress', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        CallMarketaddress = CallMarketInstance.address;
        console.log('The address of the CallMarket contract is:', CallMarketInstance.address);
        
    });

});
//******************* Deploys the DappToken and allows CallMarket to spend tokens from it *************************
contract('DappToken', function(accounts) {

    it('should approve transfer of 100 tokens from account[0] to the CallMarket contract ', async ()=> {
        const DappTokenInstance = await DappToken.deployed();
        tokenaddress = DappTokenInstance.address;
        const receipt = await DappTokenInstance.approve (CallMarketaddress, 15000, {from: accounts[0]});
        const result = await DappTokenInstance.allowance(accounts[0],CallMarketaddress);
        console.log('Account[0] allowes the CallMarket contract to spend:',result.toNumber());
        console.log('********************************************');
    
    });   

});

//*******************New test Block for the already deployed CallMarket contract *************************
describe('CallMarket', function(accounts) {
    this.timeout(0);
   
    //*******************Test 1*************************
    it('should deposit tokens from accounst[0] to the CallMarket contract', async() => {
        
        const CallMarketInstance = await CallMarket.deployed(); 

        accounts = await web3.eth.getAccounts();
       
        const receipt = await CallMarketInstance.DepositToken (tokenaddress, 15000, {from: accounts[0]});
        
        const totalbalance = await CallMarketInstance.TotalTokenBalance(accounts[0]);
        
        console.log('The token balance of account[0] is:', totalbalance.toNumber());
        console.log('********************************************');

    });

    //*******************Test 2*************************
    it('should deposit Ethers from accounts[1] to the CallMarket contract', async() => {
        
        const CallMarketInstance = await CallMarket.deployed(); 

        accounts = await web3.eth.getAccounts();
        
        const receipt = await CallMarketInstance.DepositEther (1000000, {from: accounts[1]});

        const totalbalance = await CallMarketInstance.TotalEtherBalance(accounts[1]);
        
        console.log('The Ether balance of accounts[1] is:',totalbalance.toNumber());
        console.log('********************************************');

    });
    //*******************Test 3*************************

    it('should open the market on the Dapp Token', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 

        const receipt = await CallMarketInstance.OpenMarket ();
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for openning the market: ${receipt.receipt.gasUsed}`);
        
    });
    //*******************Test 4*************************
    
    it('should submit asks from accounst[0]', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        var receipt = null;
        var array = [];
        
        accounts = await web3.eth.getAccounts();
        for(let j = 1; j <= 30  ; j++){
            var randomnumber = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
            await CallMarketInstance.submitAsk (randomnumber, 1, {from: accounts[0]});
            array.push(randomnumber);
            console.log('Ask',j,'price is equal to:', randomnumber);
        } 
        console.log(array.length,'asks has been succsessfully submitted');
         
    });
    //*******************Test 5*************************
    it('should submit Bids from accounst[1]', async() => {
        
        const CallMarketInstance = await CallMarket.deployed();  
        var receipt = null;
        var array = [];
        
        accounts = await web3.eth.getAccounts();
        for(let j = 1; j <= 30  ; j++){
            var randomnumber = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
            await CallMarketInstance.submitBid (randomnumber, 1, {from: accounts[1]});
            array.push(randomnumber);
            console.log('Bid',j,'price is equal to:', randomnumber);

        } 
        console.log(array.length,'bids has been succsessfully submitted');
 
    });
    //*******************Test 6*************************
    it('should close the market on the Dapp Token', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        await CallMarketInstance.CloseMarket();
        
    });

    //*******************Test 7*************************
    it('should match the orders', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        const receipt = await CallMarketInstance.MatchOrders();
        console.log('********************************************');
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for worst case matching is: ${receipt.receipt.gasUsed}`);
    
    });
    //*******************Test 8*************************
    it('should print how many matches happened', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        
        const counter = await CallMarketInstance.countervariable();
        console.log('********************************************');
        console.log('Number of matches occured:',counter.toNumber());
        console.log('********************************************');
    

    });


        
});