select o.vendor_code, 
  v.name as vendor_name,
  count(distinct case when o.is_gross_order and not o.is_test_order then o.code end) as gross_orders 
from `fulfillment-dwh-production.pandata_curated.pd_orders` o
join `fulfillment-dwh-production.pandata_curated.pd_vendors` v
  on o.vendor_code = v.vendor_code and o.global_entity_id = v.global_entity_id 
where o.created_date_utc >= current_date() - 185
  and o.global_entity_id = 'FP_PK'
  and v.global_vendor_id is null
  and not v.is_test
  and not v.is_private
group by 1,2
having gross_orders >= 1