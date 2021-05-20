

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x2dc4dea5281738a92e8de9137a1088403dd3c160'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xB3267469542f52D9F572649a734B01a7DAeE64E1';

var accounts;
var maximum = 100;
var minimum = 1;




//******************* Deploys the CallMaket and stores its address *************************
contract('CallMarket', function(accounts) {
    

   
    //*******************Test 6*************************
    it('should submit Bids from accounst[1]', async() => {
        
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        var receipt = null;
        var array = [];
        
        accounts = await web3.eth.getAccounts();
        for(let j = 1; j <= 200  ; j++){
           
            
            var randomnumber = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
            receipt = await CallMarketInstance.submitBid (randomnumber, 1, {from: accounts[0]});
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
