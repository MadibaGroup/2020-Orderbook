var CallMarket = artifacts.require("./Call_Market.sol"); 
var PQ1 = artifacts.require("./PQ1_Heap_Dynamic_Array.sol"); 
var PQ2 = artifacts.require("./PQ2_Heap_Static_Array.sol"); 
var PQ3 = artifacts.require("./PQ3_Heap_Mapping.sol")
var PQ4 = artifacts.require("./PQ4_Linkedlist.sol")
var PQ5 = artifacts.require("./PQ5_Linkedlist_Mapping.sol")
var MP = artifacts.require("./Mapping.sol")
var PQaddress;
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
    deployer.deploy(PQ1);
    console.log("I was deployed!");
};

// module.exports =  function (deployer) {
    
//     deployer.deploy(PQ2, 60).then (function(){
//         return deployer.deploy(CallMarket, PQ2.address)

//     });
   
//     console.log("I was deployed!");



// };
module.exports = function (deployer) {
    deployer.deploy(PQ2);
    console.log("I was deployed!");
};
module.exports = function (deployer) {
    deployer.deploy(PQ3);
    console.log("I was deployed!");
};
module.exports = function (deployer) {
    deployer.deploy(PQ4);
    console.log("I was deployed!");
};
module.exports = function (deployer) {
    deployer.deploy(PQ5);
    console.log("I was deployed!");
};


module.exports =  function (deployer) {
    
    deployer.deploy(CallMarket);
    console.log("I was deployed!");
   
    console.log("I was deployed!");



};

// module.exports = function (deployer) {
//     deployer.deploy(MP);
//     console.log("I was deployed!");
// };