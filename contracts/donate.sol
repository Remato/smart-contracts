// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct Request {
    uint id;
    address author;
    string tittle;
    string description;
    string contact;
    uint timestamp;
    uint goal; //wei
    uint balance;
    bool open;
}

contract Help {

    uint public lastId = 0;
    mapping(uint => Request) public requests;

    function openRequest(string memory _tittle, string memory _description, string memory _contact, uint _goal) public {
        lastId++;

        requests[lastId] = Request({
            id: lastId,
            tittle: _tittle,
            description: _description,
            contact: _contact,
            goal: _goal,
            balance: 0,
            timestamp: block.timestamp,
            author: msg.sender,
            open: true
        });
    }

    function closeRequest(uint id) public {
        address author = requests[id].author;
        uint balance = requests[id].balance;
        uint goal = requests[id].goal;

        //close if: is open and if balance reachs goal, or if the owner request the close.
        require(requests[id].open && (msg.sender == author || balance >= goal), "You can't close this request.");

        requests[id].open = false;

        if(balance > 0) {
            requests[id].balance = 0;
            payable(author).transfer(balance);
        }
    }

    function donate(uint id) public payable {
        require(msg.value > 0, "Invalid donation amount");

        requests[id].balance += msg.value;

        if(requests[id].balance >= requests[id].goal){
            closeRequest(id);
        }
    }


    //only read function, don't write on blockchain "view" type function
    function getOpenRequests(uint startId, uint quantity) public view returns(Request[] memory) {
        Request[] memory result = new Request[](quantity);
        uint id = 1;
        uint count = startId;

        do {
            if(requests[id].open){
                result[count] = requests[id];
                count++;
            }
            id++;
        } while(count < quantity && id <= lastId);

        return result;
    }
}
