const linkedlist = artifacts.require('linkedlist');
const Node = artifacts.require('Node');
//var Itemaddress;




// contract('ObjectFactory', function(accounts) {
//     it('should create another object', async() => {
//         const ObjectFactoryInstance = await ObjectFactory.deployed(); 
        
//         await ObjectFactoryInstance.
        
//     });



// contract('Item', function(accounts) {
//     it('should create another object', async() => {
//         const ItemtInstance = await Item.deployed(); 
//         //accounts = await web3.eth.getAccounts();
//         Itemaddress = ItemtInstance.address;
//         //const receipt = await FactorytInstance.add("0x0000000000000000000000000000000000000000",{from: accounts[0]});
//         //const tx = await web3.eth.getTransaction(receipt.tx);
//         //console.log(`GasPrice: ${tx}`);
//         //await ItemtInstance.addNew("0x1000000000000000000000000000000000000000");
//     });


// });
contract('linkedlist', function(accounts) {
    it('should create another object', async() => {
        const linkedlistInstance = await linkedlist.deployed(); 
        //accounts = await web3.eth.getAccounts();
        
        //const receipt = await FactorytInstance.add("0x0000000000000000000000000000000000000000",{from: accounts[0]});
        //const tx = await web3.eth.getTransaction(receipt.tx);
        //console.log(`GasPrice: ${tx}`);
        //const headprice = linkedlisttInstance.getheadprice(headnodeaddress);
        //console.log('The headprice before adding another node is:', headprice);

        const head = await linkedlistInstance.headnodeaddress();
        console.log('The head add:', head);
        await linkedlistInstance.add(head,2);
        //const {0: link, 1: next} = result;
        //console.log('The link is:', link);
        //console.log('The next is:', next);
        const nextprice = linkedlistInstance.getnextprice();
        const headprice2 = linkedlistInstance.getheadprice(head);
        console.log('The headprice after adding another node is:', headprice2);
        console.log('The nextprice after adding another node is:', nextprice);

        

    });


});

