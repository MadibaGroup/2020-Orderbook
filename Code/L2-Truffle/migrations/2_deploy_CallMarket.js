var CallMarket = artifacts.require("./CallMarket.sol"); 
//var PQ1 = artifacts.require("./HeapDynamicArray.sol"); 
//var PQ2 = artifacts.require("./HeapStaticArray.sol"); 
//var PQ3 = artifacts.require("./HeapMapping.sol");
//var PQ4 = artifacts.require("./LinkedList.sol");
var PQ5 = artifacts.require("./LinkedListMapping.sol");



module.exports =  function (deployer) {
    

    //For PQ1:
    //deployer.deploy(PQ1).then (function(){
        //return deployer.deploy(CallMarket, PQ1.address)
        //});
    //***********************************************************/
    //For PQ2:
    //deployer.deploy(PQ2,84).then (function(){
        //return deployer.deploy(CallMarket, PQ2.address)
        //});
    //***********************************************************/
    //For PQ3:
    //deployer.deploy(PQ3).then (function(){
        //return deployer.deploy(CallMarket, PQ3.address)
        //});
    //***********************************************************/
    //For PQ4:
    //deployer.deploy(PQ4).then (function(){
        //return deployer.deploy(CallMarket, PQ4.address)
        //});
    //deployer.deploy(CallMarket);
    //***********************************************************/
    //For PQ5:
    deployer.deploy(PQ5).then (function(){
        return deployer.deploy(CallMarket, PQ5.address)
        });
};

