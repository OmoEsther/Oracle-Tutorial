# Oracle-Tutorial

## Introduction

One of the greatest challenges of the blockchain technology was the issue of getting access to real world data, this data is often referred to as **off-chain data** and is basically any data that is external to a blockchain, such as sports scores, weather data, price feeds etc. This issue was due to the limitation of smart contracts as they cannot inherently interact with data and systems existing outside their native blockchain environment.

![blockchain](assets/intro.png)

You may then wonder why were blockchains isolated from these external systems as obviously the external systems are well needed. Well this trade off allowed blockchains obtain their most valuable properties like strong consensus on the validity of user transactions, prevention of double-spending attacks, and mitigation of network downtime. So this issue created the need for secure interoperation with off-chain systems from a blockchain and that brings us to the topic of the tutorial **Oracles** "the bridge between the two environments".

Oracles on the blockchain are frameworks that allow for the blockchain world to interface with data from the rest of the web. They can not only give access to offchain-data but can provide a trust-minimized form of off-chain computation to extend the capabilities of blockchains like verifiable randomness, smart contract automation etc. This useful tool helped make users have countless ways to make blockchains useful in their day-to-day life.

So in this tutorial we're going to be building a simple on-chain weather oracle with solidity and node.js.

## Tech Stack

We will use the following tools and languages in this tutorial

1. Remix IDE
2. VS Code
3. A web browser
4. Node JS

## Prerequisites

- Basic knowledge of programming with Solidity
- Basic knowledge of using Remix
- Basic knowledge of javascript

## ORACLE Development

The oracle will be made up of two parts

- The on-chain oracle contract
- The off-chain oracle service

Here is a breakdown of how this two parts will combine to give us a working oracle:

1. The on-chain oracle emits an event with information about the job.

2. The off-chain oracle service listens for events about the job and pulls info when one is triggered.

3. Then the off-chain oracle interacts with any api service or data to receive result.

4. After that the off-chain oracle transacts with on-chain oracle contract to update data for the job.

5. Now the smart contract ecosystems can use the data for whatever it needs it for.

## On-chain Oracle Contract

In this section we're going to be writing two contracts, the first one being the oracle contract itself, and the second being the consumer contract which inherits the oracle contract, to test our oracle contract.

To get started, hop on to remix and create a file `OnChainOracle.sol` and open it.

Now let's define the structure of the contract. The contract will contain the following:

- the address of the off-chain oracle (this should be immutable)
- a constructor that helps us set the off-chain oracle address
- an event that triggers the off-chain oracle
- a function the consumer contract calls to make the weather request
- a function the off-chain oracle calls to supply us with the weather result.
- a nonce to help in generating a different requestID

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract OnChainOracle{

    uint256 private nonce;

    address private immutable offChainOracleAddress;

    event newRequest(uint256 requestId, int256 lat, int256 lon);

    constructor(address _offChainOracleAddress) {
        offChainOracleAddress = _offChainOracleAddress;
    }

    //function makeWeatherRequest(){}

    //function rawCompleteRequest(){}

    //function completeRequest(){}
}

```

If you look closely, you'd notice that the contract is marked as `abstract`, what this means is that we're basically telling the compiler that this contract has both defined and undefined functions.

But wait this wasn't specified in the structure of the contract. Yes it wasn't, but we'll go over it as we're defining the `rawCompleteRequest`.

let's define the `makeWeatherRequest` function;

```solidity
function makeWeatherRequest(
        uint256 _lat,
        uint256 _lon
    ) internal returns (uint256) {
        uint256 requestId = uint(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
        );
        emit newRequest(requestId, _lat, _lon);
        nonce++;
        return requestId;
    }
```

Breakdown of the function

- It takes in two parameters from the caller, the latitude and the longitude as ints so it can support negative inputs from the caller, as the range for latitudes is -90 to 90 and -180 to 180 for longitudes
- Next it generates a unique request Id, so the off-chain can be able to keep track of different requests. It uses a combination of the timestamp, caller address and the contract's nonce to generate this id. This ID is returned after the function is completed.
- Lastly it emits the trigger event so the off-chain oracle can get notified of a new requests, it sends the requestId along with the latitude and longitude. Then it increments the nonce.

Now let's define the `rawCompleteRequest` function;

```solidity
    function rawCompleteRequest(uint256 _requestId, uint256 _temp) external {
        require(msg.sender == offChainOracleAddress, "No permission");
        completeRequest(_requestId, _temp);
    }

    function completeRequest(
        uint256 _requestId,
        uint256 _temp
    ) internal virtual;
```

Recall when we made mention that the contract is marked as asbtract because it contains both defined and undefined function right? Well this is the reason why.

So we start the `rawCompleteRequest` function, this function is callable only by the off-ChainOracle address and what it does is to send the result of the request which is the temperature back to the contract. Then it calls the `completeRequest` function.

Let's just think of the `completeRequest` function like the plug-and-play devices we use at home where all we have to do is plug it in for it to work. Now say we have a consumer contract that uses our oracle, we have to assume they'd want to do something with the data gotten from the oracle, hence we have to create a way for them to just plug their contract into the oracle and from there they can manipulate the data however they want.

It is the undefined function in the oracle contract, is marked as `virtual` so that the inheriting contracts i.e. our consumers contract can then override it to define how they want to use it.

The onChain-oracle contract now looks like this;

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract OnChainOracle {
    uint256 private nonce;

    address private immutable offChainOracleAddress;

    event newRequest(uint256 requestId, int256 lat, int256 log);

    constructor(address _offChainOracleAddress) {
        offChainOracleAddress = _offChainOracleAddress;
    }

    function makeWeatherRequest(
        int256 _lat,
        int256 _lon
    ) internal returns (uint256) {
        uint256 requestId = uint(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
        );
        emit newRequest(requestId, _lat, _lon);
        nonce++;
        return requestId;
    }

    function rawCompleteRequest(uint256 _requestId, uint256 _temp) external {
        require(msg.sender == offChainOracleAddress, "Only oracle can call");
        completeRequest(_requestId, _temp);
    }

    function completeRequest(
        uint256 _requestId,
        uint256 _temp
    ) internal virtual;
}

```
