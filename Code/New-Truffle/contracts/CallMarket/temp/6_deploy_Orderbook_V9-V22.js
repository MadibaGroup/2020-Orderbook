var Orderbook_V9 = artifacts.require("./Orderbook_V9.sol"); 
var Orderbook_V10 = artifacts.require("./Orderbook_V10.sol"); 
var Orderbook_V11 = artifacts.require("./Orderbook_V11.sol"); 
var Orderbook_V12 = artifacts.require("./Orderbook_V12.sol"); 
var Orderbook_V13 = artifacts.require("./Orderbook_V13.sol"); 
var Orderbook_V14 = artifacts.require("./Orderbook_V14.sol"); 
var Orderbook_V15 = artifacts.require("./Orderbook_V15.sol"); 
var Orderbook_V17 = artifacts.require("./Orderbook_V17.sol"); 
var Orderbook_V18 = artifacts.require("./Orderbook_V18.sol"); 
var Orderbook_V19 = artifacts.require("./Orderbook_V19.sol"); 
var Orderbook_V20 = artifacts.require("./Orderbook_V20.sol"); 
var Orderbook_V21 = artifacts.require("./Orderbook_V21.sol"); 
var Orderbook_V22 = artifacts.require("./Orderbook_V22.sol"); 



module.exports = function (deployer) {
    if (deployer.network === 'skipMigrations') {
        return;
    }
    deployer.deploy(Orderbook_V9);
    deployer.deploy(Orderbook_V10);
    deployer.deploy(Orderbook_V11);
    deployer.deploy(Orderbook_V12);
    deployer.deploy(Orderbook_V13);
    deployer.deploy(Orderbook_V14);
    deployer.deploy(Orderbook_V15);
    deployer.deploy(Orderbook_V17);
    deployer.deploy(Orderbook_V18);
    deployer.deploy(Orderbook_V19);
    deployer.deploy(Orderbook_V20);
    deployer.deploy(Orderbook_V21);
    deployer.deploy(Orderbook_V22);

    console.log("I was deployed!");
   


};