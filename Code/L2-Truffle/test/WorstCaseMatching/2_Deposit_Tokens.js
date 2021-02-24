

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x39228aeb624b1b2ee3703632d9bef87e100da5c6'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xcCe4032149779EfDB25aDC4647c89123f7A1F280';
var accounts;




contract('CallMarket', function(accounts) {
   

    it('should deposit tokens from accounst[0] to the CallMarket contract', async() => {

        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        accounts = await web3.eth.getAccounts();


        const DappTokenInstance = await DappToken.at(addressDappToken); //loads the DappToken from its address
        await DappTokenInstance.approve(CallMarketaddress, 1200, {from: accounts[0]});
       
        const receipt = await CallMarketInstance.depositToken (addressDappToken, 1200, {from: accounts[0]});

        const totalTokenbalance = await CallMarketInstance.totalTokenBalance(accounts[0]);

        console.log('The token balance of account[0] is:', totalTokenbalance.toNumber());
    });
    


});
