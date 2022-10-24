# Nouns Vision Batch Transfer

Allows Nouns DAO to batch transfer Nouns Vision Glasses to pods, subdaos, etc.
Deployed at [0x6ff4ff4fe59d7ec571f36e36961b032027e68cee](https://etherscan.io/address/0x6ff4ff4fe59d7ec571f36e36961b032027e68cee) on Mainnet.

## How To Use

### Nouns DAO

1. Once deployed, **Nouns DAO** must approve the `NounsVisionBatchTransfer` contract for all transfers

```
NounsVisionContract.setApprovalForAll( address(NounsVisionBatchTransfer), true)
```

2. **Nouns DAO** must add a batch transfer allowance for a **Pod**

```
NounsVisionBatchTransfer.addAllowance(POD_ADDRESS, 10);
```

### Pod

#### Gift a Single Pair of Glasses

A **Pod** can choose to leave their Nouns Vision Glasses in the possesion of Nouns DAO and only transfer a pair when they have a designated recipient (e.g. after a giveaway). When that recipient address is known:

1. The **Pod** calls the [getStartId()](https://etherscan.io/address/0x6ff4ff4fe59d7ec571f36e36961b032027e68cee#readContract#F4) view function in [Etherscan](https://etherscan.io/address/0x6ff4ff4fe59d7ec571f36e36961b032027e68cee#readContract#F4) to get the `startId` paramater to use.

2. The **Pod** initiates the transfer using the `startId` and the recipient `address`

```
NounsVisionBatchTransfer.sendGlasses(startId, address)
```

#### Gift Many Pairs of Glasses

A **Pod** can choose to leave their Nouns Vision Glasses in the possesion of Nouns DAO and only transfer pairs when they have a designated recipients (e.g. after a giveaway). When the recipients' address is known:

1. The **Pod** calls the [getStartId()](https://etherscan.io/address/0x6ff4ff4fe59d7ec571f36e36961b032027e68cee#readContract#F4) view function in [Etherscan](https://etherscan.io/address/0x6ff4ff4fe59d7ec571f36e36961b032027e68cee#readContract#F4) to get the `startId` paramater to use.

2. The **Pod** initiates the transfer using the `startId` and an array recipient `addresses` ([0xabc..., 0xdef...])

```
NounsVisionBatchTransfer.sendGlasses(startId, addresses)
```

#### Claim an Amount of Glasses

Sends an amount of Glasses to the **Pod**'s address

1. The **Pod** calls the [getStartIdAndBatchAmount()](https://etherscan.io/address/0x6ff4ff4fe59d7ec571f36e36961b032027e68cee#readContract#F5) view function in [Etherscan](https://etherscan.io/address/0x6ff4ff4fe59d7ec571f36e36961b032027e68cee#readContract#F5) with its own address to get the `startId` and `amount` parameters to use.

```
NounsVisionBatchTransfer.getStartIdAndBatchAmount(POD_ADDRESS)
=> startId, amount
```

2. The **Pod** initiates the batch transfer using the `startId` and any value up to the `amount`

3. The **Pod** can `claimGlasses` as many times as it has allowance to do so. For example, it can choose to transfer only half its allocation to save gas.

_NOTE:
**NounsVisionBatchTransfer** batches only continuous token Id transfers (i.e. 751-800). Due to transfers out of **Nouns DAO** and back in, there may not be a "continuous batch" of Nouns Vision Glasses to satisify a **Pod**'s allocation. (ie. only tokenIds 777, 888, 900-1200 may be owned by Nouns DAO at any one time). It is possible that `NounsVisionBatchTransfer.getStartIdAndBatchAmount(POD_ADDRESS)` and `NounsVisionBatchTransfer.claimGlasses(startId, amount)` may need to be called several times to transfer the allowed amount of Nouns Vision Glasses._

### Via Gnosis Safe
To use the above batch transfer function in the Gnosis Safe webapp:
1. Click on `New Transaction`
2. Click `Contract Interaction`
3. Enter `0x6ff4FF4Fe59D7EC571f36e36961B032027e68ceE` as the `Contract Address`. Gnosis Safe will fetch the ABI and populate the list of transactions. 
3. Select the function from the drop-down and enter the parameters as described above.
