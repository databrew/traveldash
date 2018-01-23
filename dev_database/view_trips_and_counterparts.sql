create VIEW pd_wbgtravel.trips_and_counterparts as
with all_trip_agendas as
(
	select 
	ta.trip_id,
	ag.*
	from pd_wbgtravel.trip_agendas ta 
	inner join pd_wbgtravel.agendas ag on ag.agenda_id = ta.agenda_id -- all the details of their agenda on the trip
),
all_trips as
(
select 
tr.trip_id,
pe.person_id,
ci.city_id,
ata.agenda_id,
pe.short_name,
pe.title,
pe.organization,
pe.sub_organization,
pe.is_wbg,
tr.trip_start_date,
tr.trip_end_date,
tr.trip_title,
ci.country_name,
ci.city_name,
ci.latitude,
ci.longitude,
ata.agenda_type,
ata.short_title,
ata.calendar_schedule
from pd_wbgtravel.trips tr -- all the trips
inner join pd_wbgtravel.people pe on pe.person_id = tr.person_id -- all the people travelling on those trips
left join pd_wbgtravel.cities ci on ci.city_id = tr.city_id -- all the cities the people go
left join all_trip_agendas ata on ata.trip_id = tr.trip_id -- all the agendas on the trips
)
select 
	trips.*,
	pe2.short_name as counterpart_name 
from all_trips trips
left join pd_wbgtravel.trip_agendas ta on ta.agenda_id = trips.agenda_id and ta.trip_id <> trips.trip_id
left join pd_wbgtravel.trips tr2 on tr2.trip_id = ta.trip_id
left join pd_wbgtravel.people pe2 on pe2.person_id = tr2.person_id
order by agenda_id