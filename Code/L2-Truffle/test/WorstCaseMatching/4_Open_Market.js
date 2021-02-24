

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x39228aeb624b1b2ee3703632d9bef87e100da5c6'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xcCe4032149779EfDB25aDC4647c89123f7A1F280';





contract('CallMarket', function(accounts) {

    it('should open the market on the Dapp Token', async() => {
      
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        await CallMarketInstance.openMarket ();
     
    });


});
