select distinct on (node_outputs.additional_registers::json->'R5'->> 'renderedValue')
nu.name,
node_outputs.additional_registers::json->'R5'->> 'renderedValue' as Vesting_Token_id,
noa.address,
na.staked_amount / 100 as Staked_Amount,
nu.Original_Amount,
TO_DATE(replace(left(trim(both '"' from cast(nu.stakeTime as VARCHAR)),10),'-',''),'YYYYMMDD') as stake_date 

/* nu.box_id as VestingKey_box_id,
node_outputs.box_id as contract_box_id,
node_outputs.creation_height */

From node_outputs

/* find all active staking key ids and current wallet address and join on staking contracts box register (R5) from contract box. */
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
   	node_assets.value as Staked_Amount,
	node_assets.token_id,
	node_assets.box_id
  from node_assets
  inner join tokens t on node_assets.token_id = t.token_id
  where node_assets.box_id = node_outputs.box_id
  and t.name = 'NETA' /** change to 'EGIO', 'NETA', 'Paideia', 'ergopad' as required **/
) na on node_outputs.box_id = na.box_id 

/* Find staking key ID from contract and extract description */
left join lateral (
	select 
	tokens.box_id,
	tokens.token_id,
	tokens.name,
	tokens.description::json->'originalAmountStaked' as Original_Amount,
	tokens.description::json->'stakeTime' as stakeTime
	from tokens
	where tokens.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'
) nu on nu.token_id = node_outputs.additional_registers::json->'R5'->> 'renderedValue'


