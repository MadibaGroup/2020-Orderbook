

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x39228aeb624b1b2ee3703632d9bef87e100da5c6'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xbfFD1b8b307244407B250892A1d667AD8ce7Ef68';
var accounts;




contract('CallMarket', function(accounts) {
    

    it('should deposit Ethers from accounts[0] to the CallMarket contract', async() => {
   
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        accounts = await web3.eth.getAccounts();

        //Following "value" is in wei.
        //1 ether = 1,000,000,000,000,000,000 wei
        //Note that the sender must have enough ether on Arbitrum to be able to do the transfer (This can be done using https://bridge.offchainlabs.com/)
        await CallMarketInstance.depositEther({from: accounts[0], value: 37900}); //transferring 0.000000000000000001 eth
        
                
        
        const totalEtherbalance = await CallMarketInstance.totalEtherBalance(accounts[0]);


        console.log('The Ether balance of accounts[0]  is:',totalEtherbalance.toNumber());
        console.log('********************************************');
        const num = await CallMarketInstance.getBalance();
        console.log('The Ether balance of Lissy is:', num.toNumber()); 

    });



});
