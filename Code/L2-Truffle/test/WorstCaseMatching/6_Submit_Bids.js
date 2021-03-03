

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x39228aeb624b1b2ee3703632d9bef87e100da5c6'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xbfFD1b8b307244407B250892A1d667AD8ce7Ef68';
var accounts;



contract('CallMarket', function(accounts) {
    //this.timeout(0);
    
    it('should submit Bids from accounst[1]', async() => {
        
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        //var receipt = null;
        //var array = [];
        
        accounts = await web3.eth.getAccounts();
        for(let j = 280; j <= 309  ; j++){
           
            await CallMarketInstance.submitBid (j, 1, {from: accounts[0]});
            //array.push(j);
            //console.log('Bid',j,' volume is equal to:', 1);
            //console.log('Bid',j);
            //console.log('the tx receipt is:', receipt);
            //console.log('******************************');

        } 
        //console.log(array.length,'bids have been succsessfully submitted');
        //console.log('********************************************');
    });

    
});
