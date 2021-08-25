select o.vendor_code,
v.name as vendor_name, 
v.global_vendor_id as grid,
v.is_test as is_backend_test,
a.is_marked_for_testing_training as is_salesforce_test,
a.vertical_segment,
count(distinct case when o.is_gross_order and not o.is_test_order then o.code end) as gross_orders
from `fulfillment-dwh-production.pandata_curated.pd_orders` o
left join `fulfillment-dwh-production.pandata_curated.pd_vendors` v
  on o.vendor_code = v.vendor_code and o.global_entity_id = v.global_entity_id
left join `fulfillment-dwh-production.pandata_curated.sf_accounts` a
       on a.global_entity_id = v.global_entity_id and a.global_vendor_id = v.global_vendor_id 
where o.created_date_utc >= current_date() - 180
  and o.global_entity_id = 'FP_PK'
  and (
    v.is_test
    or a.is_marked_for_testing_training 
  )
  and a.vertical_segment = 'Regular Restaurant'
group by 1,2,3,4,5,6