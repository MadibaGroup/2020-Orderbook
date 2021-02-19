var CallMarket = artifacts.require("./CallMarket.sol"); 
var PQ1 = artifacts.require("./HeapDynamicArray.sol"); 
// var PQ2 = artifacts.require("./HeapStaticArray.sol"); 
// var PQ3 = artifacts.require("./HeapMapping.sol");
// var PQ4 = artifacts.require("./LinkedList.sol");
// var PQ5 = artifacts.require("./LinkedListMapping.sol");



module.exports =  function (deployer) {
    



    deployer.deploy(PQ1).then (function(){
        return deployer.deploy(CallMarket, PQ1.address)
        });


};

