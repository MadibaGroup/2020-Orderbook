

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken ='0x3e9c93df1cadc164d2b2751f6874a8d3eaf68a2e'; //the address of the ERC20 token; it has the same address as Kovan
var CallMarketaddress;

var accounts;




//******************* Deploys the CallMaket and stores its address *************************
contract('CallMarket', function(accounts) {
    //*******************Test 1*************************
    it('should store the address of the CallMarket into the var CallMarketaddress', async() => {
        const CallMarketInstance = await CallMarket.deployed(); 
        CallMarketaddress = CallMarketInstance.address;
        console.log('The address of the CallMarket contract is:', CallMarketInstance.address);
        console.log('********************************************');
        
    });

    //*******************Test 2*************************
    it('should deposit tokens from accounst[0] to the CallMarket contract', async() => {

        const CallMarketInstance = await CallMarket.deployed(); 
       

        //const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        accounts = await web3.eth.getAccounts();

        const DappTokenInstance = await DappToken.at(addressDappToken); //loads the DappToken from its address
        await DappTokenInstance.approve(CallMarketaddress, 500, {from: accounts[0]});
       
        const receipt = await CallMarketInstance.depositToken (addressDappToken, 500, {from: accounts[0]});

        const totalTokenbalance = await CallMarketInstance.totalTokenBalance(accounts[0]);
        const totalEtherbalance = await CallMarketInstance.totalEtherBalance(accounts[0]);

        console.log('The token balance of account[0] (Bob) is:', totalTokenbalance.toNumber());
        console.log('The Ether balance of account[0] (Bob) is:', totalEtherbalance.toNumber());
        console.log('********************************************');
    });
    


});
