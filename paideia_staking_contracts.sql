select 
nu.name,
noa.address,
na.staked_amount / 10000 as Staked_Amount
/**
node_outputs.additional_registers::json->'R5'->> 'renderedValue' as VestingKey_Token_ID,
nu.box_id as VestingKey_box_id,
node_outputs.box_id as contract_box_id
**/

From node_outputs

left join lateral (
	select distinct on (node_assets.index, node_assets.token_id, node_assets.box_id)
    node_assets.value as Staked_Amount,
	node_assets.token_id,
	node_assets.box_id
  from node_assets
  left join tokens t on node_assets.token_id = t.token_id
  where node_assets.box_id = node_outputs.box_id
  and t.name = 'Paideia' /** change to Paideia, EGIO, NETA as required **/
) na on na.box_id = node_outputs.box_id

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

where node_outputs.address = 'BxjSQHD1hqQFUXbXatkn46YUxM6wVsLkT5HNXJe1N1n3dM2c7X8BtgnLqszJuxoRTnzXzrCrmEjPyLxqstcnW7YkQJ9m7QTmhChBYt1hAFcTWiyVMdaiYYFtxr7qfXKcjsadtfusNhS63ZddciC3wogjrfSE3U2Fy9dhrrKStUVzWhTP22ZuwdDPv8F88WVtdLsu24bbHsv2ntXZJGhvdKnvJL83kJWs9XV582sqUBqX7kL2A5qp6T2Jxgt3gLxcZ99JhUG99YtRsmpuwb94TE5KVTESWA6cD8EdReTbP1kwW77rnJyNfj8KUsy1j7AZuNBUsVBc3oLV4GxYFDvaTNEyNBmGY3dEe8k7UKjUSnqCmYH2QM2cmhtPEdT6UBR9sS4h4YFiGsRHiybjuTSaBUPrzhJ12ESKf8jcaNna9rYprzm8ZnfwNEQFtPJyKfCoJjbwkfsAEirsMcyU3VjPAvKJ2mtu7A3WwXViBSfwUgdCnWkEhdPCRPueAXfN38JXG8HjJeZTPi3VtgcnFobg8Zjp1XtRkTaoj6i4BgyfwCft3sCYgBgmNjXhtFuuozpCiAXWyGMMs5rhJL6FzXsJWiTSML96LdshFnhoPRPi8FXVooURKztnqJowFcpLApL2ou2jfeC4iaxKgtd6zDR6ikFVXMsipVHmBrhan9dheUPnfjeXz9WVPmGLmVkrxnVv'
 and not exists (select box_id from node_inputs where node_inputs.box_id = node_outputs.box_id)

order by na.staked_amount desc


/** 
EGIO contract: 5ASYVJ2w8tH3bDMmDvjvgX76HQen4rcvoHku32GsL9js8THW6rduV5VDy8Diue6rRQfp4DRTs4P9bd4vjQY9mmE94A473YeANVps31i76HD88Xk3oeuMgWSgAPuTncfYG1hYHvyT9N7RECUYb64Hs8b2kuvUksccZ841k1vYTmhzseiAFEC59PPnfxxJ4EL9MJ6oHSfwwJBYaZHjmH5eCPkXbJZhGwnTb6bFXvCGGucjDXhmiDPSXGUU49U3r8gN2eTnbh5Dz5mh9eSudUGf7N1fWtT3asz1uruMcdYeNFptD2jFNz6MDTqajZjSEw5guvAmvZAYnfiXwRW8yQyqbd5GcwiuiaPybcGThdf5TLhYxrNeTr1eLn7d1A1RGvySo8dz9vHNrzsK4Zd8HGK4ofhE4kwepyNbYWJY9XbfKVZxqtmLTUHwheNwiJ7cQSCcQUFyMZwAKmjuXdPrVZ9AftFc5gkdqdaC82ya8oMhsbHBV68yorJbp4yyXs8qjaegUfEb4TEZ4L9NsTTsKZxfHB2GypBmssJ6gHGEongQWnca3zqSV9A55SGwbvMQrrkrnvAe9UVsK1h6XwzBj41vF2faVp7Sfp5noqJi9jZjobiCTYA344RW6dNpGS2YpxNzrZtxvyVhmyF9Tms7nSTUMpbF4L
PAIDEIA contract: BxjSQHD1hqQFUXbXatkn46YUxM6wVsLkT5HNXJe1N1n3dM2c7X8BtgnLqszJuxoRTnzXzrCrmEjPyLxqstcnW7YkQJ9m7QTmhChBYt1hAFcTWiyVMdaiYYFtxr7qfXKcjsadtfusNhS63ZddciC3wogjrfSE3U2Fy9dhrrKStUVzWhTP22ZuwdDPv8F88WVtdLsu24bbHsv2ntXZJGhvdKnvJL83kJWs9XV582sqUBqX7kL2A5qp6T2Jxgt3gLxcZ99JhUG99YtRsmpuwb94TE5KVTESWA6cD8EdReTbP1kwW77rnJyNfj8KUsy1j7AZuNBUsVBc3oLV4GxYFDvaTNEyNBmGY3dEe8k7UKjUSnqCmYH2QM2cmhtPEdT6UBR9sS4h4YFiGsRHiybjuTSaBUPrzhJ12ESKf8jcaNna9rYprzm8ZnfwNEQFtPJyKfCoJjbwkfsAEirsMcyU3VjPAvKJ2mtu7A3WwXViBSfwUgdCnWkEhdPCRPueAXfN38JXG8HjJeZTPi3VtgcnFobg8Zjp1XtRkTaoj6i4BgyfwCft3sCYgBgmNjXhtFuuozpCiAXWyGMMs5rhJL6FzXsJWiTSML96LdshFnhoPRPi8FXVooURKztnqJowFcpLApL2ou2jfeC4iaxKgtd6zDR6ikFVXMsipVHmBrhan9dheUPnfjeXz9WVPmGLmVkrxnVv
NETA Contract: 5ASYVJ2w8tH3bDQx5ZLz6rZUdokD1kmTXSRZ8GfrsAUW4vqy9eg5omtTYVzY22ibHANf7GgSc2E5FiThgo8qXzWpU3RDLohN277hksbAf9yykajXbYPUaXUeMPfSXbS1GdE4y2GoYKaXHR3H57MV5CDZE58YteqWe3XVXzmMvj1192AD7UZ1N6nguRfjgijxEWTrLq2ZrykjRAut2JBGYHanAKn46tYWW3chpxNosXG7ZW2ShDzKju2ttHhfxeZVMBydryuoEya5E9KVagjsfa9E2qPUdLpbh8enppVWcwoQ4GF1ktgzSX32QbfKhfpD23iWQixThUbcCca14FjXDt94GVFPuhAT5tQyiKen863Cq5eRAEgsQ7otX6pWa32Q28sxSF9Az4abwiJKNbFhbhb3cDCs6A45ZnW6aB6AkfwTJSAZ2ZzqqG7LXT4HdxNpdmiwno9sJWxPf2PC4vRhVqBPdxxyCgoodjyutf4UuinSCibhfqdhUJLc1JM8zX9UcD699mChgUZoKE8kXD4soVGSgQD3qfGXC6RP7n8dtowArNLm3H5QJ3EobDCbEgECLHFaHN2BPwwWscAt5eejKeFvkp3CuQ3mqFW7vfQG4n9tTLnshj8cjxnpkBdfFKC83sW8A3AoZAX4K1UrhndfLSFh4w
**/

 
