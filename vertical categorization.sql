with

not_odr_vendors as (
  select distinct
Case when v.chain_code = 'cb1qb' then 'ODR' else 'Others' end as ODR_Ct,
v.chain_code,
v.chain_name,
v.vendor_code,
v.uuid,
from `fulfillment-dwh-production.pandata_curated.pd_vendors`   v
where
global_entity_id in ('FP_PK')
),

verticals as (
  select
  v.vendor_code,
  v.chain_code,
  v.chain_name,
  v.global_vendor_id as grid,
  v.name as vendor_name,
  v.is_test as is_backend_test,
  a.is_marked_for_testing_training as is_sf_test,
  v.is_private,
  v.is_active as is_backend_active,
  case 
    when odv.ODR_Ct = 'ODR' then 'PandaGo'
    when lower(b.business_type_apac) LIKE '%concept%' then 'concepts'
    when lower(b.business_type_apac) LIKE '%kitchen%' then 'shared kitchens'
    when lower(a.vertical_segment) like '%home%' then 'home chefs'    
    when lower(a.vertical_segment) like '%darkstore%' then 'darkstores'
    when a.vertical_segment = 'caterers' then 'caterers'
    when lower(a.vertical_segment) = 'regular restaurant' then 'restaurants'
    when lower(a.vertical) like '%shop%' then 'shops'
    when a.vertical is null then
     case 
     when lower(b.business_type_apac) like '%home%' then 'home chefs'
     when b.business_type_apac = 'dmart' then 'darkstores'
     when b.business_type_apac = 'pandago' then 'PandaGo'
     when b.business_type_apac = 'kitchens' then 'shared kitchens'
        else lower(b.business_type_apac) 
     end
    else lower(a.vertical_segment)
    end as vertical
  
  from `fulfillment-dwh-production.pandata_curated.pd_vendors` v
  left join `fulfillment-dwh-production.pandata_curated.sf_accounts` a
    on a.global_vendor_id = v.global_vendor_id and v.global_entity_id = a.global_entity_id 
  join `fulfillment-dwh-production.pandata_curated.pd_vendors_agg_business_types` b on v.uuid = b.uuid
  left join not_odr_vendors odv on v.uuid = odv.uuid
  where v.global_entity_id = 'FP_PK'
--     and a.is_marked_for_testing_training = false 
--     and v.is_test = false 
--     and a.type in ('Branch - Main', 'Branch - Kitchen Restaurant', 'Branch - Virtual Restaurant')
)

select * from verticals