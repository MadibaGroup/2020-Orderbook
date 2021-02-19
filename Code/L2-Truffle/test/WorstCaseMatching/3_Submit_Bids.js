

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x2dc4dea5281738a92e8de9137a1088403dd3c160'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xAE0b960010ec76A0E9aA3F0Cea4E368c287a380d';

var accounts;




//******************* Deploys the CallMaket and stores its address *************************
contract('CallMarket', function(accounts) {
    

   
    //*******************Test 6*************************
    it('should submit Bids from accounst[1]', async() => {
        
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        var receipt = null;
        var array = [];
        
        accounts = await web3.eth.getAccounts();
        for(let j = 73; j <= 76  ; j++){
           
            receipt = await CallMarketInstance.submitBid (j, 1, {from: accounts[0]});
            array.push(j);
            //console.log('Bid',j,' volume is equal to:', 1);
            //console.log('Bid',j);
            //console.log('the tx receipt is:', receipt);
            //console.log('******************************');

        } 
        console.log(array.length,'bids have been succsessfully submitted');
        console.log('********************************************');
    });

    
});
