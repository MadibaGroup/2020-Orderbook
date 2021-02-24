

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x2dc4dea5281738a92e8de9137a1088403dd3c160'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '';
var accounts;




contract('CallMarket', function(accounts) {
    this.timeout(0);
  
    it('should close the market and match the orders', async() => {
        
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);

        const receipt = await  CallMarketInstance.closeMarket();
        console.log('the tx receipt is:', receipt);
    });  
    
 



});
