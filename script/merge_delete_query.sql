with deleted as (
    select *
    from red_red_cleaned
    where operation = 'Delete'
    and classified_metaData_classifiedId IS NULL
), non_deleted as (
    select 
        *
    from red_red_cleaned
    where operation != 'Delete'
    and classified_metaData_classifiedId IS NOT NULL
), joined as (
    select 
        a.id, a.partitionChangeDate, a.changeDate, a.globalObjectKey, a.operation, b.changeDate as b_changeDate, {extra_columns},
        row_number() OVER (PARTITION BY a.globalObjectKey, a.changeDate ORDER BY b.changeDate DESC) as rank
    from deleted a
    inner join non_deleted b
        on a.globalObjectKey = b.globalObjectKey
        and a.changeDate >= b.changeDate
)
select *
from joined
where
    rank = 1
    and partitioncreateddate>=to_date('{first_day_3_months_ago}') 
    and partitioncreateddate<to_date('{first_day_next_month}')