const { BigNumber, providers, Wallet } = require('ethers')
const { ethers } = require('hardhat')
const { Bridge } = require('arb-ts')
require('dotenv').config()


const walletPrivateKey = process.env.DEVNET_PRIVKEY
const l1Provider = new providers.JsonRpcProvider(process.env.L1RPC)
const l2Provider = new providers.JsonRpcProvider(process.env.L2RPC)

const l1Wallet = new Wallet(walletPrivateKey, l1Provider)
const l2Wallet = new Wallet(walletPrivateKey, l2Provider)


const tokenDepositAmount = BigNumber.from(1000000000)

const main = async () => {
 
  const bridge = await Bridge.init(l1Wallet, l2Wallet)


  const L1DappToken = await (await ethers.getContractFactory('DappToken')).connect(l1Wallet)
  console.log('Deploying the test DappToken to L1')
  const l1DappToken = await L1DappToken.deploy(1000000000000000)
  await l1DappToken.deployed()
  console.log(`DappToken is deployed to L1 at ${l1DappToken.address}`)
  const erc20Address = l1DappToken.address

  
  const approveTx = await bridge.approveToken(erc20Address)
  const approveRec = await approveTx.wait()
  console.log(`You successfully allowed the Arbitrum Bridge to spend DappToken ${approveRec.transactionHash}`)


  const depositTx = await bridge.deposit(erc20Address, tokenDepositAmount)
  const depositRec = await depositTx.wait()

  

  const seqNumArr = await bridge.getInboxSeqNumFromContractTransaction(
    depositRec
  )

 
  const seqNum = seqNumArr[0]
  console.log(
    `Sequence number for your transaction found: ${seqNum.toNumber()}`
  )

  const redeemTransaction = await bridge.calculateL2RetryableTransactionHash(seqNum)

  
  console.log('waiting for L2 transaction:')
  const l2TxnRec = await l2Provider.waitForTransaction(
    redeemTransaction,
    undefined,
    1000 * 60 * 12
  )

  console.log( `L2 transaction found! Your DappToken balance is updated! ${l2TxnRec.transactionHash}`)

 

  const l2Data = await bridge.getAndUpdateL2TokenData(erc20Address)
  const l2WalletTokenBalance = l2Data && l2Data.ERC20 && l2Data.ERC20.balance
  console.log(
    `your l2Wallet has ${l2WalletTokenBalance.toString()} DappToken now!`
  )

  const l2Tokenaddress = await bridge.getERC20L2Address(erc20Address);
  console.log("DappToken L2 address is:",l2Tokenaddress)
  
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
