const LinkedList_V2 = artifacts.require('LinkedList_V2');
const Node = artifacts.require('Node');

var Nodeaddress;
//var tokenaddress;

contract('Node', function(accounts) {
    it('should store the address of the node into the var node address', async() => {
        const NodeInstance = await Node.deployed();  
        Nodeaddress = NodeInstance.address;
        console.log('The address of the node contract is:', NodeInstance.address);
        
    });




});

contract('LinkedList', function(accounts) {
    it('should insert 1 to the linkedlist', async() => {
    const LinkedListInstance = await LinkedList_V2.deployed(); 
    await LinkedListInstance.add(Nodeaddress);
    });

});

//contract('LinkedList', function(accounts) {
    // it('should insert 1 to the linkedlist', async() => {
    //     const LinkedListInstance = await LinkedList_V2.deployed(); 
    //     await LinkedListInstance.insert (1);
        
    //     //assert.equal(result.logs[0], "Error");

    //     //const result = await LinkedListInstance.printList.call();
    //     //console.log('The list is:', result.toNumber());

    //     const result = await LinkedListInstance.printhead.call();
    //     const {0: intprice, 1: next} = result;
    //     console.log('The price is:', intprice.toNumber());
    //     console.log('The next is:', next);

        
        
    // });
    // it('should insert 2 to the linkedlist', async() => {
    //     const LinkedListInstance = await LinkedList_V2.deployed(); 
    //     await LinkedListInstance.insert (2);
        
    //     const result = await LinkedListInstance.printhead.call();
    //     const {0: intprice, 1: next, 2: x} = result;
    //     console.log('The price is:', intprice.toNumber());
    //     console.log('The next is:', next);
    //     console.log('The x is:', x.toNumber());
    // });

    // it('should insert 3 to the linkedlist', async() => {
    //     const LinkedListInstance = await LinkedList_V2.deployed(); 
    //     await LinkedListInstance.insert (3);
        
    //     const result = await LinkedListInstance.printhead.call();
    //     const {0: intprice, 1: next, 2: x} = result;
    //     console.log('The price is:', intprice.toNumber());
    //     console.log('The next is:', next);
    //     console.log('The x is:', x.toNumber());
    // });

    // it('should print list', async() => {
    //     const LinkedListInstance = await LinkedList_V2.deployed(); 
        
        
    //     const result = await LinkedListInstance.printlist.call();
    //     //const {0: intprice, 1: next, 2: x} = result;
    //     console.log('The list is:', result.toNumber());
    //     //console.log('The next is:', next);
    //     //console.log('The x is:', x.toNumber());
    // });



    








    // it('should return the id of 4', async() => {
    //     const LinkedListInstance = await LinkedList.deployed(); 
    //     const reuslt = await LinkedListInstance.findIdForData(4);
    //     console.log('The id of 4 is:', reuslt.toNumber());
    //     //const reuslt = await LinkedListInstance.findTailId();
    //     //console.log('The tale ID is:', reuslt.toNumber());

    //     const object = await LinkedListInstance.objects(3);
    //     const next = object.next;
    //     console.log('The next:', next.toNumber());

 
    // });
    










//});