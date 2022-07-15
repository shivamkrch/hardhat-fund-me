// Get funds from users
// Withdraw funds
// Set a minimum funding value in INR

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error FundMe__NotOwner();

/**@title A sample Funding Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 50 * 1e18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmtFunded;

    AggregatorV3Interface private s_priceFeed;

    address private immutable i_owner;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        // msg is a global keyword which contains txn data
        // msg.value contains amount of ETH sent to this contract
        // require(getConversionRate(msg.value) >= MIN_USD, "Didn't send enough ETH");
        require(msg.value.getConversionRate(s_priceFeed) >= MIN_USD, "Didn't send enough!");
        s_funders.push(msg.sender);
        s_addressToAmtFunded[msg.sender] += msg.value;
    }

    function withdraw() public payable onlyOwner {
        for(uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmtFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // transfer- max 2300 gas, throws error on fail
        // to send ETH, use payable address
        // payable(msg.sender).transfer(address(this).balance);

        // send- max 2300 gas, returns bool
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed!");

        // call- forward all gas or set gas, returns bool
        (bool callSuccess, ) = i_owner.call{ value: address(this).balance }("");
        require(callSuccess, "Call failed!");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for(uint256 i=0;i<funders.length;i++){
           address funder = funders[i];
           s_addressToAmtFunded[funder]=0; 
        }
        s_funders=new address[](0);

        (bool callSuccess, ) = i_owner.call{ value: address(this).balance }("");
        require(callSuccess, "Call failed!");
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getOwner() public view returns(address){
        return i_owner;
    }

    function getFunder(uint256 index) public view returns(address){
        return s_funders[index];
    }

    function getAmtFundedForAddress(address funder) public view returns(uint256){
        return s_addressToAmtFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface){
        return s_priceFeed;
    }
}