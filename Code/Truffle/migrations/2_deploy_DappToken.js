var DappToken = artifacts.require("./DappToken.sol"); 
module.exports = function (deployer) {
    deployer.deploy(DappToken, 10000000);
    
    console.log("I was deployed!");
    

};