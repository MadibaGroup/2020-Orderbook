


const hre = require("hardhat");
const ethers = require("ethers");
const addressDappToken ='0x9D83C3c3e39d12416c395Da096988511B57E712F'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress ='0x244B16EB248cD6e8e72220BA17588A04fA418695';


require('dotenv').config();

const main = async () => {
   
    const accounts = await hre.ethers.getSigners();

    const infuraKey = process.env.INFURA_KEY
    if(!infuraKey) throw new Error("No INFURA_KEY set.")

    const walletPrivateKey = process.env.DEVNET_PRIVKEY
    if(!walletPrivateKey) throw new Error("No DEVNET_PRIVKEY set.")


    const l1Provider = new ethers.providers.JsonRpcProvider(process.env.L1RPC)
    const l2Provider = new ethers.providers.JsonRpcProvider(process.env.L2RPC)
    const signer = new ethers.Wallet(walletPrivateKey)

    const l1Signer = signer.connect(l1Provider);
    const l2Signer = signer.connect(l2Provider);


    var maximum = 100;
    var minimum = 1;

    const l2CallMarket = await (await hre.ethers.getContractAt('CallMarket',CallMarketaddress )).connect(l2Signer)

    await l2CallMarket.openMarket();

    var receipt = null;
    var array = [];
    
    for(let j = 1; j <= 200  ; j++){


        var randomnumber = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
        receipt = await l2CallMarket.connect(l2Signer).submitAsk(randomnumber, 1);
            array.push(j);
            //console.log('Ask',j,' volume is equal to:', 1);
            console.log('Ask',j);
            console.log('the tx receipt is:', receipt);
            console.log('******************************');
        } 
        console.log(array.length,'asks have been succsessfully submitted');
        console.log('********************************************');
    
   
    


}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

