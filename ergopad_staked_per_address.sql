select distinct on (node_outputs.additional_registers::json->'R5'->> 'renderedValue')
node_outputs.additional_registers::json->'R5'->> 'renderedValue' as Vesting_Token_id,
nu.name,
noa.address,
na.staked_amount / 100 as Staked_Amount,
nu.box_id as VestingKey_box_id,
node_outputs.box_id as contract_box_id,
node_outputs.creation_height

From node_outputs

left join lateral (
	select distinct on (node_assets.index, node_assets.token_id, node_assets.box_id)
    node_assets.value as Staked_Amount,
	node_assets.token_id,
	node_assets.box_id
  from node_assets
  inner join tokens t on node_assets.token_id = t.token_id
  where node_assets.box_id = node_outputs.box_id
  and t.name = 'ergopad'
) na on node_outputs.box_id = na.box_id 

left join lateral (
	select 
	tokens.box_id,
	tokens.token_id,
	tokens.name
	from tokens
	where tokens.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'
) nu on nu.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'

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

where node_outputs.address = '3eiC8caSy3jiCxCmdsiFNFJ1Ykppmsmff2TEpSsXY1Ha7xbpB923Uv2midKVVkxL3CzGbSS2QURhbHMzP9b9rQUKapP1wpUQYPpH8UebbqVFHJYrSwM3zaNEkBkM9RjjPxHCeHtTnmoun7wzjajrikVFZiWurGTPqNnd1prXnASYh7fd9E2Limc2Zeux4UxjPsLc1i3F9gSjMeSJGZv3SNxrtV14dgPGB9mY1YdziKaaqDVV2Lgq3BJC9eH8a3kqu7kmDygFomy3DiM2hYkippsoAW6bYXL73JMx1tgr462C4d2PE7t83QmNMPzQrD826NZWM2c1kehWB6Y1twd5F9JzEs4Lmd2qJhjQgGg4yyaEG9irTC79pBeGUj98frZv1Aaj6xDmZvM22RtGX5eDBBu2C8GgJw3pUYr3fQuGZj7HKPXFVuk3pSTQRqkWtJvnpc4rfiPYYNpM5wkx6CPenQ39vsdeEi36mDL8Eww6XvyN4cQxzJFcSymATDbQZ1z8yqYSQeeDKF6qCM7ddPr5g5fUzcApepqFrGNg7MqGAs1euvLGHhRk7UoeEpofFfwp3Km5FABdzAsdFR9'
and not exists (select box_id from node_inputs where node_inputs.box_id = node_outputs.box_id)

order by 
node_outputs.additional_registers::json->'R5'->> 'renderedValue',
node_outputs.creation_height
desc
