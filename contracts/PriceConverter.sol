// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//Importing the interface to access the function and not use the ABI
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    function getPrice() internal view returns(uint256){
        //Now if we have to go reach out to the contract and acccess it we need 2 things that is its ADDRESS and ABI
        //We can get the address from chainlink 0x694AA1769357215DE4FAC081bf1f309aDC325306 this is the address
        //Now to get the ABI we could import the whole contract and simply get the ABI but that is tedious so we use interface
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //In the interface contract we can see it returns a number of things, but as we just need the price we can leave out the others
        (,int256 price,,,) = priceFeed.latestRoundData();

        //This variable price will now return the price of ETH in USD with 8 decimal places as we can check from the decimal() function
        return uint256(price*1e10);
    }

    //Now as we have a function which will give us the price of ethereum in usd now lets convert the msg.val to USD
    function getConversionRate(uint256 ethAmount)internal view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }

}

/*
Libraries are similar to contracts but you can't declare any state variable and can't send any ether
A library is embedded into a contract if all the functions are internal
Otherwise the library must be deployed and then linked before the contract is deployed
*/