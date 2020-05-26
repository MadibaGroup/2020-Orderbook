pragma solidity >=0.4.22;

// contract LinkedList_V2 {
    
//     Node public head = new Node(0);
//     uint public x;
    
    
//     function insert(uint _price) public returns (bool){
        
    
//         Node  new_node = new Node(_price); 
//         //new_node.next.price = 0; 
//         // Create a new node with given data 
//         //head = new_node; 
        
//         if (head.price() == 0) { 
//             head = new_node; 
//         } 
//         else { 
//             // Else traverse till the last node 
//             // and insert the new_node there 
//             Node last = new Node(0);
//             last = head;
            
            
            
//             Node next = new Node(0);

//             next.setnext(last.next());
//             //next.replacenodes(last.next());
            
//             //x = next.price();
            
//             //x = next.price();
//             //last = head; 
//             //Node last_Next = new Node (last.next());

            



//             while (next.price() != 0) { 
//                 //x =2;

//                 last = next;
//                 next.setnext(last.next());
                
//             } 
            
//             // // // Insert the new_node at last node 
            
//             // // last.next = new_node;
//             // next.setnext(new_node); 
//             // x = next.price();
            
//         //last.next = new_node; 

            
            
//             next = new_node;
//             x = next.price();
//         } 
//         return true; 
//     } 

//     // function get() public returns (uint _price){

//     // Node currNode = head; 
//     // uint amount = uint(currNode.price);
//     // return amount;
//     // }

//     function printhead() public view returns (uint, Node, uint)
//     { 
//          Node currNode = head; 
//          return (currNode.price(), currNode.next(), x);
        
        
//     } 

//     function printlist() public returns (uint)
//     //public static void printList(LinkedList list) 
//     { 
//         Node currNode = head; 
//         //uint[] prices;

//         //System.out.print("LinkedList: "); 
   
//         // Traverse through the LinkedList 
//         //while (currNode.price() != 0) { 
//             // Print the data at current node 
//             //prices.push(currNode.price());
//             // Go to next node 
        
//         //Node next = new Node(0);
//         currNode.setnext(currNode.next());

//         //} 
        
//         return currNode.price();

         
          
//     } 



// }

// contract Node {


//     uint public price;
//     Node public next;
//     //bool public isInitiallized;

//     constructor (uint _price) public{
//         price = _price;
//         //isInitiallized = true;
//         //next = _next; 
//     }

//     function setnext (Node _next) public returns (bool){
        
//       //price =  _next.price();
//       next = _next;


//     }
//     function replacenodes (Node _replacor) public returns (bool){
        
//       price =  _replacor.price();
//       next = _replacor.next();


//     }


// }





import "./Node.sol";

contract LinkedList_V2 {
    Node public head;

    constructor() public {
        head = new Node(Node(0));
    }

    function add(Node _to) public {
        Node link = _to.next();
        Node next = new Node(link);
        _to.addNew(next);
    }
}





