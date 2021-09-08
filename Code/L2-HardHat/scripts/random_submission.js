const { providers, Wallet } = require('ethers')
const { ethers } = require('hardhat')

require('dotenv').config();

const main = async () => {
  const addressDappToken ='0x0391de5c475479bD9E7a0355AA022D864C57d876'; //the address of the DAppToken on L2
  var CallMarketaddress;  
  
  const walletPrivateKey = process.env.DEVNET_PRIVKEY

  const l2Provider = new providers.JsonRpcProvider(process.env.L2RPC)

  const l2Wallet = new Wallet(walletPrivateKey, l2Provider)
   


  const L2CallMarket = await ( await ethers.getContractFactory('CallMarket')).connect(l2Wallet)
  const l2CallMarket = await L2CallMarket.deploy()
  console.log("Deploying CallMarket to L2")
  await l2CallMarket.deployed()
  console.log(`Call Market is deployed to ${l2CallMarket.address}`)

  CallMarketaddress = l2CallMarket.address;

  const l2DappToken = await (await hre.ethers.getContractAt('DappToken',addressDappToken )).connect(l2Wallet)
    
  await l2DappToken.approve(CallMarketaddress, 10000000000);
       
  await l2CallMarket.depositToken(addressDappToken, 10000000000);

  const totalTokenbalance = await l2CallMarket.totalTokenBalance(l2Wallet.address);
  const totalEtherbalance = await l2CallMarket.totalEtherBalance(l2Wallet.address);

  console.log('The token balance of account[0] is:', totalTokenbalance.toNumber());
  console.log('The Ether balance of account[0] is:', totalEtherbalance.toNumber());
  console.log('********************************************');

  
  console.log("token deposits done! Let's submit orders now")
  await l2CallMarket.openMarket();



  var array = [];

  for(let j = 1; j <= 200  ; j++)
  {
    var randomnumber = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
    await l2CallMarket.submitAsk(randomnumber, 1);
  } 
  console.log(array.length,'asks have been succsessfully submitted');
    
  



}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
