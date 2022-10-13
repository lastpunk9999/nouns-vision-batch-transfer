# Nouns Vision Batch Transfer

Allows Nouns DAO to batch transfer Nouns Vision Glasses to pods, subdaos, etc.

### How To Use

1. Once deployed, **Nouns DAO** must approve the `NounsVisionBatchTransfer` contract for all transfers

```
NounsVisionContract.setApprovalForAll( address(NounsVisionBatchTransfer), true)
```

2. **Nouns DAO** must add a batch transfer allowance for a **Pod**

```
NounsVisionBatchTransfer.addAllowance(POD_ADDRESS, 10);
```

3. The **Pod** calls a view function with its own address to get the `startId` and `amount` parameters to use.

```
NounsVisionBatchTransfer.getStartIdAndBatchAmount(POD_ADDRESS)
=> startId, amount
```

4. The **Pod** initiates the batch transfer using the `startId` and any value up to the `amount`

```
NounsVisionBatchTransfer.batchTransfer(startId, amount)
```

5. The **Pod** can `batchTransfer` as many times as it has allowance to do so. For example, it can choose to transfer only half its allocation to save gas.

_NOTE:_

**NounsVisionBatchTransfer** batches only continuous token Id transfers (i.e. 751-800). Due to transfers out of **Nouns DAO** and back in, there may not be a "continuous batch" of Nouns Vision Glasses to satisify a **Pod**'s allocation. (ie. only tokenIds 777, 888, 900-1200 may be owned by Nouns DAO at any one time). It is possible that `NounsVisionBatchTransfer.getStartIdAndBatchAmount(POD_ADDRESS)` and `NounsVisionBatchTransfer.batchTransfer(startId, amount)` may need to be called several times to transfer the allowed amount of Nouns Vision Glasses.
