

const CallMarket = artifacts.require('CallMarket.sol');
const DappToken = artifacts.require('DappToken');

const addressDappToken = '0x279dc89a3dcea80a2cdb20a87854f7820c0c2819'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress = '';

var accounts;
var maximum = 100;
var minimum = 1;



//******************* Deploys the CallMaket and stores its address *************************
contract('CallMarket', function(accounts) {
    

    //*******************Test 4*************************

    // it('should open the market on the Dapp Token', async() => {
      
    //     const CallMarketInstance = await CallMarket.at(CallMarketaddress);

    //     const receipt = await CallMarketInstance.openMarket ();
    //     //const gasUsed = receipt.receipt.gasUsed;
    //     //console.log(`GasUsed for openning the market: ${receipt.receipt.gasUsed}`);
    //     console.log('********************************************');
    // });
    //*******************Test 5*************************
    
    it('should submit asks from accounst[0]', async() => {
        const CallMarketInstance = await CallMarket.at(CallMarketaddress);
        var receipt = null;
        var array = [];
    
        accounts = await web3.eth.getAccounts();
        for(let j = 1; j <= 10  ; j++){


            var randomnumber = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
            receipt = await CallMarketInstance.submitAsk (randomnumber, 1, {from: accounts[0]});
            array.push(j);
            //console.log('Ask',j,' volume is equal to:', 1);
            console.log('Ask',j);
            console.log('the tx receipt is:', receipt);
            console.log('******************************');
        } 
        console.log(array.length,'asks have been succsessfully submitted');
        console.log('********************************************');
    });
   
    



});
