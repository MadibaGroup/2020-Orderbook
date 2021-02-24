

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x39228aeb624b1b2ee3703632d9bef87e100da5c6'; //the address of the ERC20 token; it has the same address as Kovan
var CallMarketaddress;





//******************* Deploys the CallMaket and stores its address *************************

contract('CallMarket', function(accounts) {

    it('should store the address of the CallMarket into the var CallMarketaddress', async() => {
        
        const CallMarketInstance = await CallMarket.deployed(); 
        CallMarketaddress = CallMarketInstance.address;
        console.log('The address of the CallMarket contract is:', CallMarketInstance.address);
        
    });



});
