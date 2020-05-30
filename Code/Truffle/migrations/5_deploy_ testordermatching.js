var testordermatching = artifacts.require("./testordermatching.sol"); 
module.exports = function (deployer) {
    deployer.deploy(testordermatching);
    
    console.log("I was deployed!");
    

};