# Ergo Explorer Queries



Requirements:
* You will need access to an Explorer instance to connect to DB.
 (You can use https://github.com/abchrisxyz/ergo-setup)
* PGAdmin or similar to run the sqls.

**Total Value Locked by Smart Contract**:
Shows all smart contracts (I think.....) with their amount of ERG plus USD value plus the following tokens:
1. SigUSD
2. SPF
3. NETA
4. Ergopad
5. EGIO
6. Paideia

It's easy to add more which I'll do at a later date...

Most contracts are unknown, if you know what some of the contracts are, let me know :)

**Staked Ergopad/Paidea Contracts by address:**:

Query will pull a list of addresses in all Ergopad staking contracts:
  1. Token ID
  2. Wallet Address
  3. Current Staked Amount
  4. Original/Initial staked amount
  5. Initial Stake date

It's currently one row per staking key and many addresses have multiple keys.
Use excel to pivot and analyze by address. 

Known Issue:

Ergopad query pulls in a few less tokens than expected (~10) but for the addresses I checked it's correct. 
It includes burnt tokens (address=NULL)


