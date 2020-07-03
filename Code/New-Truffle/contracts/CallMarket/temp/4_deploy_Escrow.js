var Escrow = artifacts.require("./Escrow.sol"); 
module.exports = function (deployer) {
    if (deployer.network === 'skipMigrations') {
        return;
    }
    deployer.deploy(Escrow);
    
    console.log("I was deployed!");
    

};