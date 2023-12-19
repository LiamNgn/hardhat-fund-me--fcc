// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint;
    //State Variables!
    mapping(address => uint) public addressToAmountFunded;
    address[] public funders;
    address Owner;
    uint public minimumUsd = 20 * 1e18;

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        Owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    modifier onlyOwner() {
        if (msg.sender != Owner) revert FundMe_NotOwner();
        _;
    }

    function fund() public payable {
        require(
            msg.value.getConverstionRate(priceFeed) >= minimumUsd,
            "Send more ether"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        for (uint i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "call failed");
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }
}
