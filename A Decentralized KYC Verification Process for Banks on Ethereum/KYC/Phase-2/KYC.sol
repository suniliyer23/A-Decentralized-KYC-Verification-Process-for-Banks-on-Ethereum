pragma solidity ^0.6.9;
 
contract KYCContract {
    address admin;
 
    /*
    Struct for a customer
     */
    struct Customer {
        bytes32 userName; //unique
        string data_hash; //unique
        uint256 rating;//
        //bool kycStatus;
        uint8 upvote; //need to add downvotes,kyc status
        uint8 downvote;
        address bank;
    }
 
    /*
    Struct for a Bank
     */
    struct Bank {
        string bankName;
        address ethAddress; //unique
        uint256 rating;
        uint256 kyc_count;
        string regNumber;//unique
        uint256 complaintsReported;
        bool isAllowedtoVote;
 
 
    }
 
    /*
    Struct for a KYC Request
     */
    struct KYCRequest {
        bytes32 userName;
        string data_hash; //unique
        address bank;
        bool isAllowed;
    }
 
    /*
    Mapping a customer's username to the Customer struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(bytes32 => Customer) customers;
    bytes32[] customerNames;
 
    /*
    Final customer list, mapping of customer's username to the customer Struct
    */
    mapping(bytes32 => Customer) final_customers;
    bytes32[] final_customerNames;
 
    /*
    Mapping a bank's address to the Bank Struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(address => Bank) banks;
    address[] bankAddresses;
 
    /*
    Mapping a customer's Data Hash to KYC request captured for that customer.
    This mapping is used to keep track of every kycRequest initiated for every customer by a bank.
     */
    mapping(bytes32 => KYCRequest) kycRequests;
    bytes32[] customerDataList;
 
    /*
    Mapping a customer's user name with a bank's address
    This mapping is used to keep track of every upvote given by a bank to a customer
     */
    mapping(bytes32 => mapping(address => uint256)) upvotes;
    mapping(bytes32 => mapping(address => uint256)) downvotes;
 
    /**
     * Constructor of the contract.
     * We save the contract's admin as the account which deployed this contract.
     */
    constructor() public {
        admin = msg.sender;
    }
 
    /**
     * Record a new KYC request on behalf of a customer
     * The sender of message call is the bank itself
     * @param  {string} _userName The name of the customer for whom KYC is to be done
     * @param  {address} _bankEthAddress The ethAddress of the bank issuing this request
     * @return {bool}        True if this function execution was successful
     */
    function addKycRequest(bytes32 _userName, string memory _customerData)
        public
        returns (uint8)
    {
        // Check that the user's KYC has not been done before, the Bank is a valid bank and it is allowed to perform KYC.
 
        //checking if the bank is a valid Bank
 
        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (msg.sender == bankAddresses[i]) {
                //checking if the customer KYC request alreay exist
                require(
                    !(kycRequests[_userName].bank == msg.sender),
                    "This user already has a KYC request with same data in process."
                );
                kycRequests[_userName].data_hash = _customerData;
                kycRequests[_userName].userName = _userName;
                kycRequests[_userName].bank = msg.sender;
                kycRequests[_userName].isAllowed = true;
                //incrementing the kyc_count for the bank
                banks[msg.sender].kyc_count++;
 
                //checking if the BANK is a trusted bank to add KYC requests
                if (banks[msg.sender].rating <= 50) {
                    kycRequests[_userName].isAllowed = false;
                } else {
                    kycRequests[_userName].isAllowed = true;
                }
                customerDataList.push(_userName);
                return 1;
            }
        }
        return 0; // 0 is returned in case of failure
    }
  /**
     * Add a new customer
     * @param {string} _userName Name of the customer to be added
     * @param {string} _hash Hash of the customer's ID submitted for KYC
     */
    function addCustomer(bytes32 _userName, string memory _customerData)
        public
        returns (uint8)
    {
        //checking if the bank is a vaild Bank
        for (uint256 i = 0; i < bankAddresses.length; i++) {
            if (msg.sender == bankAddresses[i]) {
 
                require(customers[_userName].userName == _userName, "error");
                customers[_userName].userName = _userName;
                customers[_userName].data_hash = _customerData;
                customers[_userName].bank = msg.sender;
                customers[_userName].upvote = 0;
                customerNames.push(_userName);
                return 1;
 
                //checking if the customerdata hash is valid
                // for (uint256 k = 0; k < customerDataList.length; k++) {
                //     if (customerDataList[k] == _customerData) {
                //         require(
                //             customers[_userName].bank == address(0),
                //             "This customer is already present, modifyCustomer to edit the customer data"
                //         );
                //         require(
                //             kycRequests[_userName].isAllowed == true,
                //             "isAllowed is false, bank is not trusted to perfrom the transaction"
                //         );
                //         customers[_userName].userName = _userName;
                //         customers[_userName].data_hash = _customerData;
                //         customers[_userName].bank = msg.sender;
                //         customers[_userName].upvote = 0;
                //         customerNames.push(_userName);
                //         return 1;
                //     }
                // }
            }
        }
        return 0; // 0 is returned in case of failure
    }
 
 
 /**
     * Remove KYC request
     * @param  {string} _userName Name of the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function removeKYCRequest(
        bytes32 _userName
       // string memory customerData,
    ) public returns (uint8) {
        uint8 i = 0;
        uint256 length = customerDataList.length;
        //checking if the provided username and customer Data are mapped in kycRequests
        require(kycRequests[_userName].userName == _userName,"Please enter valid UserName and Customer Data Hash");
 
        //looping through customerDataList and then deleting the kycRequests and deleting the customer data hash from customerDataList array
        for (i = 0; i < length; i++) {
            if (customerDataList[i] == _userName) {
                delete kycRequests[_userName];
                for (uint256 j = i + 1; j < length; j++) {
                    customerDataList[j - 1] = customerDataList[j];
                }
                length--;
                return 1;
            }
        }
        return 0; // 0 is returned if no request with the input username is found.
    }
/**
     * View customer information
     * @param  {public} _userName Name of the customer
     * @return {Customer}         The customer struct as an object
     */
    function viewCustomer(bytes32 _userName)
        public
        view
        returns (bytes32)
    {
        //looping through customerNames to check if the _userName passes is valid
        return customers[_userName].userName;
        //for (uint256 i = 0; i < customerNames.length; i++) {
            //if (stringsEquals(customerNames[i], _userName)) {
                //looping through passwordSet array, which is an string[] stores USERNAME's of user whose password is set
 
 
           // }
        //}
        //passwordStore is a mapping of username=>password, if given username and password match we return customer data hash
        //else error is thrown informing user that password provided didn't match
 
 
    }
 
 /**
     * Add upvote to provide ratings on customers
     * Add a new upvote from a bank
     * @param {public} _userName Name of the customer to be upvoted
     */
    function upvoteCustomer(bytes32 _userName) public returns (uint8) {
        //checking if the customer exist in the customerNames
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (customerNames[i] == _userName) {
                require(
                    upvotes[_userName][msg.sender] == 0,
                    "This bank have already upvoted this customer"
                );
                upvotes[_userName][msg.sender] = 1;
                customers[_userName].upvote++;
 
                //updating the rating of the customer
                customers[_userName].rating =
                    (customers[_userName].upvote * 100) /
                    bankAddresses.length;
                //if the customer rating is higher then also adding the customer to the final_customers list.
                if (customers[_userName].rating > 50) {
                    final_customers[_userName].userName = _userName;
                    final_customers[_userName].data_hash = customers[_userName]
                        .data_hash;
                    final_customers[_userName].rating = customers[_userName]
                        .rating;
                    final_customers[_userName].upvote = customers[_userName]
                        .upvote;
                    final_customers[_userName].bank = customers[_userName].bank;
                    //final_customerNames is array to itterate over customers
                    final_customerNames.push(_userName);
                }
 
                return 1;
            }
        }
        return 0;
    }
 
 
    /**
     * Add Downvote to provide ratings on customers
     * Add a new Downvote from a bank
     * @param {public} _userName Name of the customer to be upvoted
     */
    function downvoteCustomer(bytes32 _userName) public returns (uint8) {
        //checking if the customer exist in the customerNames
        for (uint256 i = 0; i < customerNames.length; i++) {
            if (customerNames[i] == _userName) {
                require(
                    downvotes[_userName][msg.sender] == 0,
                    "This bank have already downvoted this customer"
                );
                downvotes[_userName][msg.sender] = 1;
                customers[_userName].downvote++;
 
                //updating the rating of the customer
                customers[_userName].rating =
                    (customers[_userName].downvote * 100) /
                    bankAddresses.length;
                //if the customer rating is higher then also adding the customer to the final_customers list.
                if (customers[_userName].rating > 50) {
                    final_customers[_userName].userName = _userName;
                    final_customers[_userName].data_hash = customers[_userName]
                        .data_hash;
                    final_customers[_userName].rating = customers[_userName]
                        .rating;
                    final_customers[_userName].downvote = customers[_userName]
                        .downvote;
                    final_customers[_userName].bank = customers[_userName].bank;
                    //final_customerNames is array to itterate over customers
                    final_customerNames.push(_userName);
                }
 
                return 1;
            }
        }
        return 0;
    }
 
 
 
 
    // update customerData
    function modifyCustomer(bytes32 userName, string memory _customerData, address _bank) public{
        require(customers[userName].bank != address(0) );
        customers[userName].data_hash = _customerData;
        customers[userName].bank = _bank;
 
 
    }
 
    //get bank complaint
 
    function getbankComplaint(address bankAddress )
        public
        view
        returns (uint256)
    {
        //looping through customerNames to check if the _userName passes is valid
        return banks[bankAddress].complaintsReported;
    }
 
      /*
	viewBankDetail
	*/
 
     function viewBankDetail(address bankAddress)
         public
         view
         returns (
             string memory,
             uint256,
             uint256,
             string memory
         )
        {
         //checking if bank exist
        return (banks[bankAddress].bankName,banks[bankAddress].kyc_count,banks[bankAddress].complaintsReported,banks[bankAddress].regNumber);
     }
 
 
  function reportBank(address _bank) public {
        require(banks[msg.sender].ethAddress == msg.sender, "You are not authorised to report the bank");
        banks[_bank].complaintsReported = banks[_bank].complaintsReported + 1;
        if (banks[_bank].complaintsReported > 1000){
            banks[_bank].isAllowedtoVote = false;
        }
    }
 
 
 
 
 
 
 /*
	Add Bank to the smart contract
	add bank = bank can only be added by the admin
	admin = account which is deploying smart contract
    mapping to store bankRegistration => bank address
    mapping(string => address) bankRegStore;
	*/
    function addBank(
        string memory bankName,
        address bankAddress,
        string memory bankRegistration
    ) public returns (string memory) {
        //checking if the account used to perform add operation is an Admin
        require(msg.sender == admin, "You are not an admin");
        require(
            banks[bankAddress].ethAddress == address(0),
            "This bank is already added to the samrt contract"
        );
        //making sure that the registration number is unique
       // require(
           // bankRegStore[bankRegistration] == address(0),
          // "This Registration number is already assocaited with another bank"
        //);
        //adding bank
        banks[bankAddress].bankName = bankName;
        banks[bankAddress].ethAddress = bankAddress;
        banks[bankAddress].rating = 0;
        banks[bankAddress].kyc_count = 0;
        banks[bankAddress].regNumber = bankRegistration;
 
        bankAddresses.push(bankAddress);
       // bankRegStore[bankRegistration] = bankAddress;
        return "successful entry of bank to the contract";
    }
 
/*
	Remove Bank from the smart contract
	remove bank = bank can only be removed by the admin
	admin = account which is deploying smart contract
    */
    function removeBank(address bankAddress) public returns (string memory) {
        //checking if the account used to perform remove operation is an Admin
        require(msg.sender == admin, "You are not an admin");
        uint256 length = bankAddresses.length;
        for (uint256 i = 0; i < length; i++) {
            if (bankAddresses[i] == bankAddress) {
                delete banks[bankAddress];
                for (uint256 j = i + 1; j < length; j++) {
                    bankAddresses[j - 1] = bankAddresses[j];
                }
                length--;
                return "successful removal of the bank from the contract.";
            }
        }
 
        return "The bank is already removed from the contract";
    }
 
 
 
function updateBankData(address bankAddress, bool _isAllowedtoVote) public {
        require(admin == msg.sender, "You are not allowed to Add Bank");
        require(banks[bankAddress].ethAddress == bankAddress, "Bank is not available in the bank list");
        banks[bankAddress].isAllowedtoVote = _isAllowedtoVote;
    }
 
}
