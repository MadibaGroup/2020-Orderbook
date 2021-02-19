

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x2dc4dea5281738a92e8de9137a1088403dd3c160'; //the address of the ERC20 token; it has the same address as Kovan
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
       
        accounts = await web3.eth.getAccounts();

        const DappTokenInstance = await DappToken.at(addressDappToken); //loads the DappToken from its address
        await DappTokenInstance.approve(CallMarketaddress, 750, {from: accounts[0]});
       
        const receipt = await CallMarketInstance.depositToken (addressDappToken, 750, {from: accounts[0]});

        const totalTokenbalance = await CallMarketInstance.totalTokenBalance(accounts[0]);
        const totalEtherbalance = await CallMarketInstance.totalEtherBalance(accounts[0]);

        console.log('The token balance of account[0] (Bob) is:', totalTokenbalance.toNumber());
        console.log('The Ether balance of account[0] (Bob) is:', totalEtherbalance.toNumber());
        console.log('********************************************');
    });
    //*******************Test 3*************************
    it('should deposit Ethers from accounts[0] to the CallMarket contract', async() => {
        
        const CallMarketInstance = await CallMarket.deployed(); 

        accounts = await web3.eth.getAccounts();

        //Following "value" is in wei.
        //1 ether = 1,000,000,000,000,000,000 wei
        //Note that the sender must have enough ether on Arbitrum to be able to do the transfer (This can be done using https://bridge.offchainlabs.com/)
        await CallMarketInstance.depositEther({from: accounts[0], value: 4500}); //transferring 0.000000000000000001 eth
        
                
        
        const totalEtherbalance = await CallMarketInstance.totalEtherBalance(accounts[0]);
        const totalTokenbalance = await CallMarketInstance.totalTokenBalance(accounts[0]);

        console.log('The Ether balance of accounts[0]  is:',totalEtherbalance.toNumber());
        console.log('The token balance of accounts[0] is:',totalTokenbalance.toNumber());
        console.log('********************************************');
        const num = await CallMarketInstance.getBalance();
        console.log('The Ether balance of Lissy is:', num.toNumber()); 
        console.log('********************************************');
    });



});