where node_outputs.address = '3eiC8caSy3jiCxCmdsiFNFJ1Ykppmsmff2TEpSsXY1Ha7xbpB923Uv2midKVVkxL3CzGbSS2QURhbHMzP9b9rQUKapP1wpUQYPpH8UebbqVFHJYrSwM3zaNEkBkM9RjjPxHCeHtTnmoun7wzjajrikVFZiWurGTPqNnd1prXnASYh7fd9E2Limc2Zeux4UxjPsLc1i3F9gSjMeSJGZv3SNxrtV14dgPGB9mY1YdziKaaqDVV2Lgq3BJC9eH8a3kqu7kmDygFomy3DiM2hYkippsoAW6bYXL73JMx1tgr462C4d2PE7t83QmNMPzQrD826NZWM2c1kehWB6Y1twd5F9JzEs4Lmd2qJhjQgGg4yyaEG9irTC79pBeGUj98frZv1Aaj6xDmZvM22RtGX5eDBBu2C8GgJw3pUYr3fQuGZj7HKPXFVuk3pSTQRqkWtJvnpc4rfiPYYNpM5wkx6CPenQ39vsdeEi36mDL8Eww6XvyN4cQxzJFcSymATDbQZ1z8yqYSQeeDKF6qCM7ddPr5g5fUzcApepqFrGNg7MqGAs1euvLGHhRk7UoeEpofFfwp3Km5FABdzAsdFR9'
/** 
Change above address according to contract you're interested in:
EGIO contract: 5ASYVJ2w8tH3bDMmDvjvgX76HQen4rcvoHku32GsL9js8THW6rduV5VDy8Diue6rRQfp4DRTs4P9bd4vjQY9mmE94A473YeANVps31i76HD88Xk3oeuMgWSgAPuTncfYG1hYHvyT9N7RECUYb64Hs8b2kuvUksccZ841k1vYTmhzseiAFEC59PPnfxxJ4EL9MJ6oHSfwwJBYaZHjmH5eCPkXbJZhGwnTb6bFXvCGGucjDXhmiDPSXGUU49U3r8gN2eTnbh5Dz5mh9eSudUGf7N1fWtT3asz1uruMcdYeNFptD2jFNz6MDTqajZjSEw5guvAmvZAYnfiXwRW8yQyqbd5GcwiuiaPybcGThdf5TLhYxrNeTr1eLn7d1A1RGvySo8dz9vHNrzsK4Zd8HGK4ofhE4kwepyNbYWJY9XbfKVZxqtmLTUHwheNwiJ7cQSCcQUFyMZwAKmjuXdPrVZ9AftFc5gkdqdaC82ya8oMhsbHBV68yorJbp4yyXs8qjaegUfEb4TEZ4L9NsTTsKZxfHB2GypBmssJ6gHGEongQWnca3zqSV9A55SGwbvMQrrkrnvAe9UVsK1h6XwzBj41vF2faVp7Sfp5noqJi9jZjobiCTYA344RW6dNpGS2YpxNzrZtxvyVhmyF9Tms7nSTUMpbF4L
NETA contract: 5ASYVJ2w8tH3bDQx5ZLz6rZUdokD1kmTXSRZ8GfrsAUW4vqy9eg5omtTYVzY22ibHANf7GgSc2E5FiThgo8qXzWpU3RDLohN277hksbAf9yykajXbYPUaXUeMPfSXbS1GdE4y2GoYKaXHR3H57MV5CDZE58YteqWe3XVXzmMvj1192AD7UZ1N6nguRfjgijxEWTrLq2ZrykjRAut2JBGYHanAKn46tYWW3chpxNosXG7ZW2ShDzKju2ttHhfxeZVMBydryuoEya5E9KVagjsfa9E2qPUdLpbh8enppVWcwoQ4GF1ktgzSX32QbfKhfpD23iWQixThUbcCca14FjXDt94GVFPuhAT5tQyiKen863Cq5eRAEgsQ7otX6pWa32Q28sxSF9Az4abwiJKNbFhbhb3cDCs6A45ZnW6aB6AkfwTJSAZ2ZzqqG7LXT4HdxNpdmiwno9sJWxPf2PC4vRhVqBPdxxyCgoodjyutf4UuinSCibhfqdhUJLc1JM8zX9UcD699mChgUZoKE8kXD4soVGSgQD3qfGXC6RP7n8dtowArNLm3H5QJ3EobDCbEgECLHFaHN2BPwwWscAt5eejKeFvkp3CuQ3mqFW7vfQG4n9tTLnshj8cjxnpkBdfFKC83sW8A3AoZAX4K1UrhndfLSFh4w
PAIDEIA contract: BxjSQHD1hqQFUXbXatkn46YUxM6wVsLkT5HNXJe1N1n3dM2c7X8BtgnLqszJuxoRTnzXzrCrmEjPyLxqstcnW7YkQJ9m7QTmhChBYt1hAFcTWiyVMdaiYYFtxr7qfXKcjsadtfusNhS63ZddciC3wogjrfSE3U2Fy9dhrrKStUVzWhTP22ZuwdDPv8F88WVtdLsu24bbHsv2ntXZJGhvdKnvJL83kJWs9XV582sqUBqX7kL2A5qp6T2Jxgt3gLxcZ99JhUG99YtRsmpuwb94TE5KVTESWA6cD8EdReTbP1kwW77rnJyNfj8KUsy1j7AZuNBUsVBc3oLV4GxYFDvaTNEyNBmGY3dEe8k7UKjUSnqCmYH2QM2cmhtPEdT6UBR9sS4h4YFiGsRHiybjuTSaBUPrzhJ12ESKf8jcaNna9rYprzm8ZnfwNEQFtPJyKfCoJjbwkfsAEirsMcyU3VjPAvKJ2mtu7A3WwXViBSfwUgdCnWkEhdPCRPueAXfN38JXG8HjJeZTPi3VtgcnFobg8Zjp1XtRkTaoj6i4BgyfwCft3sCYgBgmNjXhtFuuozpCiAXWyGMMs5rhJL6FzXsJWiTSML96LdshFnhoPRPi8FXVooURKztnqJowFcpLApL2ou2jfeC4iaxKgtd6zDR6ikFVXMsipVHmBrhan9dheUPnfjeXz9WVPmGLmVkrxnVv
ERGOPAD: 3eiC8caSy3jiCxCmdsiFNFJ1Ykppmsmff2TEpSsXY1Ha7xbpB923Uv2midKVVkxL3CzGbSS2QURhbHMzP9b9rQUKapP1wpUQYPpH8UebbqVFHJYrSwM3zaNEkBkM9RjjPxHCeHtTnmoun7wzjajrikVFZiWurGTPqNnd1prXnASYh7fd9E2Limc2Zeux4UxjPsLc1i3F9gSjMeSJGZv3SNxrtV14dgPGB9mY1YdziKaaqDVV2Lgq3BJC9eH8a3kqu7kmDygFomy3DiM2hYkippsoAW6bYXL73JMx1tgr462C4d2PE7t83QmNMPzQrD826NZWM2c1kehWB6Y1twd5F9JzEs4Lmd2qJhjQgGg4yyaEG9irTC79pBeGUj98frZv1Aaj6xDmZvM22RtGX5eDBBu2C8GgJw3pUYr3fQuGZj7HKPXFVuk3pSTQRqkWtJvnpc4rfiPYYNpM5wkx6CPenQ39vsdeEi36mDL8Eww6XvyN4cQxzJFcSymATDbQZ1z8yqYSQeeDKF6qCM7ddPr5g5fUzcApepqFrGNg7MqGAs1euvLGHhRk7UoeEpofFfwp3Km5FABdzAsdFR9
**/
and nu.token_id not in ('142b8012cf5383bbd9530b31cc22425f076dba192735a9432b21d70055b0d501','2dd9a4c6f6d6999077da7f0ab83d5d43fad5a1c440223a35d3cc765d461815d8') /* ignoring two ergopad keys with incorrect json formatting in description */
and not exists (select box_id from node_inputs where node_inputs.box_id = node_outputs.box_id)

order by 
node_outputs.additional_registers::json->'R5'->> 'renderedValue',
node_outputs.creation_height
desc
