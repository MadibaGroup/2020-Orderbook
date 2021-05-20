

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x2dc4dea5281738a92e8de9137a1088403dd3c160'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xB3267469542f52D9F572649a734B01a7DAeE64E1';

var accounts;




//******************* Deploys the CallMaket and stores its address *************************
contract('CallMarket', function(accounts) {

  
    //*******************Test 1*************************
    it('should close the market and match the orders', async() => {
        
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);

        const receipt = await  CallMarketInstance.closeMarket();
        console.log('the tx receipt is:', receipt);
    });  
    
 



});
