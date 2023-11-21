# REDUCE GAS USAGE OF DISTRIBUTE SMART CONTRACT

The goal of this analysis and the code refactoring of the smart contract `Distribute.sol` is a reduction of the gas usage (gas optimization) and eliminate some security flaws.

Please check the new version of _Distribute.sol [here](https://github.com/ivanmolto/dist-gas-optimization/blob/main/Distribute.sol) in the repo.

[X] **Gas Optimization** A transition from using `require()` to use a `revert()` with a _custom error_ optimizes the gas usage of the smart contract.
My approach is going from `require( block.timestamp > createTime + 2 weeks, "cannot call distribute yet");` to `revert NoDistributionYet();` stripping the string literal.

[] **Best Practice** Not to use of `block.timestamp` for comparisons as it can be manipulated by miners. 
We would need to avoid relying on `block.timestamp` but as it doesn't affect the smart contract because it is not a source of randomness and does not help with gas optimization I have decided to keep it .
`block.timestamp > createTime + 2 weeks`

[X] **Best Practice** It is not recommended for deployment using a pragma version with an old version `solc-08.15`. Using an old version prevents the access to new new Solidity security checks.
I decided to go from `pragma solidity 0.8.15;` to `pragma solidity 0.8.18;`

[X] **Gas Optimization** A state variable that is not updated following the deployment as `createTime` should be immutable.

[X] **Gas Optimization and security flaw**
The following lines of the smart contract are an exploit scenario `transfer()` unprotected calls sending ETH.
In a way that arbitrary senders other than the contract creator could potentially extract Ether from the smart contract [SWC-105].
```
payable(contributors[0]).transfer(amount);
payable(contributors[1]).transfer(amount);
payable(contributors[2]).transfer(amount);
payable(contributors[3]).transfer(amount);
payable(contributors[4]).transfer(amount);
payable(contributors[5]).transfer(amount);
```

To fix it we will need to ensure that a malicious user cannot withdraw unauthorized funds.

On the other hand this code snippet is also a gas bottleneck for using `transfer()` instead of `call()`.
As multiple calls are executed in the same transaction. It is possible that some calls never get executed if a prior call fails permanently [SWC-113].

[X] **Gas Optimization**
Used ++i (unchecked) instead of for loop i++ in the new version of _Distribute.sol_


And finally, the model of distribution.
The new _Distribute.sol_ contract allows to split Ether payments amoung a group of contributors. 
The split can be in any arbitrary proportion and so it supports the old distribution model. 

The way this is specified is by assigning each contributor to a number of shares. Each contributor will then be able to claim an amount proportional to the percentage of total shares.

It follows a pull payment model. 






