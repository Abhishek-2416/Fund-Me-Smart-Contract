// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {PriceConverter} from "./PriceConverter.sol";

error notOwner();

contract FundMe{
    using PriceConverter for uint256;

    address public immutable owner;

    //This is the minimum amount in usd which should be sent to the fund function
    //But the problem is the blockchain does not understand the value of usd or anything related to the actual world as they are determinstic systems
    //To solve this problem we use chainlink which is an oracle which helps it connect to the real world,So we use CHAINLINK DATA FEEDS
    uint256 public constant minimumUSD = 5e18;

    //Let us store all the addresses which have send us money
    address[] public funders;

    //This is to track how much the funders have sent us
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

     fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    constructor(){
        owner = msg.sender;
    }

    //This function allows a user to fund and send ETH through a function
    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUSD,"Didnt send enough ETH"); 
        funders.push(msg.sender);

        //Updating the mapping which will make sure we have track of all funds sent by the user
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner{
        //When we withdraw money we should get back all the mappings to zero to show we have withdrawed all the money
        //Resetting the mapping values
        for(uint256 i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;            
        }

        //Resetting the array funders
        funders = new address[](0);

        //Now we are transferring funds , there are 3 ways to do it 

        //using transfer function
        //There is a problem with transfer it is capped at 2300 gas if more is  used it will throw an error
        payable (msg.sender).transfer(address(this).balance);

        //using send 
        //There is a problem with transfer it is capped at 2300 gas if more is  used it will return an boolean value
        bool sendsuccess = payable (msg.sender).send(address(this).balance);
        require(sendsuccess,"Send failed");

        //using the call function
        //This is best method as it has no gas limit it takes all the gas and returns the remaning
        //It takes 2 values which is boolean and bytes calldata as it can return something when we call a function
        // (bool s, bytes memory dataReturned) = payable (msg.sender).call{value:address(this).balance}("");
        (bool s,) = payable (msg.sender).call{value:address(this).balance}("");
        require(s,"Call failed");
    }

    //Instead of writing the require statements again and again we can use function modifiers
    //The _; means that when the  rest of the code will be executed so here we first want the condition in require to check then execute the rest of the code
    modifier onlyOwner{
        if(msg.sender != owner){
            revert notOwner();
        }
        _;
    }
    
}



/*-------------------------------------------------------------NOTES--------------------------------------------------------------------------


    Every single transaction we send wil have these feilds

    Nonce - tx count for the account
    Gas Price - price per uint of gas
    Gas Limit - max gas the tx can use
    To - address that the tx is sent to
    Value - amount of wei to send
    Data - what to send to the To address
    v,r,s - components of tx signature

    The problem of oracles could also be solved by calling an API but that is not the secnario as the blockchain cannot call any api and it cannot
    reach consensus as they might call api at different time
    Instead we need a decentralised network to do it and this will return the data to our smart contract to us

----------------------------------------------------------------------------------------------------------------------------------------------*/

/*
            Basic layout

Get funds from the users
Withdraw funds
Set a minimum funding value in USD
*/


// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly