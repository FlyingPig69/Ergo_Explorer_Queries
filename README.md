# Ergo Explorer Queries

Right now there's only one query, extracting staked amount in Ergopad contracts. 

You will need access to an Explorer instance to connect to DB.

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


