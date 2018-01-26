drop view pd_wbgtravel.view_trip_coincidences;
create or replace view pd_wbgtravel.view_trip_coincidences as
-- Logic:
-- (1) Get all the trips, people traveling, cities they go to
-- (2) Identify where trips and people overlap in time and place
-- (3) Identify if overlapping people have meeting already scheduled?
-- (4) Identify meetings scheduled for trips that don't have coincidences with other travelers

--(1) Get all the trips
with trips_cities_people as
(
	select 
	tr.trip_id,
	tr.person_id,
	pe.short_name,
	pe.is_wbg,
	tr.city_id,
	tr.trip_start_date,
	tr.trip_end_date,
	tr.trip_reason,
	ci.latitude,
	ci.longitude,
	ci.city_name,
	ci.country_name
	from pd_wbgtravel.trips tr
	inner join pd_wbgtravel.cities ci on ci.city_id = tr.city_id
	inner join pd_wbgtravel.people pe on pe.person_id = tr.person_id
),
-- (2) Identify where trips overlap
trip_coincidences as
(
	select 
	t1.trip_id,
	t1.city_id,
	t1.person_id,
	t1.short_name as person_name,
	t1.is_wbg,
	t1.city_name,
	t1.country_name,
	t1.trip_start_date,
	t1.trip_end_date,
	t1.trip_reason,
	t2.trip_id as coincidence_trip_id,
	t2.city_id as coincidence_city_id,
	t2.person_id as coincidence_person_id,
	t2.short_name as coincidence_person_name,
	t2.is_wbg as coincidence_is_wbg,
	t2.city_name as coincidence_city_name,
	t2.country_name as coincidence_country_name,
	t2.trip_reason as coincidence_trip_reason
	from trips_cities_people t1 
	-- Join logic:
	-- For someone else's trip (ie, don't match my own trip)
	-- The dates of their trip overlap with the dates of my trip
	-- We're within 100km of each other
	-- See https://en.wikipedia.org/wiki/Decimal_degrees; note degrees are radial so this is approximate.  But objective is approximate.
	-- Value differene <1 is approximately less than 100km. 
	inner join trips_cities_people t2 
		on t1.trip_id <> t2.trip_id and
		(
			(
				t2.trip_start_date between t1.trip_start_date and t1.trip_end_date or
				t2.trip_end_date between t1.trip_start_date and t1.trip_end_date
			)
			and	((t1.latitude - t2.latitude)^2 + (t1.longitude - t2.longitude)^2)^.5 < 1 --
		)
),
-- (3) When trips overlap do they already have meetings scheduled?
trip_coincidence_meetings as
(
	select 
	tc.*, 
	case when tm.meeting_person_id is not null then 'YES' else 'NO' end as has_meeting,
	case when tm.meeting_person_id is not null then tc.coincidence_person_name else NULL end as meeting_person_name,
	tm.topic
	from trip_coincidences tc
	left join pd_wbgtravel.trip_meetings tm on 
		(tm.travelers_trip_id = tc.trip_id and tm.meeting_person_id = tc.coincidence_person_id) or -- Meeting already scheduled with coincidence person
		(tm.travelers_trip_id = tc.coincidence_trip_id and tm.meeting_person_id = tc.person_id)    -- Reciprocally, if A meets B then B meets A 
)
-- (4) For trips that don't overlap with anyone, do they have meetings scheduled?
-- Note: we're not able to do a left-join in step 3 to get all trips to join meetings onto because not all meetings are scheduled with
-- people that have trips explicitly entered into the system.   That is, people on trips schedule meetings with other people (who may or may not 
-- have a trip defined).  Therefore, pulling all people on trips doesn't pull all people who are having meetings.
--select * from trip_coincidence_meetings
select 
tcp.trip_id,
tcp.city_id,
tcp.person_id,
tcp.short_name as person_name,
tcp.is_wbg,
tcp.city_name,
tcp.country_name,
tcp.trip_start_date,
tcp.trip_end_date,
tcp.trip_reason,
null as coincidence_trip_id,
null as coincidence_city_id,
null as coincidence_person_id,
null as coincidence_person_name,
null as coincidence_is_wbg,
null as coincidence_city_name,
null as coincidence_country_name,
null as coincidence_trip_reason,
case when tm.meeting_person_id is not null then 'YES' else 'NO' end as has_meeting,
pe.short_name as meeting_person_name,
tm.topic
from trips_cities_people tcp
left join pd_wbgtravel.trip_meetings tm on tm.travelers_trip_id = tcp.trip_id
left join pd_wbgtravel.people pe on pe.person_id = tm.meeting_person_id
where not exists(select * from trip_coincidence_meetings tcm where tcm.trip_id = tcp.trip_id)

union all

select * from trip_coincidence_meetings;