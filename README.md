# mirror-token-erc20

Download and Install Ganache : https://www.trufflesuite.com/ganache

Should have node.js & npm. If not, download here : https://nodejs.org/en/
Instatll Truffle with npm :
```shell
$ npm install truffle -g
```
Clone the repo to your local :
```shell
git clone https://github.com/satoshi-u/mirror-token-erc20.git
```

Open Ganache UI (can work with cli too : https://www.trufflesuite.com/ganache).
Do a QUICKSTART-ETHEREUM.
This should start a blockchain in your local. 

Now open the truffle-config.js file at project root. It will have the follwing:
development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
}
-> Now, confirm that the host and port in truffle-confiig.js is the same as in Gnaache UI -> RPC SERVER HTTP://127.0.0.1:7545 (defualt for me)

Now, you can compile the contracts (Works even without Ganache open) : 
```shell
$ truffle compile 
```

To test the contracts (Needs Ganache) :
```shell
$ truffle test
```
.

