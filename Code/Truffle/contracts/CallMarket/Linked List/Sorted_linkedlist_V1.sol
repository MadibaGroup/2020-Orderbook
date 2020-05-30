pragma solidity >=0.4.22;


contract Sorted_linkedlist_V1{
    Item public head;
    address[] public newItems;
    //Item public item;
    uint public j;
    bool public i;


    constructor(uint _data) public {
        head = new Item(Item(0), _data);
        newItems.push(address(head));
    }

    function add(uint _data) public returns (bool){


        /*if (head.data() < _data){ //replace head with the new node

            Item link = head.next();
            Item previoushead = new Item(link, head.data());

            head = new Item (head, _data);
            newItems.push(address(head));

        }*/
        if(head.next() == head) {
            Item link = head.next();
            Item next = new Item(link, _data);
            link.addNew(next);
            newItems.push(address(next));
            i = false;
            return true;

        }


        Item link = head.next();
        while (link.data() != 0 && link.data() > _data)
        {
            //i = true;
            //uint sec_data = link.data();
            //uint found = 0;
            //Item T2 = new Item (head, head.data());


            link.addNew(link.next());
            link.replacedata(link.next().data());

        }

        Item link2 = link.next();
        Item next = new Item(link2, _data);
        link2.addNew(next);

        newItems.push(address(next));

        i = false;







        return true;


    }








}









contract Item {
    Item public next;
    uint public data;
    uint public returndata;

    constructor(Item _next, uint _data) public {

        if (_next == Item(0)) {
            next = this;
            data = _data;
        } else {
            next = _next;
            data = _data;
        }
    }

    function addNew(Item item) public {

        next = item;

    }

    function replacedata ( uint _data) public {
        data = _data;

    }

    function getdata (Item item) public returns (uint){

        returndata = item.data();
        return returndata;

    }











}
