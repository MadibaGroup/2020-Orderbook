

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x2dc4dea5281738a92e8de9137a1088403dd3c160'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '0xAE0b960010ec76A0E9aA3F0Cea4E368c287a380d';

var accounts;




//******************* Deploys the CallMaket and stores its address *************************
contract('CallMarket', function(accounts) {
    

    //*******************Test 4*************************

    it('should open the market on the Dapp Token', async() => {
      
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);

        const receipt = await CallMarketInstance.openMarket ();
        //const gasUsed = receipt.receipt.gasUsed;
        //console.log(`GasUsed for openning the market: ${receipt.receipt.gasUsed}`);
        console.log('********************************************');
    });
    //*******************Test 5*************************
    
    it('should submit asks from accounst[0]', async() => {
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        var receipt = null;
        var array = [];
    
        accounts = await web3.eth.getAccounts();
        for(let j = 3; j >= 1  ; j--){
            
            receipt = await CallMarketInstance.submitAsk (j, 1 , {from: accounts[0]});
            array.push(j);
            //console.log('Ask',j,' volume is equal to:', 1);
            //console.log('Ask',j);
            //console.log('the tx receipt is:', receipt);
            //console.log('******************************');
        } 
        console.log(array.length,'asks have been succsessfully submitted');
        console.log('********************************************');
    });
   
    



});
