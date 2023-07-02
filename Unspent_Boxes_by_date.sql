select
no.box_id,
no.address,
no.value,
no.creation_height,
no.settlement_height,
to_timestamp(timestamp/1000) as Date
from node_outputs no

left join
(select ni.box_id
  from node_inputs ni
where ni.main_chain = true ) i
on i.box_id = no.box_id

where no.main_chain = true
and to_timestamp(timestamp/1000) < to_timestamp('1 Jan 2020', 'DD Mon YYYY')
and not exists (select box_id from node_inputs ni where no.box_id = ni.box_id)
;






 