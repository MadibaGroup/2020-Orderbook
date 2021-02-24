

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x2dc4dea5281738a92e8de9137a1088403dd3c160'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '';
var accounts;



contract('CallMarket', function(accounts) {

    this.timeout(0);

    it('should send back the tokens and ether', async() => {
        
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);

        const totalEtherbalance = await CallMarketInstance.totalEtherBalance(accounts[0]);
        await CallMarketInstance.claimEther(totalEtherbalance); 

        const totalTokenbalance = await CallMarketInstance.totalTokenBalance(accounts[0]);
        await CallMarketInstance.claimTokens(addressDappToken, totalTokenbalance); 
   
    });


        
     




});
