

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x39228aeb624b1b2ee3703632d9bef87e100da5c6'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0x3c9006F42e6b649ED8281b52B7Eed6D99e71a348';
var accounts;



contract('CallMarket', function(accounts) {
    //this.timeout(0);


    it('should submit asks from accounst[0]', async() => {
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        //var receipt = null;
        //var array = [];
    
        accounts = await web3.eth.getAccounts();
        for(let j = 86; j >= 1  ; j--){
            
            await CallMarketInstance.submitAsk (j, 1 , {from: accounts[0]});
            //array.push(j);
            //console.log('Ask',j,' volume is equal to:', 1);
            //console.log('Ask',j);
            //console.log('the tx receipt is:', receipt);
            //console.log('******************************');
        } 
        //console.log(array.length,'asks have been succsessfully submitted');
        //console.log('********************************************');
    });
   
    



});
