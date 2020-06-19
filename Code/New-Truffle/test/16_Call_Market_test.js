const CallMarket = artifacts.require('Call_Market.sol');
const PQ = artifacts.require('PQ1_Heap_Dynamic_Array');
const DappToken = artifacts.require('DappToken');
var CallMarketaddress;
//var PQddress;
var tokenaddress;
var accounts;


// contract('PQ', function(accounts) {
//     it('should store the address of the priority queue into the var PQddress', async() => {
//         const PQInstance = await PQ.deployed(); 
//         PQddress = PQInstance.address;
//         console.log('The address of the priority queue contract is:', PQInstance.address);
        
//     });




// });

contract('CallMarket', function(accounts) {
    it('should store the address of the CallMarket into the var CallMarketaddress', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        CallMarketaddress = CallMarketInstance.address;
        console.log('The address of the CallMarket contract is:', CallMarketInstance.address);
        
    });




});

contract('DappToken', function(accounts) {

    it('should approve transfer of 100 tokens from account[0] to the CallMarket contract ', async ()=> {
        const DappTokenInstance = await DappToken.deployed();
        tokenaddress = DappTokenInstance.address;
        const receipt = await DappTokenInstance.approve (CallMarketaddress, 15000, {from: accounts[0]});
        const result = await DappTokenInstance.allowance(accounts[0],CallMarketaddress);
        console.log('Account[0] allowes the CallMarket contract to spend:',result.toNumber());
        
        console.log('********************************************');
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for approving: ${receipt.receipt.gasUsed}`);
    
    });   

});


//*******************New test Block for the already deployed CallMarket contract *************************
describe('CallMarket', function(accounts) {
    this.timeout(0);
    
    //*******************Test 1*************************
    it('should deposit 100 tokens from accounst[0] to the CallMarket contract', async() => {
        
        const CallMarketInstance = await CallMarket.deployed(); 

        accounts = await web3.eth.getAccounts();
       
        const receipt = await CallMarketInstance.DepositToken (tokenaddress, 15000, {from: accounts[0]});
        
        const totalbalance = await CallMarketInstance.TotalTokenBalance(accounts[0]);
        
        console.log('The token balance of account[0] is:', totalbalance.toNumber());
        console.log('********************************************');
        //const gasUsed = receipt.receipt.gasUsed;
        //console.log(`GasUsed for depositting 100 tokens: ${receipt.receipt.gasUsed}`);

    });

    //*******************Test 2*************************
    it('should deposit 6000 Ether from accounts[1] to the CallMarket contract', async() => {
        
        const CallMarketInstance = await CallMarket.deployed(); 

        accounts = await web3.eth.getAccounts();
        
        const receipt = await CallMarketInstance.DepositEther (1000000, {from: accounts[1]});

        const totalbalance = await CallMarketInstance.TotalEtherBalance(accounts[1]);
        
        console.log('The Ether balance of accounts[1] is:',totalbalance.toNumber());
        console.log('********************************************');
        //const gasUsed = receipt.receipt.gasUsed;
        //console.log(`GasUsed for depositting 6000 Ethers: ${receipt.receipt.gasUsed}`);
        
    });
    //*******************Test 4*************************
    
    it('should submit 1 asks from accounst[0]', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
            var receipt = null;
            var array = [];
        

            accounts = await web3.eth.getAccounts();
            for(let j = 40; j >= 1  ; j--){
                receipt = await CallMarketInstance.submitAsk (j, 1, {from: accounts[0]});
        
                //const gasUsed = receipt.receipt.gasUsed;
                //array.push(gasUsed);
                //console.log(`GasUsed for a submitAsk tx is: ${receipt.receipt.gasUsed}`);

            } 
            //console.log(array.length,'asks has been succsessfully submitted');
            //console.log('Gas used for submitting the', array.length,'th ask is:');
            //console.log(`${receipt.receipt.gasUsed}`);
        
   });

   
    //*******************Test 6*************************
    it('should submit 1 Bids from accounst[1]', async() => {
        
        const CallMarketInstance = await CallMarket.deployed();  
        var receipt = null;
        var array = [];
        

        accounts = await web3.eth.getAccounts();
        for(let j = 1; j <= 40  ; j++){
            receipt = await CallMarketInstance.submitBid (j, 1, {from: accounts[1]});
        
            //const gasUsed = receipt.receipt.gasUsed;
            //array.push(gasUsed);
            //console.log(`GasUsed for a submibid tx is: ${receipt.receipt.gasUsed}`);

        } 
        //console.log(array.length,'bids has been succsessfully submitted');
        //console.log('Gas used for submitting the', array.length,'th bid is:');
        //console.log(`${receipt.receipt.gasUsed}`);
 
    });

    //*******************Test 8*************************
    it('should match the orders', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        
        const receipt = await CallMarketInstance.MatchOrders();
        console.log('********************************************');
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for Matching: ${receipt.receipt.gasUsed}`);
    
    });

    it('should show the countervariable', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        
        const counter = await CallMarketInstance.countervariable();
        console.log('********************************************');
        console.log('the countervariable is',counter.toNumber());
        console.log('********************************************');
        //const test = await CallMarketInstance.test();
        //console.log('********************************************');
        //console.log('the test is',test.toNumber());
        console.log('********************************************');
        
        });


        
});