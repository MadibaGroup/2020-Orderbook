var CallMarket = artifacts.require("./Call_Market.sol"); 

//const BN = require('bn.js');


// module.exports = async function(deployer) {
//     deployer.deploy(modularExp).then(() => {
//         return deployer.deploy(modularExp);
//     }).then(async () => {
//         //var modularExp = await modularExp.deployed();
//         await modularExp.js_call();       
//     });      
//     };
// module.exports = function (deployer) {
//     deployer.deploy(PQ1);
//     console.log("I was deployed!");
// };

// // module.exports =  function (deployer) {
    
// //     deployer.deploy(PQ2, 60).then (function(){
// //         return deployer.deploy(CallMarket, PQ2.address)

// //     });
   
// //     console.log("I was deployed!");



// // };
// module.exports = function (deployer) {
//     deployer.deploy(PQ2);
//     console.log("I was deployed!");
// };
// module.exports = function (deployer) {
//     deployer.deploy(PQ3);
//     console.log("I was deployed!");
// };
// module.exports = function (deployer) {
//     deployer.deploy(PQ4);
//     console.log("I was deployed!");
// };
// module.exports = function (deployer) {
//     deployer.deploy(PQ5);
//     console.log("I was deployed!");
// };


module.exports =  function (deployer) {
    
    deployer.deploy(CallMarket);
    console.log("I was deployed!");


};

// module.exports = function (deployer) {
//     deployer.deploy(MP);
//     console.log("I was deployed!");
// };