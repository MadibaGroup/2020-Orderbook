pragma solidity >=0.4.22;

contract Node {
    Node public next;
    uint public price;
    uint public ID;
    constructor(Node _next, uint _price) public {
        
        if (_next == Node(0)) {
            next = this;
            price = _price;
            ID ++;
        } else {
            next = _next;
            price = _price;
            ID ++;
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
    address public nextnode;
    address public headnodeaddress;
    uint public headprice;
    uint public nextprice;
    
    
    constructor(uint _price) public {
        head = new Node(Node(0),_price );
        headnodeaddress = address(head);
        headprice = head.price();
        
    }

    function add(Node _to, uint _price) public returns (address) {
        Node link = _to.next();
        Node next = new Node(link,_price);
        _to.addNew(next);
        nextnode = address(next);
        headprice = head.price();
        nextprice = next.price();
        //return nextnode;
        
        Node last = head; 
            while (last.next().price()!= 0) { 
                last = last.next(); 
            } 
  
            // Insert the new_node at last node 
            last.next = new_node; 
        
        
        
        
        //address _link = address(link);
        //address _next = address(next);
        //return (_link, _next);


        
    }

    function getheadprice(Node _head) public returns (uint){

        return _head.ID();
    }

    function getnextprice() public returns (uint){

        return (nextprice);
    }



}









    
   