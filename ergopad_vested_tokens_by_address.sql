/** Extracts all ergopad vesting keys, original vested amounts and what i left to claim **/

select distinct on (node_outputs.additional_registers::json->'R5'->> 'renderedValue')
nu.name as Vesting_Key_Name,
/** node_outputs.additional_registers::json->'R5'->> 'renderedValue' as vesting_key_id, **/
noa.address,
CAST(na.Vested_Amount as float) / CAST(RPAD('1',tokens.decimals+1, '0') AS Float) as Vested_Amount,
nu.Original_Amount,
TO_DATE(replace(left(trim(both '"' from cast(nu.vestTime as VARCHAR)),10),'-',''),'YYYYMMDD') as vesting_Start_date,
nu.periods,
trim(leading '"' from trim(trailing ' day(s)"' from cast(nu.period_length as VARCHAR))) as period_length

From node_outputs

/* find all active vesting key ids and current wallet address and join on vesting contracts box register (R5) from contract box. */
left join lateral (
  select
  o.address,
  o.box_id,
  a.token_id
  from node_outputs o
  left join node_inputs i on o.box_id = i.box_id and i.main_chain = true
  left join node_assets a on o.box_id = a.box_id 
  where a.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'
    and i.box_id is null
    and o.main_chain = true
	) noa on noa.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'

/* Find amount of tokens stored in contract box */
left join lateral (
	select distinct on (node_assets.index, node_assets.token_id, node_assets.box_id)
   	node_assets.value as Vested_Amount,
	node_assets.token_id,
	node_assets.box_id
  from node_assets
  inner join tokens t on node_assets.token_id = t.token_id
  where node_assets.box_id = node_outputs.box_id
) na on node_outputs.box_id = na.box_id 

/* find token decimals */
join tokens on (tokens.token_id = na.token_id)

/* Find staking key ID from contract and extract description */
left join lateral (
	select 
	tokens.box_id,
	tokens.token_id,
	tokens.name,
	tokens.description::json->'Total vested' as Original_Amount,
	tokens.description::json->'Vesting start' as vestTime,
	tokens.description::json->'Periods' as periods, 
	tokens.description::json->'Period length' as period_length
	
	from tokens
	where tokens.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'
) nu on nu.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'

where node_outputs.address = 'HNLdwoHRsUSevguzRajzvy1DLAvUJ9YgQezQq6GGZiY4TmU9VDs2ae8mRpQkfEnLmuUKyJibZD2bXR2yoo1p8T5WCRKPn4rJVJ2VR2LvRBk8ViCmhcume5ubWaySXTUqpftEaaURTM6KSFxe4QbRFbToyPzZ3JJmjoDn4WzHh5ioXZMj7AX6xTwJvFmzPuko9BqDk5z1RJtD1wP4kd8sSsLN9P2YNQxmUGDEBYHaDCoAhY7Pg5oKit6ZyqMynoiycWqctfg1EHhMUKCTJsZNnidU961ri98RaYP4CfEwYQ3d9dRVuC6S1n7J1wPPHYqmUBgJCGWbTULayXUowSSmRuZUkQYGo9vvNaEpB7ManiLsX1n8cBYwN4XoVsY24mCfptBP86P4rZ5fgcr9mYtQ9nG934DMDZBbjs81VzCupB6KVrGCe1WtYSr6c1DwkNAinBMwqcqxTznXZUvfBsjDSCtJzCut44xcc7Zsy9mWz2B2pqhdKsX83BVzMDDM5hnjXTShYfauJGs81'
and not exists (select box_id from node_inputs where node_inputs.box_id = node_outputs.box_id)

order by 
node_outputs.additional_registers::json->'R5'->> 'renderedValue',
node_outputs.creation_height
desc
