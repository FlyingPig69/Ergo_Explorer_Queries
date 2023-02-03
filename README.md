# Ergo_Explorer_Queries

Very much WIP!

Query will pull a list of addresses that are staking on ergopad. 

It's currently pulling one row per staking key, but you can pivot in excel to make a summary table.

I'll add it to the query itself when I learn how :)

EGIO,Paideia and Neta query works fine.

Ergopad query pulls in a few less tokens than expected (~10) but for the addresses I checked it's correct. It includes burnt tokens (address=NULL)

You will need access to an explorer psql instance.
