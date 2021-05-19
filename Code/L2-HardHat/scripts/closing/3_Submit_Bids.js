


const hre = require("hardhat");
const ethers = require("ethers");
const addressDappToken ='0x9D83C3c3e39d12416c395Da096988511B57E712F'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress ='0xcE17BE19aa80396Ae1A1C9f8dd386C48c1533F52';


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


   

    const l2CallMarket = await (await hre.ethers.getContractAt('CallMarket',CallMarketaddress )).connect(l2Signer)

    //await l2CallMarket.openMarket();

    var receipt = null;
    var array = [];
    
    for(let j = 39; j <= 76  ; j++){
        
            receipt = await l2CallMarket.connect(l2Signer).submitBid(j, 1);
            array.push(j);
            //console.log('Ask',j,' volume is equal to:', 1);
            console.log('Bid',j);
            //console.log('the tx receipt is:', receipt);
            console.log('******************************');
        

        }


        
        console.log(array.length,'bids have been succsessfully submitted');
        console.log('********************************************');
    
   
    


}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

