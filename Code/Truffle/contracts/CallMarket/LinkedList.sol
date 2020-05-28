pragma solidity >=0.4.22;

contract Node {
    Node public next;
    uint public price;
    //uint public ID;
    constructor(Node _next, uint _price) public {
        
        if (_next == Node(0)) {
            next = this;
            price = _price;
            //ID ++;
        } else {
            next = _next;
            price = _price;
            //ID ++;
        }
    }

    function addNew(Node node) public {
        //require(msg.sender == owner);
        next = node;
        //price = _price;
    }
    
}

contract linkedlist {
    Node public head;
    address public headaddress;
    
    
    
    constructor(uint _price) public {
        head = new Node(Node(0),_price );
        headaddress = head;
        
    }

    function add(Node _to, uint _price) public  {
        Node link = _to.next();
        Node next = new Node(link,_price);
        _to.addNew(next);
        


        
    }



}









    
   