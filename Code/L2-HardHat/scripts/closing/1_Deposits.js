


const hre = require("hardhat");
const ethers = require("ethers");
const addressDappToken ='0x9D83C3c3e39d12416c395Da096988511B57E712F'; //the address of the ERC20 token; it has the same address as Kovan
var CallMarketaddress;


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




    const L2CallMarket = await (await hre.ethers.getContractFactory('CallMarket')).connect(l2Signer)
    
    console.log("Deploying CallMarket to L2")
    
    const l2CallMarket = await L2CallMarket.deploy()
    await l2CallMarket.deployed()
    console.log(`deployed to ${l2CallMarket.address}`)

    CallMarketaddress = l2CallMarket.address;

    const l2DappToken = await (await hre.ethers.getContractAt('DappToken',addressDappToken )).connect(l2Signer)
    
    
    await l2DappToken.connect(l2Signer).approve(CallMarketaddress, 10000000000);
       
    await l2CallMarket.connect(l2Signer).depositToken(addressDappToken, 10000000000);

    const totalTokenbalance = await l2CallMarket.totalTokenBalance(l2Signer.address);
    const totalEtherbalance = await l2CallMarket.totalEtherBalance(l2Signer.address);

    console.log('The token balance of account[0] (Bob) is:', totalTokenbalance.toNumber());
    console.log('The Ether balance of account[0] (Bob) is:', totalEtherbalance.toNumber());
    console.log('********************************************');





        //Following "value" is in wei.
        //1 ether = 1,000,000,000,000,000,000 wei
        //Note that the sender must have enough ether on Arbitrum to be able to do the transfer (This can be done using https://bridge.offchainlabs.com/)
    await l2CallMarket.connect(l2Signer).depositEther({value: 2200}); //transferring 0.000000000000000001 eth
        
                
        
    const totalEtherbalance2 = await l2CallMarket.totalEtherBalance(l2Signer.address);


    console.log('The Ether balance of accounts[0]  is:',totalEtherbalance2.toNumber());
    console.log('********************************************');
    const num = await l2CallMarket.getBalance();
    console.log('The Ether balance of Lissy is:', num.toNumber()); 




}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
