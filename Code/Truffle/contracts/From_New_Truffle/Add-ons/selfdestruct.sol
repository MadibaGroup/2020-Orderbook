pragma solidity >=0.4.22;
contract selfdestruct {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    function destroy() onlyOwner public {
        selfdestruct(owner);
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}