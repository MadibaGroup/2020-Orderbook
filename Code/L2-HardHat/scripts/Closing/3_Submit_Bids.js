


const hre = require("hardhat");
const ethers = require("ethers");
const addressDappToken ='0x40bed42b1162EDb35A0dA7A48C32bDE014Ee0E3A'; //the address of the ERC20 token; it has the same address as Kovan
const CallMarketaddress ='0x18BF65069Fdaed79f8BDB0B6EDa87d5cc46F6E28';


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

