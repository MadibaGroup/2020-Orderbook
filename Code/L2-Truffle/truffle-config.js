const wrapProvider = require('arb-ethers-web3-bridge').wrapProvider
const HDWalletProvider = require('@truffle/hdwallet-provider')
const mnemonic =
  'surge ability together fruit retire harvest release turkey social coffee owner uphold panel group car'

module.exports = {
mocha: {
    enableTimeouts: false,
    //before_timeout: 120000 // Here is 2min but can be whatever timeout is suitable for you.
    before_timeout: 3000000000 // Here is 5min but can be whatever timeout is suitable for you.
    
    },
networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      //port: 8545,
      network_id: '*', // Match any network id
    },
    
    remote_arbitrum: {
      provider: function () {
        return wrapProvider(
          new HDWalletProvider(mnemonic, 'https://kovan3.arbitrum.io/rpc')
        )
      },
      network_id: '*', // Match any network id
      gasPrice: 0,
      
    },
  },
  compilers: {
    solc: {
      //version: "0.5.3", // Fetch exact version from solc-bin (default: truffle's version)
      version: "0.6.11",
      //docker: true, // Use "0.5.3" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
}