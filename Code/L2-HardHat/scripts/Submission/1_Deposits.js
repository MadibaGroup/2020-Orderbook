const hre = require("hardhat");
const ethers = require("ethers");
const utils = require ("ethers");
const BigNumber = require ("ethers");

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

    const ethercBridge = "0x2948ac43e4AfF448f6af0F7a11F18Bb6062dd271";
    const addressDappToken ;
    var CallMarketaddress;
    
    const L1CallMarket = await (await hre.ethers.getContractFactory('CallMarket')).connect(l1Signer)
    console.log("Deploying CallMarket to L1")
    const l1CallMarket = await L1CallMarket.deploy()
    await l1CallMarket.deployed()
    CallMarketaddress = l1CallMarket.address;
    console.log(`Call Market deployed to ${CallMarketaddress}`)

   
    //deposit tokens from signer to the CallMarket contract

    const L1DappToken = await (await hre.ethers.getContractFactory('DappToken')).connect(l1Signer)
    console.log("Deploying DappToken to L1")
    const l1DappToken = await L1DappToken.deploy(100000000000)
    await l1DappToken.deployed()
    addressDappToken = l1DappToken.address;

    //const DappTokenInstance = await ethers.getContractAt("DappToken", addressDappToken); //loads the DappToken from its address


    const ethrbidge = await ethers.getContractAt("EthERC20Bridge", ethercBridge); 

    await ethrbidge.deposit(addressDappToken, signer.address, BigNumber.from(1000000), BigNumber.from(10000000000000), BigNumber.from(0), utils.parseUnits('10', 'gwei'), '0x');
    const L2address = await ethrbidge.calculateL2TokenAddress(addressDappToken)
    console.log('********************************************');
    console.log(L2address);
       
    //await l1CallMarket.depositToken(addressDappToken, 500,);

    //const totalTokenbalance = await l1CallMarket.totalTokenBalance(Signer.address);
    //const totalEtherbalance = await l1CallMarket.totalEtherBalance(Signer.address);

    //console.log('The token balance of the signer is:', totalTokenbalance.toNumber());
    //console.log('The Ether balance of the signer is:', totalEtherbalance.toNumber());
    //console.log('********************************************');



    



}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });







































