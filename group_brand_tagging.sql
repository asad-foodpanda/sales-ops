with 
accounts as (select a.id, global_vendor_id, a.sf_parent_account_id, a.name
from `fulfillment-dwh-production.pandata_curated.sf_accounts` a
where a.global_entity_id = 'FP_PK'
  and a.type in ('Branch - Main', 'Branch - Kitchen Restaurant', 'Branch - Virtual Restaurant')
),
parents as (
  select accounts.id as account_id,
    accounts.name as account_name, 
    accounts.global_vendor_id, 
    a.name as parent_name,
    a.type as parent_type,
    a.sf_parent_account_id 
  from `fulfillment-dwh-production.pandata_curated.sf_accounts` a
  right join accounts 
          on a.id = accounts.sf_parent_account_id
),

grandparents as (
  select parents.account_id, 
    parents.account_name, 
    parents.global_vendor_id, 
    parents.parent_name, 
    parents.parent_type,
    a.name as grandparent_name,
    a.type as grandparent_type
  from `fulfillment-dwh-production.pandata_curated.sf_accounts` a
  right join parents on a.id = parents.sf_parent_account_id
)
, final_brands as (
select account_id, 
  account_name, 
  global_vendor_id, 
  if(parent_type = 'Brand', parent_name, null) as brand_name,
  case when parent_type = 'Group' then parent_name
    when grandparent_type = 'Group' then grandparent_name
  end as group_name,
  case when parent_type not in ('Brand', 'Group') then parent_name end as wrong_tagged
from grandparents
)

select a.global_vendor_id, 
a.is_key_vip_account,
a.key_account_sub_category,
a.is_marked_for_testing_training, a.name, v.is_test as is_backend_test, v.vertical, b.brand_name, b.group_name, b.wrong_tagged, a.status as account_status
from `fulfillment-dwh-production.pandata_curated.sf_accounts` a
left join final_brands b on a.global_vendor_id = b.global_vendor_id
left join `fulfillment-dwh-production.pandata_curated.pd_vendors`  v
    on a.global_vendor_id = v.global_vendor_id and a.global_entity_id = v.global_entity_id
where a.global_entity_id = 'FP_PK'