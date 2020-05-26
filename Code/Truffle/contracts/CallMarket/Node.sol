pragma solidity >=0.4.22;

contract Node {
    Node public next;
    address owner;

    constructor(Node _next) public {
        owner = msg.sender;
        if (_next == Node(0)) {
            next = this;
        } else {
            next = _next;
        }
    }

    function addNew(Node node) public {
        //require(msg.sender == owner);
        next = node;
    }
}