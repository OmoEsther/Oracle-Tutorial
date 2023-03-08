# Oracle-Tutorial

## Introduction

One of the greatest challenges of the blockchain technology was the issue of getting access to real world data, this data is often referred to as **off-chain data** and is basically any data that is external to a blockchain, such as sports scores, weather data, price feeds etc. This issue was due to the limitation of smart contracts as they cannot inherently interact with data and systems existing outside their native blockchain environment.

![blockchain](assets/intro.png)

You may then wonder why were blockchains isolated from these external systems as obviously the external systems are well needed. Well this trade off allowed blockchains obtain their most valuable properties like strong consensus on the validity of user transactions, prevention of double-spending attacks, and mitigation of network downtime. So this issue created the need for secure interoperation with off-chain systems from a blockchain and that brings us to the topic of the tutorial **Oracles** "the bridge between the two environments".

Oracles on the blockchain are frameworks that allow for the blockchain world to interface with data from the rest of the web. They can not only give access to offchain-data but can provide a trust-minimized form of off-chain computation to extend the capabilities of blockchains like verifiable randomness, smart contract automation etc. This useful tool helped make users have countless ways to make blockchains useful in their day-to-day life.

So in this tutorial we're going to be building a simple blockchain oracle from scratch. Our oracle is going help us to get access to price of any token against the US dollar.

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

The oracle with be made up of two parts

- The on-chain oracle contract
- The off-chain oracle

Here is a breakdown of how this two parts will combine to give us a working oracle:

1. The on-chain oracle emits an event with information about the job.

2. The off-chain oracle service listens for events about the job and pulls info when one is triggered.

3. Then the off-chain oracle interacts with any api service or data to receive result.

4. After that the off-chain oracle transacts with on-chain contract to update data for the job.

5. Now the smart contract ecosystems can use the data for whatever it needs it for.
