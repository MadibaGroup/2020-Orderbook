var testordermatching = artifacts.require("./testordermatching.sol"); 
module.exports = function (deployer) {

    if (deployer.network === 'skipMigrations') {
        return;
    }
    deployer.deploy(testordermatching);
    
    console.log("I was deployed!");
    

};