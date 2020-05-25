const LinkedList = artifacts.require('LinkedList');



contract('LinkedList', function(accounts) {
    it('should insert 1 to the linkedlist', async() => {
        const LinkedListInstance = await LinkedList.deployed(); 
        await LinkedListInstance.SortedInsert (1);
        await LinkedListInstance.SortedInsert (8);
        await LinkedListInstance.SortedInsert (6);
        await LinkedListInstance.SortedInsert (4);
        await LinkedListInstance.SortedInsert (10);
        
        
    });

    it('should return the id of 4', async() => {
        const LinkedListInstance = await LinkedList.deployed(); 
        const reuslt = await LinkedListInstance.findIdForData(4);
        console.log('The id of 4 is:', reuslt.toNumber());
        //const reuslt = await LinkedListInstance.findTailId();
        //console.log('The tale ID is:', reuslt.toNumber());

        const object = await LinkedListInstance.objects(3);
        const next = object.next;
        console.log('The next:', next.toNumber());

 
    });
    










});