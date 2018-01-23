insert into people(short_name,organization,image_file,is_wbg)
select distinct 
"Person" as full_name,
"Organization" as organization,
"file" as image_file,
1 as is_wbg
from dev_events

union all

select distinct 
"Counterpart" as full_name,
'Unknown' as organization,
null as image_file,
0 as is_wbg
from dev_events;

insert into cities(city_name,country_name,latitude,longitude)
select distinct 
"City of visit" as city_name,
"Country of visit" as country_name,
"Lat" as latitude,
"Long" as longitude
from dev_events;

insert into trips(person_id,city_id,trip_start_date,trip_end_date,trip_title)
SELECT distinct
pe.person_id,
ci.city_id,
de."Visit start",
de."Visit end",
'test trip' as title
FROM dev_events de
inner join people pe on pe.short_name = de."Person" or pe.short_name = de."Counterpart"
inner join cities ci on ci.city_name = de."City of visit" and ci.country_name = de."Country of visit";

insert into pd_wbgtravel.agendas(agenda_type,short_title,long_title,calendar_schedule)
select distinct 
case when lower("Event") like '%summit%' or "Event" like '%conference%' or "Event" like '%Symposium%' then 'event' else 'meeting' end as agenda_type,
substring("Event" from 1 for 20) as short_title,
"Event" as long_title,
ARRAY["Visit start","Visit end"] as calendar_schedule
from pd_wbgtravel.dev_events;

insert into pd_wbgtravel.trip_agendas(trip_id,agenda_id)
select trip_id,agenda_id from pd_wbgtravel.people pe 
inner join pd_wbgtravel.trips tr on tr.person_id = pe.person_id
inner join pd_wbgtravel.agendas ag on tr.trip_start_date = ag.calendar_schedule[1] and tr.trip_end_date = ag.calendar_schedule[2];

insert into trip_meetings(meeting_person_id,travelers_trip_id,topic)
select distinct pe.person_id as meeting_person_id,
tr.trip_id as travelers_trip_id,
de."Event" as topic from pd_wbgtravel.dev_events de
inner join pd_wbgtravel.cities ci on ci.city_name = de."City of visit" and ci.country_name = de."Country of visit"
inner join pd_wbgtravel.people pe on pe.short_name = de."Counterpart"
inner join pd_wbgtravel.trips tr on tr.city_id = ci.city_id and tr.trip_start_date = de."Visit start" and tr.trip_end_date = "Visit end" and tr.person_id = pe.person_id;