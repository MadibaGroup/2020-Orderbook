var LinkedList = artifacts.require("./LinkedList.sol"); 
//const BN = require('bn.js');


// module.exports = async function(deployer) {
//     deployer.deploy(modularExp).then(() => {
//         return deployer.deploy(modularExp);
//     }).then(async () => {
//         //var modularExp = await modularExp.deployed();
//         await modularExp.js_call();       
//     });      
//     };

module.exports = function (deployer) {
    deployer.deploy(LinkedList);
    //Orderbook_V8Instance = await Orderbook_V8.deployed();
    console.log("I was deployed!");
    //HelloInstance.show_result().on('data', event => console.log(event));

    //var output = await app.toy();
    //console.log("This is the output:", output);
    //console.log("-------------")
    //console.log(output.logs[0])
    //var a = new BN(output.logs[0]);
    //event show_result(bytes byteValue, bool boolValue, uint uintValue);
    //console.log("output is:", a);


};