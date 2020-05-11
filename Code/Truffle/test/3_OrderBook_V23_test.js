const DappToken = artifacts.require('DappToken');
const Orderbook = artifacts.require('Orderbook_V23');
var Orderbookaddress;
var tokenaddress;
var accounts;


// Obtain gas used from the receipt
//const receipt = await DappTokenInstance.transfer (accounts[1], 1, {from: accounts[0]});
//const gasUsed = receipt.receipt.gasUsed;
//console.log(`GasUsed for transfering: ${receipt.receipt.gasUsed}`);


contract('Orderbook', function(accounts) {
    it('should store the address of the orderbook into the var orderbookaddress', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        Orderbookaddress = OrderbookInstance.address;
        console.log('The address of the orderbook contract is:', OrderbookInstance.address);
        
    });




});




contract('DappToken', function(accounts) {

    it('should approve transfer of 100 tokens from account[0] to the orderbook contract ', async ()=> {
        const DappTokenInstance = await DappToken.deployed();
        tokenaddress = DappTokenInstance.address;
        const receipt = await DappTokenInstance.approve (Orderbookaddress, 100, {from: accounts[0]});
        const result = await DappTokenInstance.allowance(accounts[0],Orderbookaddress);
        console.log('Account[0] allowes the orderbook contract to spend:',result.toNumber());
        
        console.log('********************************************');
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for approving: ${receipt.receipt.gasUsed}`);
    
    });   

});

//*******************New test Block for the already deployed orderbook contract *************************
describe('Orderbook', function(accounts) {
    this.timeout(0);
    
    //*******************Test 1*************************
    it('should deposit 100 tokens from accounst[0] to the orderbook contract', async() => {
        
        const OrderbookInstance = await Orderbook.deployed(); 

        accounts = await web3.eth.getAccounts();
       
        const receipt = await OrderbookInstance.DepositToken (tokenaddress, 100, {from: accounts[0]});
        
        const totalbalance = await OrderbookInstance.TotalTokenBalance(accounts[0], tokenaddress);
        const availablebalance = await OrderbookInstance.AvailableTokenBalance(accounts[0], tokenaddress);
        
        console.log('The total token balance of account[0] is:', totalbalance.toNumber());
        console.log('********************************************');
        console.log('The available token balance of account[0] is:', availablebalance.toNumber());
        console.log('********************************************');
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for depositting 100 tokens: ${receipt.receipt.gasUsed}`);

    });

    //*******************Test 2*************************
    it('should deposit 6000 Ether from accounts[1] to the orderbook contract', async() => {
        
        const OrderbookInstance = await Orderbook.deployed(); 

        accounts = await web3.eth.getAccounts();
        
        const receipt = await OrderbookInstance.DepositEther (6000, {from: accounts[1]});

        const totalbalance = await OrderbookInstance.TotalEtherBalance(accounts[1]);
        const availablebalance = await OrderbookInstance.AvailableEtherBalance(accounts[1]);
        
        console.log('The total Ether balance of accounts[1] is:',totalbalance.toNumber());
        console.log('********************************************');
        console.log('The available Ether balance of accounts[1] is:',availablebalance.toNumber());
        console.log('********************************************');
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for depositting 6000 Ethers: ${receipt.receipt.gasUsed}`);
        
    });
    //*******************Test 3*************************

    it('should open the market on the Dapp Token', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 

        const receipt = await OrderbookInstance.OpenMarket (tokenaddress);
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for openning the market: ${receipt.receipt.gasUsed}`);
        
    });
    //*******************Test 4*************************
    
    it('should submit 2 asks from accounst[0]', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        var receipt = null;
        var array = [];
        

        accounts = await web3.eth.getAccounts();
        for(let j = 1; j <= 1  ; j++){
            receipt = await OrderbookInstance.submitAsk (j, 1, {from: accounts[0]});
        
            const gasUsed = receipt.receipt.gasUsed;
            array.push(gasUsed);
            console.log(`GasUsed for a submitask tx is: ${receipt.receipt.gasUsed}`);

        } 
        
        // Getting sum of numbers
        var sum = array.reduce(function(a, b){
            return a + b;
        }, 0);

        console.log('********************************************');    
        console.log('cost of submitting 100 submitAsk txs is:',sum);   
        console.log(array.length,'ask orders has been succsessfully submitted');
        
   });
    //*******************Test 5*************************
    it('should return the Selllist peak', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        
    
        const result = await OrderbookInstance.SellListPeak.call();
        const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
        console.log('The SellList peak is:', intprice);
    
    });

    //*******************Test 6*************************
    // it('should delete the Selllist peak', async() => {
    //     const OrderbookInstance = await Orderbook.deployed(); 
        
    
    //     //const result = await OrderbookInstance.SellListDelete.call();
    //     //const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
    //     //console.log('The element that is deleted is:', intprice);
    //     await OrderbookInstance.SellListDelete();
    
    // });
    // //*******************Test 7*************************
    // it('should return the Selllist peak', async() => {
    //     const OrderbookInstance = await Orderbook.deployed(); 
        
    
    //     const result = await OrderbookInstance.SellListPeak.call();
    //     const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
    //     console.log('The SellList peak after delete is:', intprice);
    
    // });
    //*******************Test 8*************************
    it('should submit 3 Bids from accounst[1]', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
       
        accounts = await web3.eth.getAccounts();
        for(let j = 1; j <= 1 ; j++){
            await OrderbookInstance.submitBid (j, 1, {from: accounts[1]});
        } 
        
        
    });
   //*******************Test 9*************************
    it('should return the BuyList peak', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
    
        const result = await OrderbookInstance.BuyListPeak.call();
        const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
        console.log('The Buylist peak  is:', intprice);

    });
    //*******************Test 10*************************
    // it('should delete the BuyList peak', async() => {
    //     const OrderbookInstance = await Orderbook.deployed(); 
        
    
    //     //const result = await OrderbookInstance.SellListDelete.call();
    //     //const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
    //     //console.log('The element that is deleted is:', intprice);
    //     await OrderbookInstance.BuyListDelete();
    
    // });
    // //*******************Test 11*************************
    // it('should return the BuyList peak', async() => {
    //     const OrderbookInstance = await Orderbook.deployed(); 
    
    //     const result = await OrderbookInstance.BuyListPeak.call();
    //     const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
    //     console.log('The Buylist peak after delete is:', intprice);

    // });
    //*******************Test 12*************************
    it('should return both the total and available token balance of accounts[1]', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        
        accounts = await web3.eth.getAccounts();
        
        const totalbalance = await OrderbookInstance.TotalTokenBalance(accounts[1], tokenaddress);
        const availablebalance = await OrderbookInstance.AvailableTokenBalance(accounts[1], tokenaddress);
        
        console.log('The total token balance of accounts[1] before trade is:',totalbalance.toNumber());
        console.log('The available token balance of accounts[1] before trade is:',availablebalance.toNumber());
    
    });
    //*******************Test 13*************************

    it('should return both the total and available ether balance of accounts[0]', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        

        accounts = await web3.eth.getAccounts();

        const totalbalance = await OrderbookInstance.TotalEtherBalance(accounts[0]);
        const availablebalance = await OrderbookInstance.AvailableEtherBalance(accounts[0]);
        
        console.log('The total Ether balance of accounts[0] before trade is:',totalbalance.toNumber());
        console.log('The available Ether balance of accounts[0] before trade is:',availablebalance.toNumber());

        
    
    });
    //*******************Test 14*************************
    it('should match the orders', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        
        await OrderbookInstance.CloseMarket();
        const state =  await OrderbookInstance.getState();
        console.log('Market is currently:',state.toString());
        
        const receipt = await OrderbookInstance.MatchOrders();
        
        const result = await OrderbookInstance.BuyListPeak.call();
        const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
        console.log('The Buylist peak after matching orders is:', intprice);


        console.log('********************************************');
        const gasUsed = receipt.receipt.gasUsed;
        console.log(`GasUsed for Matching: ${receipt.receipt.gasUsed}`);
        
        //const contract = new web3.eth.Contract(OrderbookInstance.abi, OrderbookInstance.address);

        //Now get evens depending on what you need
        //contract.getPastEvents("allEvents", {fromBlock: 0, toBlock: "latest"}) .then(console.log) ;

    
    
    });

    //*******************Test 15*************************

    it('should return both the total and available token balance of accounts[1]', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        
        accounts = await web3.eth.getAccounts();
        
        const totalbalance = await OrderbookInstance.TotalTokenBalance(accounts[1], tokenaddress);
        const availablebalance = await OrderbookInstance.AvailableTokenBalance(accounts[1], tokenaddress);
        
        console.log('The total token balance of accounts[1] after trade is:',totalbalance.toNumber());
        console.log('The available token balance of accounts[1] after trade is:',availablebalance.toNumber());
    
    });
    //*******************Test 16*************************

    it('should return both the total and available ether balance of accounts[0]', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
        

        accounts = await web3.eth.getAccounts();

        const totalbalance = await OrderbookInstance.TotalEtherBalance(accounts[0]);
        const availablebalance = await OrderbookInstance.AvailableEtherBalance(accounts[0]);
        
        console.log('The total Ether balance of accounts[0] after trade is:',totalbalance.toNumber());
        console.log('The available Ether balance of accounts[0] after trade is:',availablebalance.toNumber());

        
    
    });
    //*******************Test 11*************************
    it('should return the BuyList peak', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
    
        const result = await OrderbookInstance.BuyListPeak.call();
        const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
        console.log('The Buylist peak after match is:', intprice);

    });
    //*******************Test 12*************************
    it('should return the BuyIndex', async()=>{
        const OrderbookInstance = await Orderbook.deployed(); 
        const buyindex =  await OrderbookInstance.BuyIndex();
        console.log('The BuyIndex after match is:', buyindex.toNumber());

    });

    //*******************Test 13*************************
    it('should return the SellList peak', async() => {
        const OrderbookInstance = await Orderbook.deployed(); 
    
        const result = await OrderbookInstance.SellListPeak.call();
        const {0: addsender, 1: intprice, 2: auxprice, 2: intvolume} = result;
        console.log('The SellList peak after match is:', intprice);

    });
    //*******************Test 12*************************
    it('should return the SellIndex', async()=>{
        const OrderbookInstance = await Orderbook.deployed(); 
        const buyindex =  await OrderbookInstance.SellIndex();
        console.log('The SellIndex after match is:', buyindex.toNumber());

    });
    //*******************Test 13*************************   
    //it('should return the refunded Ethers', async()=>{
        //const OrderbookInstance = await Orderbook.deployed(); 
        
        //const AvailableEtherBalance = await OrderbookInstance.AvailableEtherBalance(accounts[1]);
        //console.log('The number of Ethers refunded to account[1] is:', AvailableEtherBalance.toNumber());
    //});
    
    
    
       

    


    

});

// 
//Notes and Tutorials:
//  1- if you write tests in two difefrenet contract blocks, they are independent and hence are talking to two completely different instances of your smart contract.
//  2- Inside our contract blocks, we define each test with an it statement.
//  3- Gettin GasPrice:
    //const tx = await web3.eth.getTransaction(receipt.tx);
    //const gasPrice = tx.gasPrice;
    //console.log(`GasPrice: ${tx.gasPrice}`);