//Version5_20190509
pragma solidity ^0.5.0;

contract ChickenStore {
    
    //Store Management
    uint public numberOfSeller = 0; 
    mapping(address => chicken) store;
    mapping(uint => address) account;
    mapping(address => information) accountInformation;

    struct chicken {
        address seller;
        string name;
        string imageLink;
        string service;
        uint price;
    }
    
    struct information {
        bool register;
        bool tradable;
        address buyer;
        bool buyerSuccess;
        bool sellerSuccess;
    }
    
    function paymentInitialize(address addr) internal {
        accountInformation[addr].buyer = address(0);
        accountInformation[addr].buyerSuccess = false;
        accountInformation[addr].sellerSuccess = false;
    }
    
    function launch(string memory _name, string memory _imageLink, string memory _service, uint _price) public {
        //Register(Record) automatically
		if(accountInformation[msg.sender].register == false ) {
		    numberOfSeller++;
		    account[numberOfSeller] = msg.sender;
		    accountInformation[msg.sender].register = true;
		}
		//launch
		chicken memory _newChicken = chicken(msg.sender, _name, _imageLink, _service, _price);
		store[msg.sender] = _newChicken;
		accountInformation[msg.sender].tradable = true;
	}
	
	function getChickenInformation(uint num) public view returns (bool, address, string memory, string memory, string memory, uint) {
        address addr = account[num];
        bool _tradable = accountInformation[addr].tradable;
        chicken memory _chicken = store[addr];
        return (_tradable, _chicken.seller, _chicken.name, _chicken.imageLink, _chicken.service, _chicken.price);
    }
    
    function buyChicken(address payable addr) public payable {
        require(msg.sender != addr);
        require(msg.value >= store[addr].price*(10**18));
        require(accountInformation[addr].tradable == true);
        accountInformation[addr].buyer = msg.sender;
        accountInformation[addr].tradable = false;
    }
   
    function getRequest() public view returns (address) {
        require(accountInformation[msg.sender].register == true, "You are not seller!");
        require(accountInformation[msg.sender].buyer != address(0), "No new case.");
        return accountInformation[msg.sender].buyer;
    }
    
    function transactionSuccess(address payable addr) public {
        require(msg.sender == accountInformation[addr].buyer || accountInformation[msg.sender].buyer == addr);
        if(msg.sender == accountInformation[addr].buyer) {
            accountInformation[addr].buyerSuccess = true;
            if(accountInformation[addr].sellerSuccess == true) {
                addr.transfer(store[addr].price*(10**18));
                paymentInitialize(addr);
            }
        }
        if(accountInformation[msg.sender].buyer == addr) {
            accountInformation[msg.sender].sellerSuccess = true;
            if(accountInformation[msg.sender].buyerSuccess == true) {
                msg.sender.transfer(store[msg.sender].price*(10**18));
                paymentInitialize(msg.sender);
            }
        }
    }
    
    function transactionFail(address payable addr) public {
        require(msg.sender == accountInformation[addr].buyer || accountInformation[msg.sender].buyer == addr);
        if(msg.sender == accountInformation[addr].buyer) {
            msg.sender.transfer(store[addr].price*(10**18));
            paymentInitialize(addr);
        }
        if(accountInformation[msg.sender].buyer == addr) {
            addr.transfer(store[msg.sender].price*(10**18));
            paymentInitialize(msg.sender);
        }
    }
    
}