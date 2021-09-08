const { providers, Wallet } = require('ethers')
const { ethers } = require('hardhat')

require('dotenv').config();

const main = async () => {
  const addressDappToken ='0xb3a8791b48FcEAec736330dfc4dF38Cf06D1f183'; //the address of the DAppToken on L2
  const CallMarketaddress = '0x45F5F09364F5cc7D12F49d40814000b1fF9c6cc2';
  
  const walletPrivateKey = process.env.DEVNET_PRIVKEY

  const l2Provider = new providers.JsonRpcProvider(process.env.L2RPC)

  const l2Wallet = new Wallet(walletPrivateKey, l2Provider)
   


  // const L2CallMarket = await ( await ethers.getContractFactory('CallMarket')).connect(l2Wallet)
  // const l2CallMarket = await L2CallMarket.deploy()
  // console.log("Deploying CallMarket to L2")
  // await l2CallMarket.deployed()
  // console.log(`Call Market is deployed to ${l2CallMarket.address}`)

  // CallMarketaddress = l2CallMarket.address;
  const l2CallMarket = await (await hre.ethers.getContractAt('CallMarket',CallMarketaddress)).connect(l2Wallet)

  // const l2DappToken = await (await hre.ethers.getContractAt('DappToken',addressDappToken )).connect(l2Wallet)
  // const DapptokenBalanace = await l2DappToken.balanceOf(l2Wallet.address) 
  // console.log('The DappToken balance of  l2wallet is:', DapptokenBalanace.toNumber());

  // const result = await l2DappToken.allowance(l2Wallet.address,CallMarketaddress);
  // console.log('l2wallet allowes the CallMarket contract to spend:',result.toNumber());

  // //await l2DappToken.approve(CallMarketaddress, 10000000000);
       
  // await l2CallMarket.depositToken(addressDappToken, 1000000000);

  // const totalTokenbalance = await l2CallMarket.totalTokenBalance(l2Wallet.address);
  // // //const totalEtherbalance = await l2CallMarket.totalEtherBalance(l2Wallet.address);

  // console.log('The token balance of account[0] is:', totalTokenbalance.toNumber());
  // //console.log('The Ether balance of account[0] is:', totalEtherbalance.toNumber());
  // console.log('********************************************');

  
  // console.log("token deposits done! Let's submit orders now")
  // await l2CallMarket.openMarket();

  var maximum = 100;
  var minimum = 1;

  var array = [];

  for(let j = 1; j <= 20  ; j++)
  {
    var randomnumber = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
    await l2CallMarket.submitAsk(randomnumber, 1);
    array.push(j);
  } 
  console.log(array.length,'asks have been succsessfully submitted');
    
  const selllistCounter = await l2CallMarket.sellistCounter.call();
  console.log('selllistcounter is',selllistCounter.toNumber() )
  const numOrders = await l2CallMarket.numOrders.call();
  console.log('numOrders is',numOrders.toNumber() )
  

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
