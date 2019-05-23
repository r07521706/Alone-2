//Version6_20190521
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
        uint travelFare;
    }
    
    struct information {
        bool registered;
        bool tradable;
        bool inTransaction;
        address buyer;
        bool sellerSuccess;
        bool buyerSuccess;
        uint[] evaluation;
    }
    
    modifier participants(address addr) {
        require(accountInformation[msg.sender].buyer == addr || msg.sender == accountInformation[addr].buyer);
        _;
    }
    
    function paymentInitialize(address addr) internal {
        accountInformation[addr].inTransaction = false;
        accountInformation[addr].buyer = address(0);
        accountInformation[addr].sellerSuccess = false;
        accountInformation[addr].buyerSuccess = false;
    }
    
    function launch(string memory _name, string memory _imageLink, string memory _service, uint _price, uint _travelFare) public {
        require(accountInformation[msg.sender].inTransaction == false);
        require(_price > _travelFare);
        paymentInitialize(msg.sender);
        //Register(Record) automatically
		if(accountInformation[msg.sender].registered == false ) {
		    numberOfSeller++;
		    account[numberOfSeller] = msg.sender;
		    accountInformation[msg.sender].registered = true;
		}
		//Launch
		chicken memory _newChicken = chicken(msg.sender, _name, _imageLink, _service, _price, _travelFare);
		store[msg.sender] = _newChicken;
		accountInformation[msg.sender].tradable = true;
	}
	
	function getChickenInformation(uint num) public view returns (bool, address, string memory, string memory, string memory, uint, uint) {
        address addr = account[num];
        bool _tradable = accountInformation[addr].tradable;
        chicken memory _chicken = store[addr];
        return (_tradable, _chicken.seller, _chicken.name, _chicken.imageLink, _chicken.service, _chicken.price, _chicken.travelFare);
    }
    
    function buyChicken(address payable addr) public payable {
        require(msg.sender != addr);
        require(msg.value >= store[addr].price*(10**18));
        require(accountInformation[addr].tradable == true);
        accountInformation[addr].buyer = msg.sender;
        accountInformation[addr].tradable = false;
        accountInformation[addr].inTransaction = true;
    }
   
    function getRequest() public view returns (address) {
        require(accountInformation[msg.sender].registered == true, "You are not seller!");
        require(accountInformation[msg.sender].buyer != address(0), "No new case.");
        return accountInformation[msg.sender].buyer;
    }
    
    function transactionSuccess(address payable addr) public participants(addr) {
        require(accountInformation[msg.sender].inTransaction == true || accountInformation[addr].inTransaction == true);
        //Seller fail
        if(accountInformation[msg.sender].buyer == addr) {
            accountInformation[msg.sender].sellerSuccess = true;
            if(accountInformation[msg.sender].buyerSuccess == true) {
                msg.sender.transfer(store[msg.sender].price*(10**18));
                accountInformation[msg.sender].inTransaction =false;
            }
        }
        //Buyer fail
        if(msg.sender == accountInformation[addr].buyer) {
            accountInformation[addr].buyerSuccess = true;
            if(accountInformation[addr].sellerSuccess == true) {
                addr.transfer(store[addr].price*(10**18));
                accountInformation[addr].inTransaction = false;
            }
        }
    }
    
    function transactionFail(address payable addr) public participants(addr) {
        //Seller fail
        if(accountInformation[msg.sender].buyer == addr) {
            addr.transfer(store[msg.sender].price*(10**18));
            paymentInitialize(msg.sender);
        }
        //Buyer fail
        if(msg.sender == accountInformation[addr].buyer) {
            msg.sender.transfer((store[addr].price-store[addr].travelFare)*(10**18));
            addr.transfer(store[addr].travelFare*(10**18));
            paymentInitialize(addr);
        }
    }
    
    function evaluate(address addr, uint evaluation) public participants(addr) {
        require(evaluation>=1 && evaluation<=5);
        require(accountInformation[addr].sellerSuccess == true && accountInformation[addr].buyerSuccess == true, "Complete your transaction, please.");
        accountInformation[addr].evaluation.push(evaluation);
        paymentInitialize(addr);
    }
    
    function showEvaluation(address addr) public view returns (uint[] memory){
        return accountInformation[addr].evaluation;
    }
    
}