var DappToken = artifacts.require("./DappToken.sol"); 
module.exports = function (deployer) {
    deployer.deploy(DappToken, 10000000);
    //Orderbook_V8Instance = await Orderbook_V8.deployed();
    console.log("I was deployed!");
    //HelloInstance.show_result().on('data', event => console.log(event));
    //DappToken.totalSupply().then
    //var output = await app.toy();
    //console.log("This is the output:", output);
    //console.log("-------------")
    //console.log(output.logs[0])
    //var a = new BN(output.logs[0]);
    //event show_result(bytes byteValue, bool boolValue, uint uintValue);
    //console.log("output is:", a);


};