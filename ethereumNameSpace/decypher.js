// Config
global.config = {
  rpc: {
    host: "localhost",
    port: "8545"
  }
}

// Load Libraries
global.solc = require("solc")
global.EthTx = require("ethereumjs-tx")
global.EthUtil = require("ethereumjs-util")
global.fs = require("fs")
global.Web3 = require("web3")
global.lodash = require("lodash")
global.SolidityFunction = require("web3/lib/web3/function")

// Connect Web3 Instance
// global.web3 = new Web3(new Web3.providers.HttpProvider(`http://${global.config.rpc.host}:${global.config.rpc.port}`))
// global.web3 = new Web3(new Web3.providers.HttpProvider(`https://mainnet.infura.io/EjLdRlni9SfrUBEnnvVt`))
global.web3 = new Web3(new Web3.providers.HttpProvider(`https://ropsten.infura.io/EjLdRlni9SfrUBEnnvVt`))

// ENS
// global.ENS = require("ethereum-ens")
global.ENS = require("./ensutils.js")
global.ens = new ENS(global.web3)

// Global Account Accessors
// global.acct1 = web3.eth.accounts[0]
// global.acct2 = web3.eth.accounts[1]
// global.acct3 = web3.eth.accounts[2]
// global.acct4 = web3.eth.accounts[3]
// global.acct5 = web3.eth.accounts[4]

// Helper Functions
class Helpers {

  contractName(source) {
    var re1 = /contract.*{/g
    var re2 = /\s\w+\s/
    return source.match(re1).pop().match(re2)[0].trim()
  }

  createContract(source, options={}) {
    var compiled = solc.compile(source)
    var contractName = this.contractName(source)
    var bytecode = compiled["contracts"][contractName]["bytecode"]
    var abi = JSON.parse(compiled["contracts"][contractName]["interface"])
    var contract = global.web3.eth.contract(abi)
    var gasEstimate = global.web3.eth.estimateGas({ data: bytecode })

    var deployed = contract.new(Object.assign({
      from: global.web3.eth.accounts[0],
      value: global.web3.toWei(3, 'ether'),
      data: bytecode,
      gas: gasEstimate,
      gasPrice: global.web3.eth.gasPrice
    }, options), (error, result) => { })

    return deployed
  }

  loadContract(name) {
    var path = `./${name.toLowerCase()}.sol`
    return fs.readFileSync(path, 'utf8')
  }

  contractObject(name) {
    var source = this.loadContract(name)
    var compiled = solc.compile(source)
    var contractName = this.contractName(source)
    var bytecode = compiled["contracts"][contractName]["bytecode"]
    var abi = JSON.parse(compiled["contracts"][contractName]["interface"])
    var contract = global.web3.eth.contract(abi)

    return contract
  }

  deployedObject(name, address) {
    var source = this.loadContract(name)
    var compiled = solc.compile(source)
    var contractName = this.contractName(source)
    var bytecode = compiled["contracts"][contractName]["bytecode"]
    var abi = JSON.parse(compiled["contracts"][contractName]["interface"])
    var contract = global.web3.eth.contract(abi)

    return contract.at(address)
  }

  signContractCall() {
    var deployed = arguments['0'].deployed
    var methodName  = arguments['0'].methodName
    var pKeyx = arguments['0'].pKeyx
    var fromAddress = arguments['0'].fromAddress

    var args = [...arguments]; var params = args.slice(1, args.length);
    var solidityFunction = new global.SolidityFunction('', lodash.find(deployed.abi, { name: methodName }), '')
    var payloadData = solidityFunction.toPayload(params).data

    var rawTx = {
      nonce: global.web3.toHex(global.web3.eth.getTransactionCount(fromAddress)),
      gasPrice: global.web3.toHex(global.web3.eth.gasPrice),
      gasLimit: global.web3.toHex(300000),
      to: deployed.address,
      from: fromAddress,
      data: payloadData
    }

    var tx = new global.EthTx(rawTx)
    tx.sign(pKeyx)
    return tx.serialize().toString('hex')
  }

  callContract() {
    var deployed = arguments['0'].deployed
    var methodName  = arguments['0'].methodName
    var pKeyx = arguments['0'].pKeyx
    var fromAddress = arguments['0'].fromAddress

    var args = [...arguments]; var params = args.slice(1, args.length);
    var solidityFunction = new global.SolidityFunction('', lodash.find(deployed.abi, { name: methodName }), '')
    var payloadData = solidityFunction.toPayload(params).data

    var rawTx = {
      nonce: global.web3.toHex(global.web3.eth.getTransactionCount(fromAddress)),
      gasPrice: global.web3.toHex(global.web3.eth.gasPrice),
      gasLimit: global.web3.toHex(arguments['0'].gas || 300000),
      to: deployed.address,
       from: fromAddress,
      data: payloadData
    }

    var tx = new global.EthTx(rawTx)
    tx.sign(pKeyx)
    var txData = tx.serialize().toString('hex')

    global.web3.eth.sendRawTransaction(`0x${txData}`, (error, txHash) => {
      if(error) {
        console.log(`ERROR...`)
        console.log(error)
      } else {
        console.log(`TxHash...`)
        console.log(txHash)
      }
    })

    return true
  }

  deployContract(name, options={}) {
    var source = this.loadContract(name)
    return this.createContract(source, options)
  }

  etherBalance(contract) {
    switch(typeof(contract)) {
      case "object":
        if(contract.address) {
          return global.web3.fromWei(global.web3.eth.getBalance(contract.address), 'ether').toNumber()
        } else {
          return new Error("cannot call getEtherBalance on an object that does not have a property 'address'")
        }
        break
      case "string":
        return global.web3.fromWei(global.web3.eth.getBalance(contract), 'ether').toNumber()
        break
    }
  }

}

// Load Helpers into Decypher namespace
global.decypher = new Helpers()

// Start repl
require('repl').start({})