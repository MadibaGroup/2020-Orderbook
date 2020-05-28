pragma solidity >=0.4.22;


contract Linkedlist {
    Item public head;
    address[] public newItems;

    constructor() public {
        head = new Item(Item(0));
        newItems.push(address(head));
    }

    function add(Item _to) public {
        Item link = _to.next();
        Item next = new Item(link);
        _to.addNew(next);
        newItems.push(address(next));
        
    }
}



contract Item {
    Item public next;
    address owner;

    constructor(Item _next) public {
        owner = msg.sender;
        if (_next == Item(0)) {
            next = this;
        } else {
            next = _next;
        }
    }

    function addNew(Item item) public {
        require(msg.sender == owner);
        next = item;
    }
}

