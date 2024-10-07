For each decade, get the top three drivers in terms of race wins. To do this,
we left join a list of decades to a subquery that joins 
* drivers for driver info
* results to see any wins
* and races to get the decade
```sql
with decades as (
    select extract('year' from date_trunc('decade', date)) as decade
    from races
    group by decade
)
select
    decade,
    rank() over(partition by decade
                order by wins desc) as rank,
    forename,
    surname,
    wins
from decades
     left join lateral
     (
        select code, forename, surname, count(*) as wins
        from
            drivers
        join
            results
        on results.driver_id = drivers.driver_id
        and results.position = 1
        join
            races using(race_id)
        where extract('year' from date_trunc('decade', races.date)) = decades.decade
        group by decades.decade, drivers.driver_id
        order by wins desc
        limit 3
    ) as winners on true
order by decade asc, wins desc;
```

#### kNN Ordering and GiST indexes
Find the 10 nearest circuits to Paris, France, which is at longitude 2.349014 
and latitude 48.864716, using `point` data type and distance operator `<->`
```sql
  select name, location, country
    from circuits
order by point(lng,lat) <-> point(2.349014, 48.864716)
   limit 10; 
```
can add column of type `point` and add `gist` index:
```sql
begin;
alter table circuits add column position point;
update circuits set position = point(lng,lat);
create index on circuits using gist(position);
commit;

explain (costs off, buffers, analyze)
  select name, location, country
    from circuits
order by position <-> point(2.349014, 48.864716)
   limit 10;

-- Index Scan using circuits_position_idx on circuits (actual time=0.043..0.054 rows=10 loops=1)
```


Use `CASE` statement for ordering, where Power Unit failure condition is considered first
```sql
select drivers.code, drivers.surname,
       position,
       laps,
       status
  from results
       join drivers using(driverid)
       join status using(statusid)
 where raceid = 972
order by position nulls last,
         laps desc,
         case when status = 'Power Unit'
              then 1
              else 2
          end;
```



List the drivers that where unlucky enough to not finish a single race in which they
participated, then we can filter out those who did finish. We know that a driver
finished because their position is filled in the results table: it is not null .
```sql
-- \set season 'date ''1978-01-01'''
select forename,
     surname,
     constructors.name as constructor,
     count(*) as races,
     count(distinct status) as reasons
from drivers
     join results using(driver_id)
     join races using(race_id)
     join status using(status_id)
     join constructors using(constructor_id)
where date >= :season
 and date <  :season + interval '1 year'
 and not exists
     (
       select 1
         from results r
        where position is not null
          and r.driverid = drivers.driver_id
          and r.resultid = results.result_id
     )
group by constructors.name, driver_id
order by count(*) desc;
```

```sql
select x
from generate_series(1, 100) as t(x)
where x not in
      (1, 2, 3);            --97 rows
--       (1, 2, 3, null);   --0 rows, everything = null
```

```sql
-- Concatenation
-- Standard SQL uses ||, format is postgres-specific
select 
    format('%s %s', forename, surname) as fullname,
    forename || ' ' || surname as fullname2
from drivers;
```

```sql
WITH seq AS (
    SELECT *
    FROM generate_series(date '2000-01-01', date '2010-01-01', interval '1 year')
    as t
)
select 
    t,
    extract('isodow' from t) as dow,
    to_char(t, 'dy') as day,
    extract('isoyear' from t) as "iso year",
    extract('week' from t) as week,
    extract('day' from (t + interval '2 month - 1 day'))as feb,
    extract('year' from t) as year,
    extract('day' from (t + interval '2 month - 1 day')) = 29 as leap
FROM seq;
```

Find the all-time top three drivers, we fetch how many times each driver had
position = 1 in the results table
```sql
select code, forename, surname, count(*) as wins
from
    drivers
join 
    results 
using(driverid)
where position = 1
group by driverid
order by wins desc
limit 3;
```

```sql
-- display all the races from a quarter with their winner
-- in psql:
-- \set beginning '2017-04-01'
-- \set months 3
select date, name, drivers.surname as winner
from
    races
left join
    results
on results.race_id = races.race_id and results.position = 1
--     (
--         select race_id, driver_id
--         from results
--         where position = 1
--     ) as winners
-- using(race_id)
left join
    drivers
using(driver_id)
where date >= date :'beginning' and
      date <  date :'beginning'
                  + :months * interval '1 month';
```
